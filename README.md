# Human-vs-Bot

Welcome! This repository explores the classification of human vs. bot response behavior using simulated data and machine learning models.
We begin with feature engineering, apply classification models, and evaluate performance using a variety of metrics and visualizations in both R and Python.

## Overview

This project includes:
- Simulated response behavior data
- A logistic regression model
- Other machine learning models 

Each linked HTML page provides a full explanation of the rationale, methods, and results behind the associated R scripts. Below is a brief overview of the current R code.

## Recent Updates

- **May 2025**: Renamed all columns containing "click" to use "response" instead, to more accurately reflect behavior data and reduce ambiguity. Updated relevant code and datasets accordingly.

---

## 📊 Simulating Data
This module focuses on simulating test data to perform analyis on in R and Python; this project will be expanded to include SQL.

### 📁 Files
  - helperFunctions_simulateCases — Contains all helper functions used to generate synthetic response data for both human and bot users.
  - simulatedData_andPrep — creates training and test data management

If human 
    
### 🧠 Overview
This project was sparked by an unexpected failure: I was unable to scrape a website using standard R tools. That led me to consider the 
problem from another angle: how do we distinguish bot behavior from human behavior?

In our current digital environment, one possible differentiator is timing. Specifically, if bots and humans follow different time distributions 
between responses, could that be used as a basis for classification?

The main goal of this module is to simulate realistic user session data, where each session consists of multiple responses, each with a timestamp. The output includes:
- a unique `id` per user
- a `sessioin_id` for mulitple-session users
- timestamps from the first to the last response in each session

Users can also specify whether duplicate IDs are allowed, enabling more complex simulation scenarios.
Data generation is handled by four core functions:

- human_startTimes
- human_timesDistributionDF

- bot_startTimes
- bot_timesDistributionDF

The *_startTimes() functions generate user/session combinations, while the *_timesDistributionDF() functions create response-timestamp data based on human-like or bot-like timing patterns.

Thus





  
---

## 🔍 Logistic Regression

### 📁 Files
  - simulatedData_andPrep.R
    Generates synthetic data and prepares it for classification. The simulated dataset is also shared with the SVM and Random Forest models for consistency across methods.

  - logistic_regression.R
    Builds logistic regression models, evaluates performance, and visualizes results using ggplot2.
### 🧠 Overview

---

## 🤖 Other Machine Learning Models

The R code and a seperate readme file is available in the SVM and RF folder.

---


## 🧪 Requirements (Optional)
- R (≥ 4.0)
- `tidyverse`, `pROC`, `e1071`, `randomForest`, etc.


## 📄 License
This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
