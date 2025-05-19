# Human-vs-Bot

This repository explores the classification of human vs. bot click behavior using simulated data and machine learning models.

## Overview

This project includes:
- Simulated click behavior data
- A logistic regression model
- Other machine learning models (in progress)

Each linked HTML page provides a full explanation of the rationale, methods, and results behind the associated R scripts. Below is a brief overview of the current R code.

---

## 📊 Simulating Data

There are several R scripts related to data simulation:
- `helperFunctions_simulatedCases.R` — Utility functions for simulating human/bot behavior.
-  `helperFunctions_decisionTable.R` — Utility functions for creating Decision Table: predictive values and ROC values alongside cutpoints.

---

## 🔍 Logistic Regression

- `logistic_regression.R` — Contains model building, performance evaluation, and visualization of results.

This script goes beyond model fitting and includes analysis of classification metrics and ROC curves.

The R file title, simulatedData_andPrep, uses the R helper functions to simulate data and prep it for logisitic regression. However, this
data can also be used for analysis using SVM and RF.

The R code also uses ggplot to compare the click rates for humans and bots. The file logistic_regression creates two models, one using the predictor
rate and the other model using two predictors, rate and standard deviation for time between clicks for humans and bots.

---

## 🤖 Other Machine Learning Models

The R code and a seperate readme file is available in the SVM and RF folder.

---


## 🧪 Requirements (Optional)
- R (≥ 4.0)
- `tidyverse`, `pROC`, `e1071`, `randomForest`, etc.


## 📄 License
This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
