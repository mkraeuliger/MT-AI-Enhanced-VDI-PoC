import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Load the CSV file
data = pd.read_csv("C:\\Users\\morit\\OneDrive\\MSc-FHNW\\MasterThesis\\06_artifact\\LogGenerator\\cpu_ram_usage_with_concrete_hour_alert_series.csv")

# Handle missing values (if any)
data.ffill(inplace=True)

# Extract useful features from the date/time
# Assume 'Concrete Hour' and 'Alert Series' columns already exist
# Monday-Sunday fields should already be encoded as binary (0,1)

# Normalize CPU and RAM usage
# scaler = StandardScaler()
# data[['Percentage CPU (Avg)', 'Percentage RAM (Avg)']] = scaler.fit_transform(data[['Percentage CPU (Avg)', 'Percentage RAM (Avg)']])

# Define feature columns and target variable
features = ['Percentage CPU (Avg)', 'Percentage RAM (Avg)', 'Concrete Hour', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
target = 'Alert Series'

X = data[features]
y = data[target]

# Split the dataset into training and test sets
# X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
data_train, data_test = train_test_split(data, test_size=0.2, random_state=42)

# Now you can train a classification model (e.g., RandomForest, LogisticRegression, etc.)

# Export the training set (features and target)
# X_train.to_csv("C:\\Users\\morit\\OneDrive\\MSc-FHNW\\MasterThesis\\06_artifact\\LogGenerator\\X_train.csv", index=False)
# y_train.to_csv("C:\\Users\\morit\\OneDrive\\MSc-FHNW\\MasterThesis\\06_artifact\\LogGenerator\\y_train.csv", index=False)

# Export the test set (features and target)
# X_test.to_csv("C:\\Users\\morit\\OneDrive\\MSc-FHNW\\MasterThesis\\06_artifact\\LogGenerator\\X_test.csv", index=False)
# y_test.to_csv("C:\\Users\\morit\\OneDrive\\MSc-FHNW\\MasterThesis\\06_artifact\\LogGenerator\\y_test.csv", index=False)

# Export the training and test set
data_train.to_csv("C:\\Users\\morit\\OneDrive\\MSc-FHNW\\MasterThesis\\06_artifact\\LogGenerator\\train.csv", index=False) 
data_test.to_csv("C:\\Users\\morit\\OneDrive\\MSc-FHNW\\MasterThesis\\06_artifact\\LogGenerator\\test.csv", index=False)
