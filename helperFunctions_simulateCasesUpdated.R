library(tidyverse)
human_startTimes <- function(cases=10, do_replace = FALSE, min = 3000, max = 100000){
	id <- sample(min:max, size = cases, replace = do_replace)
	session_start_time <- sample(
		as.numeric(as.POSIXct("2024-04-30 01:02:21 UTC")):as.numeric(as.POSIXct("2025-04-30 08:42:14 UTC")), 
		size = cases)
	human_startTimesDF <- data.frame(id = id,session_start_time = session_start_time) %>%
					dplyr::group_by(id, session_start_time) %>%
						dplyr::mutate(session_id = sample(1001:4000000, size = 1, replace = FALSE)) %>%
						ungroup(.) %>%
					data.frame(.) %>%					
					dplyr::mutate(type = "human",
							  session_start_time = as.POSIXct(session_start_time)) 
		return(human_startTimesDF[,c("id","session_id","session_start_time","type")])

}

##
human_timesdistributionDF <- function(human_startTimesDF,timeLimit = 10800, meanResponses = NA){
		randomTimeLimits <- sample(30:timeLimit, size = dim(human_startTimesDF)[1])

		human_TimesDF <- data.frame(human_startTimesDF,randomTimeLimits) %>%
						dplyr::mutate(session_end_time = session_start_time + randomTimeLimits)

		responses_long <- data.frame() 

		for(i in 1:nrow(human_TimesDF)){
		   if(!is.na(meanResponses)){
			times_responded <- abs(rnorm(1,mean=meanResponses,sd=12.5))
			} else if(human_TimesDF[i,"randomTimeLimits"] <= 30){
				times_responded <- abs(rnorm(1,mean=3,sd=0.5))
				} else if(human_TimesDF[i,"randomTimeLimits"] <= 120){
				times_responded <- abs(rnorm(1,mean=15,sd=0.5))
					} else if(human_TimesDF[i,"randomTimeLimits"] <= 1800){
					times_responded <- abs(rnorm(1,mean=50,sd=1))
						} else
 					  times_responded <- abs(rnorm(1,mean=200,sd=25))

			timesToAdd <- abs(rnorm(round(times_responded), mean = 30,  sd = 2.5))
			response_times <- human_TimesDF[i, "session_start_time"] + cumsum(timesToAdd)

			response_times <- response_times[response_times <= human_TimesDF[i, "session_end_time"]]

			#if (length(response_times) < 2) next
                  times_responded <- length(response_times)
			
			temp <- data.frame(
  					id = rep(human_TimesDF[i, "id"], times_responded),
  					session_id = rep(human_TimesDF[i, "session_id"], times_responded),
  					type = rep(human_TimesDF[i, "type"], times_responded),
  					time = response_times)
			start_row <- data.frame(human_TimesDF) %>%
						dplyr::select(id,session_id,type,time = session_start_time)


			responses_long <- dplyr::bind_rows(responses_long,start_row,temp)
		}


		

		
	return(responses_long)
}


###
###




bot_startTimes <- function(cases=10, do_replace = FALSE, min = 3000, max = 100000){
	id <- sample(min:max, size = cases, replace = do_replace)
	session_start_time <- sample(
		as.numeric(as.POSIXct("2024-04-30 01:02:21 UTC")):as.numeric(as.POSIXct("2025-04-30 08:42:14 UTC")), 
		size = cases)
	bot_startTimesDF <- data.frame(id = id,session_start_time = session_start_time) %>%
					dplyr::group_by(id, session_start_time) %>%
						dplyr::mutate(session_id = sample(1001:4000000, size = 1, replace = FALSE)) %>%
						ungroup(.) %>%
					data.frame(.) %>%					
					dplyr::mutate(type = "bot",
							  session_start_time = as.POSIXct(session_start_time)) 
		return(bot_startTimesDF[,c("id","session_id","session_start_time","type")])

}


bot_timesdistributionDF <- function(bot_startTimesDF,timeLimit = 10800, meanResponses = NA){
		randomTimeLimits <- sample(30:timeLimit, size = dim(bot_startTimesDF)[1])
		bot_TimesDF <- data.frame(bot_startTimesDF,randomTimeLimits) %>%
						dplyr::mutate(session_end_time = session_start_time + randomTimeLimits)

		responses_long <- data.frame() 

		for(i in 1:nrow(bot_TimesDF)){
		  if(!is.na(meanResponses)){
			times_responded <- abs(rnorm(1,mean=meanResponses,sd=12.5))

		   } else if(bot_TimesDF[i,"randomTimeLimits"] <= 30){
				times_responded <- abs(rnorm(1,mean=25,sd=1.5))
			} else if(bot_TimesDF[i,"randomTimeLimits"] <= 120){
				times_responded <- abs(rnorm(1,mean=250,sd=10.5))
				} else if(bot_TimesDF[i,"randomTimeLimits"] <= 1800){
					times_responded <- abs(rnorm(1,mean=500,sd=1.5))
					} else
					  times_responded <- abs(rnorm(1,mean=1000,sd=100.5))
			

							
			timesToAdd <- rexp(round(times_responded), 1/10)
			response_times <- bot_TimesDF[i, "session_start_time"] + cumsum(timesToAdd)

			response_times <- response_times[response_times <= bot_TimesDF[i, "session_end_time"]]
			if (length(response_times) < 2) next
                  times_responded <- length(response_times)

			temp <- data.frame(
  					id = rep(bot_TimesDF[i, "id"], times_responded),
  					session_id = rep(bot_TimesDF[i, "session_id"], times_responded),
  					type = rep(bot_TimesDF[i, "type"], times_responded),
  					time = response_times)
			start_row <- data.frame(bot_TimesDF) %>%
						dplyr::select(id,session_id,type,time = session_start_time)


			responses_long <- dplyr::bind_rows(responses_long,start_row,temp)
		}


		

		
	return(responses_long)
}
