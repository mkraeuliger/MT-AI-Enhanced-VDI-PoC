"""
Script Name:   DataPreProc.py
Description:   This script preprocesses a dataset containing CPU and RAM usage logs
               for machine learning purposes. It:
                 - Loads the dataset from a CSV file.
                 - Handles missing values using forward-fill (if applicable).
                 - Extracts relevant features for classification.
                 - Splits the dataset into training and testing subsets.
                 - Exports the training and test datasets to separate CSV files.

Version:       1.0
Created By:    Moritz Kräuliger (moritz.kraeuliger@students.fhnw.ch)
Last Modified: 2024-11-29

Features:
  - Prepares data for machine learning by handling missing values and normalizing features.
  - Supports binary classification using the "Alert Series" column as the target variable.
  - Encodes time-based and categorical features like "Concrete Hour" and days of the week (Monday-Sunday).
  - Outputs datasets in a format suitable for model training and evaluation.

Inputs:
  - A CSV file (`cpu_ram_usage_with_concrete_hour_alert_series.csv`) containing:
      - Features like CPU and RAM usage, encoded days of the week, and "Concrete Hour."
      - A target variable ("Alert Series") indicating alert conditions.

Outputs:
  - Two CSV files:
      - `train.csv`: Training dataset containing 80% of the data.
      - `test.csv`: Testing dataset containing 20% of the data.
"""

# Import modules
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
