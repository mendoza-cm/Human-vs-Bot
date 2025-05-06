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
human_timesdistributionDF <- function(human_startTimesDF,timeLimit = 10800, meanClicks = NA){
		randomTimeLimits <- sample(30:timeLimit, size = dim(human_startTimesDF)[1])

		human_TimesDF <- data.frame(human_startTimesDF,randomTimeLimits) %>%
						dplyr::mutate(session_end_time = session_start_time + randomTimeLimits)

		clicks_long <- data.frame() 

		for(i in 1:nrow(human_TimesDF)){
		   if(!is.na(meanClicks)){
			times_clicked <- abs(rnorm(1,mean=meanClicks,sd=12.5))
			} else if(human_TimesDF[i,"randomTimeLimits"] <= 30){
				times_clicked <- abs(rnorm(1,mean=3,sd=0.5))
				} else if(human_TimesDF[i,"randomTimeLimits"] <= 120){
				times_clicked <- abs(rnorm(1,mean=15,sd=0.5))
					} else if(human_TimesDF[i,"randomTimeLimits"] <= 1800){
					times_clicked <- abs(rnorm(1,mean=50,sd=1))
						} else
 					  times_clicked <- abs(rnorm(1,mean=200,sd=25))

			timesToAdd <- abs(rnorm(round(times_clicked), mean = 30,  sd = 2.5))
			click_times <- human_TimesDF[i, "session_start_time"] + cumsum(timesToAdd)

			click_times <- click_times[click_times <= human_TimesDF[i, "session_end_time"]]

			#if (length(click_times) < 2) next
                  times_clicked <- length(click_times)
			
			temp <- data.frame(
  					id = rep(human_TimesDF[i, "id"], times_clicked),
  					session_id = rep(human_TimesDF[i, "session_id"], times_clicked),
  					type = rep(human_TimesDF[i, "type"], times_clicked),
  					time = click_times)
			start_row <- data.frame(human_TimesDF) %>%
						dplyr::select(id,session_id,type,time = session_start_time)


			clicks_long <- dplyr::bind_rows(clicks_long,start_row,temp)
		}


		

		
	return(clicks_long)
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


bot_timesdistributionDF <- function(bot_startTimesDF,timeLimit = 10800, meanClicks = NA){
		randomTimeLimits <- sample(30:timeLimit, size = dim(bot_startTimesDF)[1])
		bot_TimesDF <- data.frame(bot_startTimesDF,randomTimeLimits) %>%
						dplyr::mutate(session_end_time = session_start_time + randomTimeLimits)

		clicks_long <- data.frame() 

		for(i in 1:nrow(bot_TimesDF)){
		  if(!is.na(meanClicks)){
			times_clicked <- abs(rnorm(1,mean=meanClicks,sd=12.5))

		   } else if(bot_TimesDF[i,"randomTimeLimits"] <= 30){
				times_clicked <- abs(rnorm(1,mean=25,sd=1.5))
			} else if(bot_TimesDF[i,"randomTimeLimits"] <= 120){
				times_clicked <- abs(rnorm(1,mean=250,sd=10.5))
				} else if(bot_TimesDF[i,"randomTimeLimits"] <= 1800){
					times_clicked <- abs(rnorm(1,mean=500,sd=1.5))
					} else
					  times_clicked <- abs(rnorm(1,mean=1000,sd=100.5))
			

							
			timesToAdd <- rexp(round(times_clicked), 1/10)
			click_times <- bot_TimesDF[i, "session_start_time"] + cumsum(timesToAdd)

			click_times <- click_times[click_times <= bot_TimesDF[i, "session_end_time"]]
			if (length(click_times) < 2) next
                  times_clicked <- length(click_times)

			temp <- data.frame(
  					id = rep(bot_TimesDF[i, "id"], times_clicked),
  					session_id = rep(bot_TimesDF[i, "session_id"], times_clicked),
  					type = rep(bot_TimesDF[i, "type"], times_clicked),
  					time = click_times)
			start_row <- data.frame(bot_TimesDF) %>%
						dplyr::select(id,session_id,type,time = session_start_time)


			clicks_long <- dplyr::bind_rows(clicks_long,start_row,temp)
		}


		

		
	return(clicks_long)
}
