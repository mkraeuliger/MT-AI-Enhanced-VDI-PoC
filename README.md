# Master Thesis Artifact Repository

## Overview

This repository contains the code and relevant documentation for the artifact developed as part of my master's thesis. The thesis focuses on integrating AI solutions into Virtual Desktop Infrastructure (VDI) to enhance user experience, improve security, and optimize operational efficiency and costs. The artifact demonstrates the practical application of AI technologies, including predictive analytics, real-time data processing, and automation within the Azure ecosystem.

## Repository Structure

- **/docs**: Supplementary documentation, research notes, and diagrams that illustrate the architecture and design processes.
- **/scripts**: PowerShell and Python scripts for setting up the Azure environment and automating workflows.
- **/tests**: Test cases and results form end-to-end testing of the artifact’s functionality.

## Key Components

1. **Azure Virtual Desktop (AVD)**:
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

## Video
[![MT-ArtifactResult](https://img.youtube.com/vi/6D2IzQyS8RY/0.jpg)](https://www.youtube.com/watch?v=6D2IzQyS8RY)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/username/master-thesis-artifact.git
