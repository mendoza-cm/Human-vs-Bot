rm(list=ls())
library(tidyverse)
library(gridExtra)

# Assuming helper functions are in this directory
source("./helperFunctions_simulateCases.R")
humanInitialize <- human_startTimes(cases = 400) %>%
			human_timesdistributionDF() %>%
			data.frame() %>%
			dplyr::arrange(id,session_id,time) 
	
botInitialize <- bot_startTimes(cases = 400)%>%
			bot_timesdistributionDF()%>%
			data.frame() %>%
			dplyr::arrange(id,session_id,time) 




data <- data.frame(rbind(humanInitialize,botInitialize)) %>%
		dplyr::group_by(id,session_id,type) %>% ## using type just incase a human and bot have the same info - unlikely, but impossible?
		dplyr::mutate(responses_per_session = n(),
				  duration = as.numeric(difftime(last(time), first(time), units = "secs")),
				  rate = responses_per_session/duration, 
				  rate_10min = responses_per_session * 600 / duration,
				  inter_response = as.numeric(difftime(time, lag(time), units = "secs")))%>% 
		ungroup() %>%
		data.frame()


# in real data, do not expect the total number of responses - needed for simulating data, but not kept
# rate_10min --> responsess per 10 minutes
data_for_modeling <- data %>%
	dplyr::arrange(id,session_id,type) %>% 
	dplyr::group_by(id,session_id,type) %>% 
  		summarise(
    			sd_inter_response = sd(inter_response, na.rm = TRUE),
   			mean_inter_response = mean(inter_response, na.rm = TRUE),
    			responses_per_session = first(responses_per_session),
    			duration = first(duration),
    			rate = first(rate),
    			rate_10min = first(rate_10min),
    			type = first(type),
    			isBot = first(type == "bot"),
    			.groups = "drop"
  			) %>%
	ungroup() %>%
	dplyr::arrange(id,session_id,type) %>% 
	dplyr::group_by(id,session_id) %>%
		dplyr::mutate(uniqueRows = n()) %>%
		ungroup() %>%
	data.frame()

summary(data_for_modeling$uniqueRows)
##### if summary does not reveal 1 across the board - delete rows
data_for_modeling$uniqueRows <- NULL
# summary(data$duration)
# summary(data$responses_per_session)
### so using the above arguments, there should only be 1 start-time per user 

## training data: sample a subset of the data - 70% in train_dataSize below 
train_dataSize <- round((nrow(data_for_modeling)*.7))
training_data_ind <- sample(1:nrow(data_for_modeling),train_dataSize)
training_data <- data_for_modeling[training_data_ind,]

## test_data 
test_data <- data_for_modeling[setdiff(1:nrow(data_for_modeling),training_data_ind),]

p1 <- ggplot(training_data[training_data$isBot == 1, ], aes(x = rate_10min)) +
  geom_histogram(position = "identity", alpha = 0.6, bins = 30, fill = "pink") +
  theme_minimal() +
  labs(title = "Bots", x = "Response Rate (responses/10 min)", y = "Count")

p2 <- ggplot(training_data[training_data$isBot == 0, ], aes(x = rate_10min)) +
  geom_histogram(position = "identity", alpha = 0.6, bins = 30, fill = "darkblue") +
  theme_minimal() +
  labs(title = "Humans", x = "Response Rate (responses/10 min)", y = "Count")


png("./visualizations/response_rate_histograms.png", width = 800, height = 1000)
grid.arrange(p1, p2, ncol = 1)  # Stacked
dev.off()
#################

### read in saved data and change "click" to response
rm(list=ls())
load("./data/human_vs_bot_data.RData")
for(s in ls())
	grep()