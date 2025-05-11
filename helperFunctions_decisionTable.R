predictive_values_function <- function(dat, cuts, class, scores){
	myPredictiveValues <- data.frame()
	for(i in cuts){
		n_aboveCut <- length(which(dat[,scores] > i))
		n_belowCut <- length(which(dat[,scores] <= i))
		
		ppv <- round(length(which(dat[,scores] > i & as.numeric(dat[,class]) == 1))/n_aboveCut,2)
		npv <- round(length(which(dat[,scores] <= i & as.numeric(dat[,class]) == 0))/n_belowCut,2)
		SR <- round(length(which(dat[,scores] > i))/nrow(dat),2)
		

		temp <- data.frame(
		cut_point = i,
		PPV = ppv,
		NPV = npv,
		selection_ratio = SR
		) 

		myPredictiveValues <- dplyr::bind_rows(myPredictiveValues,temp)


		}
	return(myPredictiveValues)

	}


ROC_values_function <- function(dat, cuts, class, scores){
	
	myROC_values <- data.frame()

	n_trueCases <- length(which(as.numeric(dat[,class]) == 1))
	n_falseCases <- length(which(as.numeric(dat[,class]) == 0))
	myROC_values <- data.frame()
	for(i in cuts){
		
		true_positives <- length(which(dat[,scores] > i & as.numeric(dat[,class]) == 1))
		true_positive_rate <- round(true_positives/n_trueCases,2)

		true_negatives <- length(which(dat[,scores] <= i & as.numeric(dat[,class]) == 0))
		true_negative_rate <- round(true_negatives/n_falseCases,2)

		
		false_positive_rate <- 1 - true_negative_rate
		accuracy <- (true_positives + true_negatives)/length(which(!is.na(dat[,scores])))

		temp <- data.frame(
			cut_point = i,
			TPR = true_positive_rate,
			FPR = false_positive_rate,
			accuracy = paste0(round(accuracy,2)*100,"%")
			) 
				

	myROC_values <- dplyr::bind_rows(myROC_values,temp)

		}

	return(myROC_values)

	}
