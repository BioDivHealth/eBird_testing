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
length(unique(may_5_data$common_name))

# How many exotic species were there at Stiffkey Fen
stiffkey_fen_data <- norfolk_ebird[grepl("Stiffkey Fen", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
exotic_data <- stiffkey_fen_data[!is.na(stiffkey_fen_data$exotic), ]
nrow(exotic_data)

# What is the total count of birds observed at Stiffkey Fen in the first week of May 2023?
norfolk_ebird$date <- as.Date(norfolk_ebird$date, format = "%d/%m/%Y")
stif_may_2023_data <- norfolk_ebird[grepl("Stiffkey Fen", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                        norfolk_ebird$date >= as.Date("2022-05-01") & 
                                        norfolk_ebird$date <= as.Date("2022-05-07"), ]
sum(stif_may_2023_data$obs, na.rm = TRUE)

# Provide the average duration of observer effort per survey at Cringleford Marsh.
cring_data <- norfolk_ebird[grepl("Cringleford Marsh", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
observer_effort_per_survey <- aggregate(duration ~ survey, data = cring_data, FUN = sum)
mean(observer_effort_per_survey$duration)

# How many surveys conducted at Cringleford Marsh included Coal tit?
cring_data <- norfolk_ebird[grepl("Cringleford Marsh", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
fieldfare_surveys_cringleford_marsh <- unique(cring_data$survey[cring_data$common_name == "Coal Tit"])
length(fieldfare_surveys_cringleford_marsh)

# List all the bird species observed at Cromer Golf Course before 5pm on May 5th 2022.
# Convert the date column to Date format
norfolk_ebird$date <- as.Date(norfolk_ebird$date, format = "%d/%m/%Y")

names(norfolk_ebird)[names(norfolk_ebird) == "TIME OBSERVATIONS STARTED"] <- "time"
norfolk_ebird$time <- as.POSIXct(norfolk_ebird$time, format = "%H:%M:%S")
cromer_golf_course_data <- norfolk_ebird[grepl("Cromer Golf Course", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                           norfolk_ebird$date == as.Date("2022-05-05") & 
                                           format(norfolk_ebird$time, "%H:%M") < "17:00", ]

# What is the least common bird species observed?
# Aggregate data by common_name and calculate the total number of observations for each species
obs_per_species <- aggregate(obs ~ common_name, data = stiffkey_fen_data, FUN = sum)
least_common_species <- obs_per_species[which.min(obs_per_species$obs), "common_name"]
least_common_species

# Where was the most northerly sighting of the Smew?
smew_data <- norfolk_ebird[norfolk_ebird$common_name == "Smew", ]
most_northerly_smew <- smew_data[which.max(smew_data$LATITUDE), ]
print(most_northerly_smew)

# What is the average number of bird species observed per survey at Stiffkey Fen during May 2022?
stiffkey_fen_may_2022_data <- norfolk_ebird[grepl("Stiffkey Fen", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                              format(norfolk_ebird$date, "%Y-%m") == "2022-05", ]
unique_species_per_survey <- aggregate(common_name ~ survey, data = stiffkey_fen_may_2022_data, FUN = function(x) length(unique(x)))
mean(unique_species_per_survey$common_name)

# What was the median duration effort?
median(norfolk_ebird$duration, na.rm = TRUE)

# Which location has the highest number of individual observers?
# Aggregate data by location and count the number of unique observers
names(norfolk_ebird)[names(norfolk_ebird) == "OBSERVER ID"] <- "observer"
observers_per_location <- aggregate(observer ~ LOCALITY, data = norfolk_ebird, FUN = function(x) length(unique(x)))
location_max_observers <- observers_per_location[which.max(observers_per_location$observer), "locality"]

# Which bird is most often seen stationary?
names(norfolk_ebird)[names(norfolk_ebird) == "PROTOCOL TYPE"] <- "protocol"
stationary_data <- norfolk_ebird[norfolk_ebird$protocol == "stationary", ]
stationary_counts <- table(stationary_data$common_name)
most_stationary_bird <- names(stationary_counts)[which.max(stationary_counts)]


# 4. Easy inference questions -----

# Where are Common Buzzards more abundant, at Stiffkey Fen or at Titchwell Marsh?
stiffkey_fen_common_buzzard <- norfolk_ebird[grepl("Stiffkey Fen", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                               grepl("Common Buzzard", norfolk_ebird$common_name, ignore.case = TRUE), ]

total_obs_stiffkey_fen <- sum(stiffkey_fen_common_buzzard$obs, na.rm = TRUE)

titchwell_marsh_common_buzzard <- norfolk_ebird[grepl("Titchwell Marsh", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                               grepl("Common Buzzard", norfolk_ebird$common_name, ignore.case = TRUE), ]
total_obs_titchwell_marsh <- sum(titchwell_marsh_common_buzzard$obs, na.rm = TRUE)

# Compare the observation counts
if (total_obs_stiffkey_fen > total_obs_titchwell_marsh) {
  print("Buzzards are more abundant at Stiffkey Fen.")
} else if (total_obs_stiffkey_fen < total_obs_titchwell_marsh) {
  print("Buzzards are more abundant at Titchwell Marsh.")
} else {
  print("Buzzardsare equally abundant at Stiffkey Fen and Titchwell Marsh.")
}

# Which species are never spotted at Cromer Golf Course?
all_species <- unique(norfolk_ebird$common_name)
cromer_golf_course_data <- norfolk_ebird[norfolk_ebird$LOCALITY == "Cromer Golf Course", ]
species_at_cromer <- unique(cromer_golf_course_data$common_name)
species_never_spotted <- setdiff(all_species, species_at_cromer)
print(species_never_spotted)

# Group data by survey
survey_groups <- split(norfolk_ebird, norfolk_ebird$survey)

# Initialize an empty list to store pairs of species observed together
all_pairs <- list()

# Iterate over each survey group
for (survey_data in survey_groups) {
  # Get unique species observed in the survey
  unique_species <- unique(as.character(survey_data$common_name))
  
  # Check if there are enough unique species to form pairs
  if (length(unique_species) >= 2) {
    # Generate pairs of unique species
    pairs <- combn(unique_species, 2, FUN = function(x) paste(sort(x), collapse = " and "))
    
    # Add pairs to the list
    all_pairs <- c(all_pairs, list(pairs))
  }
}

# Combine all pairs into a single vector
all_pairs <- unlist(all_pairs)

# Count the frequency of each pair
pair_counts <- table(all_pairs)

# Find the pair with the highest frequency
most_likely_pair <- names(pair_counts)[which.max(pair_counts)]

# Print the result
print(most_likely_pair)


# Which two species are most likely to be seen together at Stiffkey Fen?
# Group data by survey
survey_groups <- split(stiffkey_fen_data, stiffkey_fen_data$survey)

# Initialize an empty list to store pairs of species observed together
all_pairs <- list()

# Iterate over each survey group
for (survey_data in survey_groups) {
  # Get unique species observed in the survey
  unique_species <- unique(as.character(survey_data$common_name))
  
  # Check if there are enough unique species to form pairs
  if (length(unique_species) >= 2) {
    # Generate pairs of unique species
    pairs <- combn(unique_species, 2, FUN = function(x) paste(sort(x), collapse = " and "))
    
    # Add pairs to the list
    all_pairs <- c(all_pairs, list(pairs))
  }
}

# Combine all pairs into a single vector
all_pairs <- unlist(all_pairs)

# Count the frequency of each pair
pair_counts <- table(all_pairs)

# Find the pair with the highest frequency
most_likely_pair <- names(pair_counts)[which.max(pair_counts)]

# Print the result
print(most_likely_pair)


# Which two species are most likely to be seen together at Stiffkey Fen?
# Group data by survey
survey_groups <- split(cromer_golf_course_data, cromer_golf_course_data$survey)

# Initialize an empty list to store pairs of species observed together
all_pairs <- list()

# Iterate over each survey group
for (survey_data in survey_groups) {
  # Get unique species observed in the survey
  unique_species <- unique(as.character(survey_data$common_name))
  
  # Check if there are enough unique species to form pairs
  if (length(unique_species) >= 3) {
    # Generate pairs of unique species
    pairs <- combn(unique_species, 3, FUN = function(x) paste(sort(x), collapse = " and "))
    
    # Add pairs to the list
    all_pairs <- c(all_pairs, list(pairs))
  }
}

# Combine all pairs into a single vector
all_pairs <- unlist(all_pairs)

# Count the frequency of each pair
pair_counts <- table(all_pairs)

# Find the pair with the highest frequency
most_likely_pair <- names(pair_counts)[which.max(pair_counts)]

# Print the result
print(most_likely_pair)

# Which bird species can only be seen before 8 am at Sidestrand?
sidestrand_data <- norfolk_ebird[norfolk_ebird$LOCALITY == "Sidestrand", ignore.case = TRUE]

# Extract the time information from the "TIME" column (assuming it's in HH:MM:SS format)
sidestrand_data$time <- as.POSIXct(sidestrand_data$time, format = "%H:%M:%S")

## Extract the hour information from the "TIME" column
sidestrand_data$hour <- as.numeric(format(sidestrand_data$time, "%H"))

# Filter rows observed before 8 am
before_8am_data <- sidestrand_data[sidestrand_data$hour < 8, ]
after_2pm_data <- sidestrand_data[sidestrand_data$hour > 14, ]


# Get unique species observed before 8 am
species_before_8am <- unique(as.character(before_8am_data$common_name))
species_before_8am
species_after_2pm <- unique(as.character(after_6pm_data$common_name))
species_after_2pm

# 5. Hard inference questions -----
















