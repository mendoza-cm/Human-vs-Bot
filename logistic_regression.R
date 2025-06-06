library(pROC)
library(splines)
library(gt)
library(ggplot2)



### If you simulate your own data - do not uncomment; otherwise:
#### replace directory/where/Data/is/saved/ with the loaction of the data downloaded
#load("directory/where/Data/is/saved/human_vs_bot_data.RData")
#ls()


# fit data using logistic regression
myfit <- glm(isBot ~ rate, data = training_data, family = "binomial")
summary(myfit)

# fit data again - using another predictor (sd_inter_click)
myfit2 <- glm(isBot ~ rate + sd_inter_click, data = training_data, family = "binomial")
summary(myfit2)

# classify test data
test_data <- dplyr::mutate(test_data,
				predicted_probabilities = predict(myfit2,newdata = test_data,"response"),
				logit_score = predict(myfit2,newdata = test_data,"link"))

# find auc and save roc object for later plotting
roc_obj <- roc(test_data$isBot,test_data$logit_score)
auc_value = auc(roc_obj)



# Extract the coordinates of the curve
roc_df <- data.frame(
  specificity = roc_obj$specificities,
  sensitivity = roc_obj$sensitivities
)

# Optional: reverse x-axis to match traditional ROC
roc_df$FPR <- 1 - roc_df$specificity
roc_df$TPR <- roc_df$sensitivity

# roc curve
smoothed <- as.data.frame(spline(roc_df$FPR, roc_df$TPR, n = 50))
g <- ggplot(smoothed, aes(x = x, y = y)) +
  geom_line(color = "hotpink", size = 1.2) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50") +
  coord_fixed() +
  theme_minimal() +
  labs(
    title = "Spline-Smoothed ROC Curve",
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)"
  ) +
  annotate("text", x = 0.36, y = 0.76,
           label = paste("AUC =", round(auc_value, 3)),
           color = "black", size = 5, hjust = 0, fontface = "bold") +
  theme(
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16, face = "bold"),
    plot.title = element_text(
      size = 20, face = "bold", color = "#AA336A", hjust = 0.5
    )
  )


# plot roc curve
windows()
print(g)

## will need to reference your own directory
source("~/myGit_R/Code/bot_vs_human/helperFunctions_decisionTable.R")

predValues <- predictive_values_function(dat = test_data, cuts = seq(0,1,0.1), class = "isBot", scores = "predicted_probabilities")
ROC_values <- ROC_values_function(test_data,seq(0,1,0.1),class = "isBot",scores = "predicted_probabilities")


gt_table <- merge(predValues, ROC_values) %>%
  gt() %>%
  tab_header(title = "Decision Table") %>%
  cols_label(
    cut_point = "Cut Point",
    PPV = "PPV",
    NPV = "NPV",
    selection_ratio = "Selection Ratio",
    TPR = "TPR",
    FPR = "FPR",
    accuracy = "Accuracy"
  ) %>%
tab_style(
    style = cell_text(color = "blue"),
    locations = cells_body(columns = c("cut_point", "selection_ratio", "accuracy"))
  ) %>%
  tab_style(
    style = cell_text(color = "hotpink"),
    locations = cells_body(columns = c("PPV", "NPV"))
  ) %>%
  tab_style(
    style = cell_text(color = "darkorange"),
    locations = cells_body(columns = c("TPR", "FPR"))
  )


