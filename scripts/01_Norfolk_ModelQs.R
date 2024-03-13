# Testing questions - getting correct answers for question answering
# Elise Gallois, elise.gallois94@gmail.com
# 11th March 2024

# 1. Load libraries -----
library(tidyverse)

# 2. Load data and save as RData for future use ----

#norfolk_ebird <- read_csv("~/Downloads/norfolk_ebird.csv") # too large for github
#save(norfolk_ebird, file = "data/norfolk_birds.RData")
load("data/norfolk_birds.RData")
View(norfolk_ebird)

# 3. Data retrieval questions ----
#What is the total count of birds observed in Norfolk?
names(norfolk_ebird)[names(norfolk_ebird) == "OBSERVATION COUNT"] <- "obs"
norfolk_ebird$obs <- as.numeric(norfolk_ebird$obs)
sum(norfolk_ebird$obs, na.rm = TRUE) # 1140423

# Provide the average duration of observer effort per survey in Norfolk.
names(norfolk_ebird)[names(norfolk_ebird) == "SAMPLING EVENT IDENTIFIER"] <- "survey"
norfolk_ebird$survey <- as.factor(norfolk_ebird$survey)
names(norfolk_ebird)[names(norfolk_ebird) == "DURATION MINUTES"] <- "duration"
mean(norfolk_ebird$duration, na.rm = TRUE) #115.8326

# How many surveys were conducted at Cley & Salthouse Marshes?
sum(grepl("Cley", norfolk_ebird$LOCALITY, ignore.case = TRUE))

# List all the bird species observed at Titchwell Marsh.
sum(grepl("Titchwell", norfolk_ebird$LOCALITY, ignore.case = TRUE))
names(norfolk_ebird)[names(norfolk_ebird) == "COMMON NAME"] <- "common_name"
titchwell_data <- norfolk_ebird[grepl("Titchwell", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
unique_species <- unique(titchwell_data$common_name)
unique_species

# What is the total count of Bearded Reedling observed in Norfolk?
norfolk_ebird$common_name <- as.factor(norfolk_ebird$common_name)
sum(norfolk_ebird$obs[norfolk_ebird$common_name == 'Bearded Reedling'], na.rm = TRUE)

# How many surveys recorded sightings of the Western Marsh Harrier in Norfolk?
marsh_harrier_surveys <- unique(norfolk_ebird$survey[norfolk_ebird$common_name == "Western Marsh Harrier"])
length(marsh_harrier_surveys) # 1750

# What is the average number of bird species observed per survey at Blakeney?
blakeney_data <- norfolk_ebird[grepl("Blakeney", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
unique_common_names_per_survey <- aggregate(common_name ~ survey, data = blakeney_data, FUN = function(x) length(unique(x)))
mean(unique_common_names_per_survey$common_name)

# Provide the total count of Black Headed Gull observed at NWT Holme Dunes.
black_headed_gull_obs <- norfolk_ebird[norfolk_ebird$common_name == "Black-headed Gull" & grepl("NWT Holme Dunes", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
sum(black_headed_gull_obs$obs, na.rm = TRUE)

#How many observations were recorded at Happisburgh?
happisburgh_data <- norfolk_ebird[grepl("Happisburgh", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
nrow(happisburgh_data)

#List all the exotic bird species.
names(norfolk_ebird)[names(norfolk_ebird) == "EXOTIC CODE"] <- "exotic"
exotic_data <- norfolk_ebird[!is.na(norfolk_ebird$exotic), ]
nrow(exotic_data)

# Which is the least common bird observed?
obs_per_common_name <- aggregate(obs ~ common_name, data = norfolk_ebird, FUN = sum)
lowest_obs_common_name <- obs_per_common_name[which.min(obs_per_common_name$obs), "common_name"]
lowest_obs_common_name_df <- data.frame(common_name = lowest_obs_common_name)

# Which is the most common bird observed?
obs_per_common_name <- aggregate(obs ~ common_name, data = norfolk_ebird, FUN = sum)
highest_obs_common_name <- obs_per_common_name[which.max(obs_per_common_name$obs), "common_name"]
highest_obs_common_name_df <- data.frame(common_name = highest_obs_common_name)

# What are the 3 most common birds at Hardwick Flood Lagoon??
hardwick_data <- norfolk_ebird[grepl("Hardwick Flood Lagoon", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
obs_per_common_name <- aggregate(obs ~ common_name, data = hardwick_data, FUN = sum)
sorted_obs_per_common_name <- obs_per_common_name[order(-obs_per_common_name$obs), ]
head(sorted_obs_per_common_name$common_name, 3)

# What are the 3 most common birds in Norfolk?
obs_per_common_name <- aggregate(obs ~ common_name, data = norfolk_ebird, FUN = sum)
sorted_obs_per_common_name <- obs_per_common_name[order(-obs_per_common_name$obs), ]
head(sorted_obs_per_common_name$common_name, 3)

# Rank the top 10 most common bird species observed at Cromer Golf Course.
golf_data <- norfolk_ebird[grepl("Cromer Golf Course", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
obs_per_common_name <- aggregate(obs ~ common_name, data = golf_data, FUN = sum)
sorted_obs_per_common_name <- obs_per_common_name[order(-obs_per_common_name$obs), ]
head(sorted_obs_per_common_name$common_name, 3)

# What is the total count of Carrion Crows observed in Norfolk?
carrion_crow_data <- norfolk_ebird[norfolk_ebird$common_name == "Carrion Crow", ]
total_obs_carrion_crow <- sum(carrion_crow_data$obs, na.rm = TRUE)

# What is the average number of bird species observed per survey at Stiffkey Fen?
stiffkey_fen_data <- norfolk_ebird[grepl("Stiffkey Fen", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
unique_species_per_survey <- aggregate(common_name ~ survey, data = stiffkey_fen_data, FUN = function(x) length(unique(x)))
mean(unique_species_per_survey$common_name)

# Provide the total count of Manx Shearwaters observed at Sidestrand.
manx_shearwater_blakeney_data <- norfolk_ebird[norfolk_ebird$common_name == "Manx Shearwater" & grepl("Sidestrand", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
total_obs_manx_shearwater_blakeney <- sum(manx_shearwater_blakeney_data$obs, na.rm = TRUE)

# How many surveys were conducted on 5th May?
names(norfolk_ebird)[names(norfolk_ebird) == "OBSERVATION DATE"] <- "date"
norfolk_ebird$date <- as.Date(norfolk_ebird$date, format = "%d/%m/%Y")
may_5_data <- norfolk_ebird[format(norfolk_ebird$date, "%m-%d") == "05-05", ]
length(unique(may_5_data$survey))

# How many observations were conducted on 5th May?
sum(may_5_data$obs, na.rm = TRUE)

# How many unique species were conducted on 5th May?
length(unique(may_5_data$common_name))


# 4. Easy inference questions -----


# 5. Hard inference questions -----