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

There are two R scripts related to data simulation:
- `helperFunctions_simulatedCases.R` — Utility functions for simulating human/bot behavior.
- `simulatedData_andPrep.R` — Generates the dataset and prepares it for modeling.

---

## 🔍 Logistic Regression

- `logistic_regression.R` — Contains model building, performance evaluation, and visualization of results.

This script goes beyond model fitting and includes analysis of classification metrics and ROC curves.

---

## 🤖 Other Machine Learning Models

While the HTML write-up outlines Support Vector Machines (SVM) and Random Forests (RF), the corresponding R code is still under development and will be added soon.

---

## 📌 Table of Contents (Optional)
- [Simulating Data](#-simulating-data)
- [Logistic Regression](#-logistic-regression)
- [Other Machine Learning Models](#-other-machine-learning-models)

## 🧪 Requirements (Optional)
- R (≥ 4.0)
- `ggplot2`, `dplyr`, `pROC`, `e1071`, `randomForest`, etc.

## 📄 License (Optional)
MIT License — see `LICENSE` file for details.
