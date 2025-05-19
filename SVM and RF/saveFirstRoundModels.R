rm(list=ls()
library(e1071)
library(tidyverse)
# datAll <- read.csv("~/myGit_R/Data/bot_vs_human/data_all.csv")

## this file assumes data that will be used for training the models is called training data

## change directory for downloaded data
load("~/myGit_R/Data/bot_vs_human/human_vs_bot_data.RData")

myTraining_dat <- dplyr::mutate_at(training_data, 
			.vars = vars(isBot), ~ as.factor(.)) %>%
		dplyr::select(rate,
				  sd_inter_click,
				  isBot)

 


##### train models
# linear SVM
model_linear <- svm(isBot ~ rate + sd_inter_click, 
		data = myTraining_dat, 
		kernel = "linear",
		probability = TRUE,
		type = "C-classification")

# radial kernel (RBF)
model_rbf <- svm(isBot ~ rate + sd_inter_click, 
		data = myTraining_dat, 
		kernel = "radial",
		probability = TRUE,
		type = "C-classification")

# polynomial kernel
model_poly2 <- svm(isBot ~ rate + sd_inter_click, 
		data = myTraining_dat, 
		kernel = "polynomial", 
		degree = 2,
		probability = TRUE,
		type = "C-classification")

model_poly3 <- svm(isBot ~ rate + sd_inter_click, 
		data = myTraining_dat, 
		kernel = "polynomial", 
		degree = 3,
		probability = TRUE,
		type = "C-classification")
par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))

myModels <- list()
myModels$svm <- list(
	linear = model_linear,
	rfb = model_rbf,
	poly_degree2 = model_poly2,
	poly_degree3 = model_poly2
	)


## random forest does not actually need a training and testing sample since it uses OOB; 
### for comparison purposes with our data, we utilize the training and test data as we did with the SVM
rf_model = randomForest(factor(isBot) ~ ., 
		data = training_data[,c("rate","sd_inter_click","duration","mean_inter_click","clicks_per_session","isBot")], 
		type = c("class","prob"))

myModels$RF <- rf_model

#save(myModels, file = "~/myGit_R/Data/svmRF_models.RData")
#### all models use default scale = TRUE

