# Master Thesis Artifact Repository

## Overview

This repository contains the code and relevant documentation for the artifact developed as part of my master's thesis. The thesis focuses on integrating AI solutions into Virtual Desktop Infrastructure (VDI) to enhance user experience, improve security, and optimize operational efficiency and costs. The artifact demonstrates the practical application of AI technologies, including predictive analytics, real-time data processing, and automation within the Azure ecosystem.

## Repository Structure

- **/src**: Contains all source code files for the artifact, including scripts for data collection, data preprocessing, model training, and deployment.
- **/notebooks**: Jupyter notebooks for data analysis, model training, and testing.
- **/docs**: Supplementary documentation, research notes, and diagrams that illustrate the architecture and design processes.
- **/config**: Configuration files for deployment in the Azure environment.
- **/scripts**: PowerShell and Python scripts for setting up the Azure environment and automating workflows.
- **/tests**: Test cases and scripts for end-to-end testing of the artifact’s functionality.
- **/results**: Outputs from the experiments, including model performance metrics and logs.

## Key Components

1. **Azure Virtual Desktop (AVD) **:
   - Provides the virtual machines (VMs) and hosts applications and desktops.
   - Supplies continuous data on metrics such as CPU and RAM usage for performance monitoring.

2. **Azure Monitoring**:
   - Collects and processes data in real time from AVD instances.
   - Sets up alert rules to trigger responses when specific thresholds are exceeded.

3. **Azure Runbook**:
   - Automates operational tasks and runs PowerShell scripts based on triggers from Azure Monitoring.
   - Executes the necessary scaling actions or optimization workflows as defined in the artifact.

4. **Azure Machine Learning (Azure ML)**:
   - Builds, trains, and deploys machine learning models to predict and optimize resource allocation.
   - Enables proactive resource management and scaling decisions based on predictive analytics.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/username/master-thesis-artifact.git
