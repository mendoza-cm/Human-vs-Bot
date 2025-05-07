myfit <- glm(isBot ~ rate, data = training_data, family = "binomial")
summary(myfit)

myfit2 <- glm(isBot ~ rate + sd_inter_click, data = training_data, family = "binomial")
summary(myfit2)

test_data <- dplyr::mutate(test_data,
				predicted_probabilities = predict(myfit2,newdata = test_data,"response"),
				logit_score = predict(myfit2,newdata = test_data,"link"))
library(pROC)
roc_obj <- roc(test_data$isBot,test_data$logit_score)
auc(roc_obj)
windows()
plot(roc_obj, col = "darkgreen", main = "ROC Curve")
abline(a = 0, b = 1, lty = 2, col = "gray")



# Extract the coordinates of the curve
roc_df <- data.frame(
  specificity = roc_obj$specificities,
  sensitivity = roc_obj$sensitivities
)

# Optional: reverse x-axis to match traditional ROC
roc_df$FPR <- 1 - roc_df$specificity
roc_df$TPR <- roc_df$sensitivity


library(splines)

smoothed <- as.data.frame(spline(roc_df$FPR, roc_df$TPR, n = 50))
windows()
ggplot(smoothed, aes(x = x, y = y)) +
  geom_line(color = "hotpink", size = 1.2) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50") +
  coord_fixed() +
  theme_minimal() +
  labs(
    title = "Spline-Smoothed ROC Curve",
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)"
  )
