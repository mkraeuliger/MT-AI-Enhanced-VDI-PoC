# Output is a status object (IsSuccessStatusCode, ReasonPhrase, RequestId, StatusCode)
[OutputType("PSAzureOperationResponse")]

param
(
    [parameter (Mandatory=$false)]
    [object] $WebhookData
)

$ErrorActionPreference = "stop"

# Check if WebhookData is provided
if ($WebhookData)
{
    # Parse the WebhookData into JSON format
    $WebhookBody = ConvertFrom-Json -InputObject $WebhookData.RequestBody

    # Extract the schema ID to determine the payload type
    $schemaId = $WebhookBody.schemaId
    Write-Verbose "schemaId: $schemaId" -Verbose

    # Handle various schema types for extracting VM information
    if ($schemaId -eq "azureMonitorCommonAlertSchema") {
        # Handle Azure Monitor common metric alert schema
        $Essentials = [object] ($WebhookBody.data).essentials
        # Extract subscription, resource group, resource type, and VM name
        $alertTargetIdArray = (($Essentials.alertTargetIds)[0]).Split("/")
        $SubId = $alertTargetIdArray[2]
        $ResourceGroupName = $alertTargetIdArray[4]
        $ResourceType = $alertTargetIdArray[6] + "/" + $alertTargetIdArray[7]
        $ResourceName = $alertTargetIdArray[-1]
        $status = $Essentials.monitorCondition
    }
    elseif ($schemaId -eq "AzureMonitorMetricAlert") {
        # Handle Azure Monitor near-real-time metric alert schema
        $AlertContext = [object] ($WebhookBody.data).context
        $SubId = $AlertContext.subscriptionId
        $ResourceGroupName = $AlertContext.resourceGroupName
        $ResourceType = $AlertContext.resourceType
        $ResourceName = $AlertContext.resourceName
        $status = ($WebhookBody.data).status
    }
    elseif ($schemaId -eq "Microsoft.Insights/activityLogs") {
        # Handle Activity Log alert schema
        $AlertContext = [object] (($WebhookBody.data).context).activityLog
        $SubId = $AlertContext.subscriptionId
        $ResourceGroupName = $AlertContext.resourceGroupName
        $ResourceType = $AlertContext.resourceType
        $ResourceName = (($AlertContext.resourceId).Split("/"))[-1]
        $status = ($WebhookBody.data).status
    }
    elseif ($schemaId -eq $null) {
        # Handle original metric alert schema
        $AlertContext = [object] $WebhookBody.context
        $SubId = $AlertContext.subscriptionId
        $ResourceGroupName = $AlertContext.resourceGroupName
        $ResourceType = $AlertContext.resourceType
        $ResourceName = $AlertContext.resourceName
        $status = $WebhookBody.status
    }
    else {
        # Unsupported schema type
        Write-Error "The alert data schema - $schemaId - is not supported."
    }
}

# Disable Az context autosave for process scope
Disable-AzContextAutosave -Scope Process

# Authenticate using Managed Identity
$ClientId = Get-AutomationVariable -Name "AUTOMATION_VMALERT_USER_ASSIGNED_IDENTITY_ID" -ErrorAction SilentlyContinue
if ($ClientId) {
    # Use user-assigned managed identity
    $AzureContext = (Connect-AzAccount -Identity -AccountId $ClientId).context
} else {
    # Use system-assigned managed identity
    $AzureContext = (Connect-AzAccount -Identity).context
}

# Set the active context to the specific subscription
$AzureContext = Set-AzContext -Subscription $SubId -DefaultProfile $AzureContext
Write-Verbose "Subscription to work against: $SubId" -Verbose

# Define VM name from extracted resource information
$vmName = $ResourceName

# Attempt to retrieve VM details
try {
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $ResourceName -DefaultProfile $AzureContext -ErrorAction Stop
    Write-Output "Retrieved VM details for: $vmName"
} catch {
    Write-Error "Could not find the VM: $vmName."
}

# Define VM resource ID for metrics retrieval
$resourceId = $vm.Id

# Define time range for metric collection (last 15 minutes)
$endTime = Get-Date
$startTime = $endTime.AddMinutes(-15)

# Initialize CPU and RAM usage variables
$cpuUsage = 90  # Default value
$ramUsage = 95  # Default value
$ConcreteHour = $endTime.Hour

Write-Output "Current Hour: $ConcreteHour"

# Initialize weekday columns for payload
$weekdayColumns = @{
    "Monday" = 0;
    "Tuesday" = 0;
    "Wednesday" = 0;
    "Thursday" = 0;
    "Friday" = 0;
    "Saturday" = 0;
    "Sunday" = 0;
}
$dayOfWeek = $endTime.DayOfWeek.ToString()
Write-Output "Day of the week: $dayOfWeek"

# Mark the current day in the dictionary
$weekdayColumns[$dayOfWeek] = 1

# Retrieve CPU usage, fallback to 0 if data is unavailable
try {
    $cpuMetrics = Get-AzMetric -ResourceId $resourceId -MetricName "Percentage CPU" -StartTime $startTime -EndTime $endTime
    if ($cpuMetrics.Data) {
        $cpuUsage = [Math]::Round(($cpuMetrics.Data | Measure-Object -Property Average -Average).Average, 2)
        Write-Output "VM CPUUsage Details: $cpuUsage"
    }
} catch {
    Write-Warning "CPU usage data not available for VM: $vmName. Defaulting to 0."
}

# Retrieve RAM usage, fallback to 0 if data is unavailable
try {
    $ramMetrics = Get-AzMetric -ResourceId $resourceId -MetricName "Memory Usage" -StartTime $startTime -EndTime $endTime
    if ($ramMetrics.Data) {
        $ramUsage = [Math]::Round(($ramMetrics.Data | Measure-Object -Property Average -Average).Average, 2)
    }
} catch {
    Write-Warning "RAM data not available for VM: $vmName. Defaulting to 0."
}

# Output the current usage details
$usageDetails = @{
    VMName = $vmName
    CPUUsagePercentage = $cpuUsage
    RAMUsagePercentage = $ramUsage
}
Write-Output "VM Usage Details:"
Write-Output $usageDetails

# Prepare payload for sending to the ML model API
$payload = @{
    "input_data" = @{
        "columns" = @("Percentage CPU (Avg)", "Percentage RAM (Avg)", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Concrete Hour")
        "index" = @(0)
        "data" = @(
            ,@($cpuUsage, $ramUsage, $weekdayColumns["Monday"], $weekdayColumns["Tuesday"], $weekdayColumns["Wednesday"], $weekdayColumns["Thursday"], $weekdayColumns["Friday"], $weekdayColumns["Saturday"], $weekdayColumns["Sunday"], $ConcreteHour)
        )
    }
} | ConvertTo-Json -Depth 3

Write-Output "Payload prepared for API: $payload"

# Define the API endpoint and authorization
$apiUrl = "https://azmlmkr-hbbmq.eastus2.inference.ml.azure.com/score"
$token = "Pth5aageUO0gOrfp0kZvOpgBJadMaich"  # Replace this with actual token for production use
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Send data to the API and handle response
try {
    $response = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $payload
    Write-Output "API Response: $response"
} catch {
    Write-Verbose "Error calling API: $_" -Verbose
}

# Check response and proceed to VM upscaling if needed
if ($response -eq 1) {
    Write-Output "API Response indicates upscale required - Executing VM upsize"
    # Proceed with VM upsize logic...
} else {
    Write-Output "No action taken. ML Model prediction was $response"
}
