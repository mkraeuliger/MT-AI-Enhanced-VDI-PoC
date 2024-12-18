<#
    Script Name:   LogGenerator.ps1
    Description:   A PowerShell script with a GUI interface for generating synthetic CPU and RAM usage logs.
                   This script allows users to input parameters such as:
                     - Start and end dates for data generation.
                     - Workdays and work hours during which logs should be generated.
                     - A specific "high load" day with an increased CPU load percentage.
                   The script creates a CSV file with 15-minute interval data, including:
                     - Timestamp
                     - Average CPU usage (percentage)
                     - Average RAM usage (percentage, based on CPU usage)

    Version:       1.0
    Created By:    Moritz Kräuliger (moritz.kraeuliger@students.fhnw.ch)
    Last Modified: 2024-11-30

    Features:
      - User-friendly GUI for parameter input.
      - Customizable workdays, hours, and load distribution patterns.
      - Automatically generates CPU and RAM usage data with realistic patterns.
      - Highlights specific "high load" days with customizable increased usage percentages.

    Inputs: 
      - Start Date: Defines the start of the log generation period.
      - End Date: Defines the end of the log generation period.
      - Workdays: Days of the week during which logs will be generated.
      - Work Hours: Time range during each workday for log generation.
      - High Load Day: A specific day with increased CPU usage.
      - High Load Percentage: Multiplier for the increased load on the defined high load day.

    Outputs:
      - A CSV file (`cpu_ram_usage_with_gui.csv`) saved in `C:\temp`, containing:
        - Date and time of each log entry.
        - Simulated average CPU and RAM usage percentages for each interval.
#>


# Load necessary .NET types for GUI components
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create and configure the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "CPU and RAM Usage Log Generator"
$form.Size = New-Object System.Drawing.Size(400, 350)
$form.StartPosition = "CenterScreen"

# Create labels and textboxes for input parameters

# Start Date Label and TextBox
$startDateLabel = New-Object System.Windows.Forms.Label
$startDateLabel.Text = "Start Date (yyyy-MM-dd HH:mm):"
$startDateLabel.AutoSize = $true
$startDateLabel.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($startDateLabel)

$startDateTextBox = New-Object System.Windows.Forms.TextBox
$startDateTextBox.Text = (Get-Date).ToString("yyyy-MM-dd HH:mm")
$startDateTextBox.Location = New-Object System.Drawing.Point(200, 20)
$form.Controls.Add($startDateTextBox)

# End Date Label and TextBox
$endDateLabel = New-Object System.Windows.Forms.Label
$endDateLabel.Text = "End Date (yyyy-MM-dd HH:mm):"
$endDateLabel.AutoSize = $true
$endDateLabel.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($endDateLabel)

$endDateTextBox = New-Object System.Windows.Forms.TextBox
$endDateTextBox.Text = (Get-Date).AddDays(5).ToString("yyyy-MM-dd HH:mm")
$endDateTextBox.Location = New-Object System.Drawing.Point(200, 60)
$form.Controls.Add($endDateTextBox)

# Workdays Label and TextBox
$workdayLabel = New-Object System.Windows.Forms.Label
$workdayLabel.Text = "Workdays (e.g., Mon, Tue, ...):"
$workdayLabel.AutoSize = $true
$workdayLabel.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($workdayLabel)

$workdayTextBox = New-Object System.Windows.Forms.TextBox
$workdayTextBox.Text = "Monday,Tuesday,Wednesday,Thursday,Friday"
$workdayTextBox.Location = New-Object System.Drawing.Point(200, 100)
$form.Controls.Add($workdayTextBox)

# Work Hours Label and TextBox
$hoursLabel = New-Object System.Windows.Forms.Label
$hoursLabel.Text = "Work hours (HH:MM-HH:MM):"
$hoursLabel.AutoSize = $true
$hoursLabel.Location = New-Object System.Drawing.Point(10, 140)
$form.Controls.Add($hoursLabel)

$hoursTextBox = New-Object System.Windows.Forms.TextBox
$hoursTextBox.Text = "08:00-17:00"
$hoursTextBox.Location = New-Object System.Drawing.Point(200, 140)
$form.Controls.Add($hoursTextBox)

# High Load Day Label and TextBox
$highLoadDayLabel = New-Object System.Windows.Forms.Label
$highLoadDayLabel.Text = "High Load Day (e.g., Friday):"
$highLoadDayLabel.AutoSize = $true
$highLoadDayLabel.Location = New-Object System.Drawing.Point(10, 180)
$form.Controls.Add($highLoadDayLabel)

$highLoadDayTextBox = New-Object System.Windows.Forms.TextBox
$highLoadDayTextBox.Text = "Friday"
$highLoadDayTextBox.Location = New-Object System.Drawing.Point(200, 180)
$form.Controls.Add($highLoadDayTextBox)

# High Load Percentage Label and TextBox
$highLoadPercentageLabel = New-Object System.Windows.Forms.Label
$highLoadPercentageLabel.Text = "Percentage of Higher Load (e.g., 50):"
$highLoadPercentageLabel.AutoSize = $true
$highLoadPercentageLabel.Location = New-Object System.Drawing.Point(10, 220)
$form.Controls.Add($highLoadPercentageLabel)

$highLoadPercentageTextBox = New-Object System.Windows.Forms.TextBox
$highLoadPercentageTextBox.Text = "50"
$highLoadPercentageTextBox.Location = New-Object System.Drawing.Point(200, 220)
$form.Controls.Add($highLoadPercentageTextBox)

# Create a button to start the script execution
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "Generate"
$okButton.Location = New-Object System.Drawing.Point(150, 260)
$okButton.Add_Click({
    # Parse input values from the textboxes
    $startDate = [datetime]::ParseExact($startDateTextBox.Text, 'yyyy-MM-dd HH:mm', $null)
    $endDate = [datetime]::ParseExact($endDateTextBox.Text, 'yyyy-MM-dd HH:mm', $null)
    $workdays = $workdayTextBox.Text.Split(",")
    $workHours = $hoursTextBox.Text.Split("-")
    $workStartHour = [datetime]::ParseExact($workHours[0], "HH:mm", $null)
    $workEndHour = [datetime]::ParseExact($workHours[1], "HH:mm", $null)
    $highLoadDay = $highLoadDayTextBox.Text
    $highLoadMultiplier = 1 + ([double]$highLoadPercentageTextBox.Text / 100)

    # Define parameters for CPU and RAM usage generation
    $cpuWeekdayMin = 5  # Minimum CPU usage for weekdays
    $cpuWeekdayMax = 85  # Maximum CPU usage for weekdays
    $timeInterval = New-TimeSpan -Minutes 15  # Define 15-minute intervals for data generation

    # Initialize variables and data array
    $current_time = $startDate
    $data = @()

    # Function to generate random CPU usage within a specified range, capped at 100%
    function Get-RandomCpuUsage {
        param (
            [double]$min,
            [double]$max
        )
        $random = Get-Random -Minimum $min -Maximum $max
        return [math]::Min([math]::Round($random, 2), 100)  # Cap value at 100%
    }

    # Function to calculate RAM usage as 12% higher than CPU usage, capped at 100%
    function Get-RamUsage {
        param (
            [double]$cpuUsage
        )
        $ramUsage = $cpuUsage * 1.12
        return [math]::Min([math]::Round($ramUsage, 2), 100)  # Cap value at 100%
    }

    # Main loop to generate data during defined workdays and hours
    while ($current_time -le $endDate) {
        $currentDayName = $current_time.DayOfWeek.ToString()

        # Check if the current time is within the defined workdays and work hours
        if ($workdays -contains $currentDayName -and ($current_time.TimeOfDay -ge $workStartHour.TimeOfDay) -and ($current_time.TimeOfDay -lt $workEndHour.TimeOfDay)) {
            if ($currentDayName -eq $highLoadDay) {
                # Generate higher CPU usage for the defined high load day
                $cpu_usage = Get-RandomCpuUsage -min ($cpuWeekdayMin * $highLoadMultiplier) -max ($cpuWeekdayMax * $highLoadMultiplier)
            } else {
                # Generate regular CPU usage for other weekdays
                $cpu_usage = Get-RandomCpuUsage -min $cpuWeekdayMin -max $cpuWeekdayMax
            }

            # Calculate RAM usage based on CPU usage
            $ram_usage = Get-RamUsage -cpuUsage $cpu_usage

            # Add generated data to the array
            $data += [PSCustomObject]@{
                "date" = $current_time.ToString("dd.MM.yyyy HH:mm")
                "Percentage CPU (Avg)" = $cpu_usage
                "Percentage RAM (Avg)" = $ram_usage
            }
        }

        # Increment current time by the defined time interval
        $current_time = $current_time.Add($timeInterval)
    }

    # Export generated data to a CSV file
    $data | Export-Csv -Path "C:\temp\cpu_ram_usage_with_gui.csv" -NoTypeInformation

    # Display a message box upon successful data generation
    [System.Windows.Forms.MessageBox]::Show("Logs have been generated and saved to C:\temp\cpu_ram_usage_with_gui.csv", "Success")

    # Close the form after completion
    $form.Close()
})

# Add the button to the form
$form.Controls.Add($okButton)

# Display the form to the user
$form.ShowDialog()
