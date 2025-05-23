rm(list=ls())
library(car)
library(e1071)
library(tidyverse)
library(pROC)
library(webshot2)
library(plyr)

# load saved data
load("~/myGit_R/Data/svmRF_models.RData")
load("~/myGit_R/Data/bot_vs_human/human_vs_bot_data.RData")


## this file assumes data that will be used for training the models is called training_data & test_data

## 
myTraining_dat <- dplyr::mutate_at(training_data, 
			.vars = vars(isBot), ~ as.factor(.)) %>%
		dplyr::select(rate,
				  sd_inter_click,
				  isBot)


## using models created in saveFirstRoundModels, predict class membership: we store the class based on the ML threshold, but also save the probabilities below
test_data <- test_data %>%
		dplyr::mutate(svmLinear_pred = predict(myModels$svm$linear,.),
				 svmRFB_pred = predict(myModels$svm$rfb,.),
				 svmPoly2_pred = predict(myModels$svm$poly_degree2,.),
				 svmPoly3_pred = predict(myModels$svm$poly_degree3,.),
				 RF_pred = predict(myModels$RF,.)
				) %>%
		dplyr::mutate_at(.vars = vars(svmLinear_pred,
							svmRFB_pred,
							svmPoly2_pred,
							svmPoly3_pred,
							RF_pred), ~
							as.logical(.)) %>%
		dplyr::mutate(svmLinear_predProb = attr(predict(myModels$svm$linear,., probability = TRUE),"probabilities")[,"TRUE"],
				 svmRFB_predProb = attr(predict(myModels$svm$rfb,., probability = TRUE),"probabilities")[,"TRUE"],
				 svmPoly2_predProb = attr(predict(myModels$svm$poly_degree2,., probability = TRUE),"probabilities")[,"TRUE"],
				 svmPoly3_predProb = attr(predict(myModels$svm$poly_degree3,., probability = TRUE),"probabilities")[,"TRUE"],
				 RF_predProb = predict(myModels$RF,., type = "prob")[,"TRUE"]
				) 

## table up results
my_ML_predNames <- grep("_pred$",names(test_data), value = TRUE)
myClassTesting <- data.frame(
	
	classifier = my_ML_predNames			

)
for(predName in my_ML_predNames){


	myClassTesting[which(myClassTesting[,"classifier"] == predName),"true_positives"] <- length(which(test_data[,predName] & test_data$isBot))
	myClassTesting[which(myClassTesting[,"classifier"] == predName),"true_negatives"] <- length(which(!test_data[,predName] & !test_data$isBot))
			
	
	myClassTesting[which(myClassTesting[,"classifier"] == predName),"Accuracy"] <- round(
		(myClassTesting[which(myClassTesting[,"classifier"] == predName),2] + 
											myClassTesting[which(myClassTesting[,"classifier"] == predName),3])/240
															,3)


	## Get AUC value
	roc_obj <- roc(test_data$isBot,test_data[,paste0(predName,"Prob")])
	myClassTesting[which(myClassTesting[,"classifier"] == predName),"Model AUC"] <- round(auc(roc_obj),3)


	}
oob_acc <- 1 - myModels$RF$err.rate[nrow(myModels$RF$err.rate), "OOB"]
oob_pred <- predict(myModels$RF)  # by default uses OOB votes if no newdata is given
#oob_acc2 <- mean(oob_pred == training_data$isBot) # should match oob_acc


oob_probs_allPreds <- predict(myModels$RF, type = "prob")[, "TRUE"]
roc_oob <- roc(response = training_data$isBot, predictor = oob_probs_allPreds)
auc_oob <- auc(roc_oob)
RF_OOB_TP <- myModels$RF$confusion[[1]]
RF_OOB_TN <- myModels$RF$confusion[[4]]


myClassTesting_OOB <- rbind.fill(myClassTesting,data.frame(classifier = "RF_OOB",
									true_positives = RF_OOB_TN,
									true_negatives = RF_OOB_TN,
									Accuracy = round(oob_acc,3)))

myClassTesting_OOB[nrow(myClassTesting_OOB),ncol(myClassTesting_OOB)] <- round(auc_oob,3)

# source("C:\\Users\\Administrator\\Documents\\myGit_R\\Code\\bot_vs_human\\decisionTable_functions.R")


myTraining_dat2 <- dplyr::mutate_at(training_data, 
			.vars = vars(isBot), ~ as.factor(.)) %>%
		dplyr::select(rate,
				  sd_inter_click,
				  duration,
				  mean_inter_click,
				  clicks_per_session,
				  isBot)



svm_allPred_linear <- svm(isBot ~ ., 
		data = myTraining_dat2, 
		kernel = "linear",
		probability = TRUE,
		type = "C-classification")

# radial kernel (RBF)
svm_allPred_rbf <- svm(isBot ~ ., 
		data = myTraining_dat2,
		kernel = "radial",
		probability = TRUE,
		type = "C-classification")

# polynomial kernel
svm_allPred_poly2 <- svm(isBot ~ ., 
		data = myTraining_dat2, 
		kernel = "polynomial", 
		degree = 2,
		probability = TRUE,
		type = "C-classification")

svm_allPred_poly3 <- svm(isBot ~ ., 
		data = myTraining_dat2,
		kernel = "polynomial", 
		degree = 3,
		probability = TRUE,
		type = "C-classification")


### data does not need to be standardized for random forests
rf_model2 = randomForest(factor(isBot) ~ rate + sd_inter_click, 
		data = myTraining_dat2, 
		type = c("class","prob"))


# save all models - could combine with myModels
myModelsRound2 <- list()
myModelsRound2$svm <- list()
myModelsRound2$svm$linear <- svm_allPred_linear
myModelsRound2$svm$rfb <- svm_allPred_linear
myModelsRound2$svm$poly2 <- svm_allPred_linear
myModelsRound2$svm$poly3 <- svm_allPred_linear
myModelsRound2$RF <- rf_model2
#save(myModelsRound2, file = "~/myGit_R/Data/svmRF_models_comparison.RData")
test_data_ML1 <- test_data
#save(test_data_ML1,myClassTesting_OOB, file = "~/myGit_R/Data/testData_ml_class_1.RData")

