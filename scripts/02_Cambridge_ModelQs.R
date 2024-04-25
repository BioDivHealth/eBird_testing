# Testing questions - getting correct answers for question answering
# For comparison with output of cambridgeshire models
# Elise Gallois, elise.gallois94@gmail.com
# 25th April 2024

# 1. Load libraries -----
library(tidyverse)

# 2. Load data and save as RData for future use ----

#cambridghe_ebird <- read_csv("data/cambridgeshire_sample.csv")
#save(cambridghe_ebird, file = "data/cambridghe_ebird.RData")
load("data/cambridghe_ebird.RData")
cambridge_ebird <- cambridghe_ebird
View(cambridge_ebird)

# 3. Data retrieval questions ----
#What is the total count of birds observed in cambridgeshire?
names(cambridge_ebird)[names(cambridge_ebird) == "OBSERVATION COUNT"] <- "obs"
cambridge_ebird$obs <- as.numeric(cambridge_ebird$obs)
sum(cambridge_ebird$obs, na.rm = TRUE) # 110542

# Provide the average duration of observer effort per survey in cambridgeshire.
names(cambridge_ebird)[names(cambridge_ebird) == "SAMPLING EVENT IDENTIFIER"] <- "survey"
cambridge_ebird$survey <- as.factor(cambridge_ebird$survey)
names(cambridge_ebird)[names(cambridge_ebird) == "DURATION MINUTES"] <- "duration"
mean(cambridge_ebird$duration, na.rm = TRUE) #104.7272

# How many surveys were conducted at Grafham Water?
sum(grepl("Grafham Water", cambridge_ebird$LOCALITY, ignore.case = TRUE))

# How many unique bird species have been observed at Smithy Fen.
sum(grepl("Smithy Fen", cambridge_ebird$LOCALITY, ignore.case = TRUE))
names(cambridge_ebird)[names(cambridge_ebird) == "COMMON NAME"] <- "common_name"
smithy_data <- cambridge_ebird[grepl("Smithy Fen", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
unique_species <- unique(smithy_data$common_name)
unique_species

# What is the total count of Bearded Reedling observed in cambridgeshire?
cambridge_ebird$common_name <- as.factor(cambridge_ebird$common_name)
sum(cambridge_ebird$obs[cambridge_ebird$common_name == 'Bearded Reedling'], na.rm = TRUE)

# How many surveys recorded sightings of the Western Marsh Harrier in cambridgeshire?
marsh_harrier_surveys <- unique(cambridge_ebird$survey[cambridge_ebird$common_name == "Western Marsh Harrier"])
length(marsh_harrier_surveys) # 162

# What is the average number of bird species observed per survey at Wicken Fen NNR?
wicken_data <- cambridge_ebird[grepl("Wicken Fen NNR", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
unique_common_names_per_survey <- aggregate(common_name ~ survey, data = wicken_data, FUN = function(x) length(unique(x)))
mean(unique_common_names_per_survey$common_name)

# Provide the total count of Black Headed Gull observed at Roswell Pits
black_headed_gull_obs <- cambridge_ebird[cambridge_ebird$common_name == "Black-headed Gull" & grepl("Roswell Pits", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
sum(black_headed_gull_obs$obs, na.rm = TRUE)

# How many observations were recorded at Cambridge Botanic Garden?
botanic_data <- cambridge_ebird[grepl("Cambridge Botanic Garden", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
nrow(botanic_data)

#List all the exotic bird species.
names(cambridge_ebird)[names(cambridge_ebird) == "EXOTIC CODE"] <- "exotic"
exotic_data <- cambridge_ebird[!is.na(cambridge_ebird$exotic), ]
nrow(exotic_data)

# Which is the least common bird observed?
obs_per_common_name <- aggregate(obs ~ common_name, data = cambridge_ebird, FUN = sum)
lowest_obs_common_name <- obs_per_common_name[which.min(obs_per_common_name$obs), "common_name"]
lowest_obs_common_name_df <- data.frame(common_name = lowest_obs_common_name)

# Which is the most common bird observed?
obs_per_common_name <- aggregate(obs ~ common_name, data = cambridge_ebird, FUN = sum)
highest_obs_common_name <- obs_per_common_name[which.max(obs_per_common_name$obs), "common_name"]
highest_obs_common_name_df <- data.frame(common_name = highest_obs_common_name)

# What are the 3 most common birds at Coe Fen?
coe_data <- cambridge_ebird[grepl("Coe Fen", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
obs_per_common_name <- aggregate(obs ~ common_name, data = coe_data, FUN = sum)
sorted_obs_per_common_name <- obs_per_common_name[order(-obs_per_common_name$obs), ]
head(sorted_obs_per_common_name$common_name, 3)

# What are the 3 most common birds in cambridgeshire?
obs_per_common_name <- aggregate(obs ~ common_name, data = cambridge_ebird, FUN = sum)
sorted_obs_per_common_name <- obs_per_common_name[order(-obs_per_common_name$obs), ]
head(sorted_obs_per_common_name$common_name, 3)

# Rank the top 10 most common bird species observed at Grantchester Meadows.
grantchester_data <- cambridge_ebird[grepl("Grantchester Meadows", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
obs_per_common_name <- aggregate(obs ~ common_name, data = grantchester_data, FUN = sum)
sorted_obs_per_common_name <- obs_per_common_name[order(-obs_per_common_name$obs), ]
head(sorted_obs_per_common_name$common_name, 10)

# What is the total count of Carrion Crows observed in cambridgeshire?
carrion_crow_data <- cambridge_ebird[cambridge_ebird$common_name == "Carrion Crow", ]
total_obs_carrion_crow <- sum(carrion_crow_data$obs, na.rm = TRUE)

# What is the average number of bird species observed per survey at Grafham Water?
grafham_data <- cambridge_ebird[grepl("Grafham Water", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
unique_species_per_survey <- aggregate(common_name ~ survey, data = grafham_data, FUN = function(x) length(unique(x)))
mean(unique_species_per_survey$common_name)

# Provide the total count of Arctic Tern observed at Fen Drayton Lakes RSPB Reserve.
manx_shearwater_drayton_data <- cambridge_ebird[cambridge_ebird$common_name == "Arctic Tern" & grepl("Fen Drayton", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
total_obs_manx_shearwater_drayton <- sum(manx_shearwater_drayton_data$obs, na.rm = TRUE)
total_obs_manx_shearwater_drayton

# How many surveys were conducted on 5th May?
names(cambridge_ebird)[names(cambridge_ebird) == "OBSERVATION DATE"] <- "date"
cambridge_ebird$date <- as.Date(cambridge_ebird$date, format = "%d/%m/%Y")
may_5_data <- cambridge_ebird[format(cambridge_ebird$date, "%m-%d") == "05-05", ]
length(unique(may_5_data$survey))

# How many observations were conducted on 5th May?
sum(may_5_data$obs, na.rm = TRUE)
length(unique(may_5_data$common_name))

# How many exotic species were there at Grafham Water
grafham_data <- cambridge_ebird[grepl("Grafham Water", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
exotic_data <- grafham_data[!is.na(grafham_data$exotic), ]
nrow(exotic_data)

# What is the total count of birds observed at Dernford Reservoir in the first week of May 2023?
cambridge_ebird$date <- as.Date(cambridge_ebird$date, format = "%d/%m/%Y")
dernford_data <- cambridge_ebird[grepl("Dernford Researvoir", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                      cambridge_ebird$date >= as.Date("2023-05-01") & 
                                      cambridge_ebird$date <= as.Date("2023-05-07"), ]
sum(dernford_data$obs, na.rm = TRUE)

# Provide the average duration of observer effort per survey at Paradise LNR
paradise_data <- cambridge_ebird[grepl("Paradise LNR", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
observer_effort_per_survey <- aggregate(duration ~ survey, data = paradise_data, FUN = sum)
mean(paradise_data$duration, na.rm = TRUE)

# How many surveys conducted at Paradise LNR included Coal tit?
paradise_data <- cambridge_ebird[grepl("Paradise LNR", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
fieldfare_surveys_paradise <- unique(paradise_data$survey[paradise_data$common_name == "Mallard"])
length(fieldfare_surveys_paradise)

# List all the bird species observed at Grantchester meadows before 5pm on May 20th 2022.
# Convert the date column to Date format
cambridge_ebird$date <- as.Date(cambridge_ebird$date, format = "%d/%m/%Y")

names(cambridge_ebird)[names(cambridge_ebird) == "TIME OBSERVATIONS STARTED"] <- "time"
cambridge_ebird$timeA <- as.POSIXct(cambridge_ebird$time, format = "%H:%M:%S")
cambridge_ebird$timeB <- format(cambridge_ebird$timeA, "%H:%M:%S")

grantchester_data <- cambridge_ebird[grepl("Grantchester Meadows", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                           cambridge_ebird$date == as.Date("2022-05-20") & 
                                       as.POSIXct(cambridge_ebird$timeB, format="%H:%M:%S") < as.POSIXct("17:00:00", format="%H:%M:%S"), ]
grantchester_data

# What is the least common bird species observed?
# Aggregate data by common_name and calculate the total number of observations for each species
obs_per_species <- aggregate(obs ~ common_name, data = grafham_data, FUN = sum)
least_common_species <- obs_per_species[which.min(obs_per_species$obs), "common_name"]
least_common_species

# Where was the most northerly sighting of the Barn Owl?
smew_data <- cambridge_ebird[cambridge_ebird$common_name == "Barn Owl", ]
most_northerly_smew <- smew_data[which.max(smew_data$LATITUDE), ]
print(most_northerly_smew)

# What is the average number of bird species observed per survey at Grafham during May 2023?
stiffkey_fen_may_2022_data <- cambridge_ebird[grepl("Grafham Water", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                              format(cambridge_ebird$date, "%Y-%m") == "2023-05", ]
unique_species_per_survey <- aggregate(common_name ~ survey, data = stiffkey_fen_may_2022_data, FUN = function(x) length(unique(x)))
mean(unique_species_per_survey$common_name)

# What was the median duration effort?
median(cambridge_ebird$duration, na.rm = TRUE)

# Which location has the highest number of individual observers?
# Aggregate data by location and count the number of unique observers
names(cambridge_ebird)[names(cambridge_ebird) == "OBSERVER ID"] <- "observer"
observers_per_location <- aggregate(observer ~ LOCALITY, data = cambridge_ebird, FUN = function(x) length(unique(x)))
location_max_observers <- observers_per_location[which.max(observers_per_location$observer), "locality"]

# Which bird is most often seen stationary?
names(cambridge_ebird)[names(cambridge_ebird) == "PROTOCOL TYPE"] <- "protocol"
stationary_data <- cambridge_ebird[cambridge_ebird$protocol == "Stationary", ]
stationary_counts <- table(stationary_data$common_name)
most_stationary_bird <- names(stationary_counts)[which.max(stationary_counts)]
most_stationary_bird

# 4. Easy inference questions -----

# Where are Common Buzzards more abundant, at Grafham Water or at Smithy Fen?
g_common_buzzard <- cambridge_ebird[grepl("Grafham Water", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                               grepl("Common Buzzard", cambridge_ebird$common_name, ignore.case = TRUE), ]

total_obs_g <- sum(g_common_buzzard$obs, na.rm = TRUE)

s_common_buzzard <- cambridge_ebird[grepl("Smithy Fen", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                                  grepl("Common Buzzard", cambridge_ebird$common_name, ignore.case = TRUE), ]
total_obs_s <- sum(s_common_buzzard$obs, na.rm = TRUE)

# Compare the observation counts
if (total_obs_s > total_obs_g) {
  print("Buzzards are more abundant at Smithy")
} else if (total_obs_s < total_obs_g) {
  print("Buzzards are more abundant at Grafham.")
} else {
  print("Buzzardsare equally abundant at Smithy Fen and Grafham Water.")
}

# Which species are never spotted at Grantchester?
all_species <- unique(cambridge_ebird$common_name)
grant_course_data <- cambridge_ebird[cambridge_ebird$LOCALITY == "Grantchester Meadows", ]
species_at_grant <- unique(grant_course_data$common_name)
species_never_spotted <- setdiff(all_species, species_at_grant)
print(species_never_spotted)

# Group data by survey
survey_groups <- split(cambridge_ebird, cambridge_ebird$survey)

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
survey_groups <- split(wicken_data, wicken_data$survey)

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

# Which bird species can only be seen before 8 am at Fen Drayton?
drayton_data <- cambridge_ebird[cambridge_ebird$LOCALITY == "Fen Drayton Lakes RSPB Reserve", ignore.case = TRUE]

# Extract the time information from the "TIME" column (assuming it's in HH:MM:SS format)
drayton_data$time <- as.POSIXct(drayton_data$time, format = "%H:%M:%S")

## Extract the hour information from the "TIME" column
drayton_data$hour <- hour(drayton_data$time)

# Filter rows observed before 8 am
before_8am_data <- drayton_data[drayton_data$hour < 8, ]
after_2pm_data <- drayton_data[drayton_data$hour > 14, ]


# Get unique species observed before 8 am
species_before_8am <- unique(as.character(before_8am_data$common_name))
species_before_8am
species_after_2pm <- unique(as.character(after_2pm_data$common_name))
species_after_2pm

# Get unique species observed before 8 am
species_before_8am <- unique(as.character(before_8am_data$common_name))

# Get unique species observed after 2 pm
species_after_2pm <- unique(as.character(after_2pm_data$common_name))

# Species that can only be seen before 8 am
species_only_before <- setdiff(species_before_8am, species_after_2pm)

# Species that can only be seen after 2 pm
species_only_after <- setdiff(species_after_2pm, species_before_8am)

# Print species
species_only_before
species_only_after




# What is the third most abundant bird species at Smithy Fen?
species_counts <- aggregate(obs ~ common_name, data = smithy_data, FUN = sum)
sorted_species <- species_counts[order(-species_counts$obs), ]
third_most_abundant_species <- sorted_species$common_name[3]
print(third_most_abundant_species)

# Which bird species are only observed once at Emmanuel College?
emma_data <- cambridge_ebird[cambridge_ebird$LOCALITY == "Emmanuel College, Cambridge", ignore.case = TRUE]
species_counts <- table(emma_data$common_name)
only_observed_species <- names(species_counts)[species_counts == 1]
print(only_observed_species)

# Where are Barnacle Goose more likely to be observed, at Smithy Fen or at Grafham Water?
smithy_fen_common_buzzard <- cambridge_ebird[grepl("Smithy Fen", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                               grepl("Mallard", cambridge_ebird$common_name, ignore.case = TRUE), ]

total_obs_smithy_fen <- sum(smithy_fen_common_buzzard$obs, na.rm = TRUE)

grafham_common_buzzard <- cambridge_ebird[grepl("Grafham Water", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                                  grepl("Mallard", cambridge_ebird$common_name, ignore.case = TRUE), ]
total_obs_grafham <- sum(grafham_common_buzzard$obs, na.rm = TRUE)

# Compare the observation counts
if (total_obs_smithy_fen > total_obs_grafham) {
  print("Barnacle Goose are more abundant at Smithy Fen.")
} else if (total_obs_smithy_fen < total_obs_grafham) {
  print("Barnacle Goose are more abundant at Grafham.")
} else {
  print("Barnacle Goose are equally abundant at Smithy Fen and Grafham..")
}

# Which bird species is most likely to be observed in a stationary position at Titchwell Marsh? 
smithy_data <- cambridge_ebird[grepl("Smithy Fen", cambridge_ebird$LOCALITY, ignore.case = TRUE), ]
stationary_counts <- table(smithy_data$common_name[smithy_data$protocol == "Stationary"])
most_stationary_species <- names(stationary_counts)[which.max(stationary_counts)]
print(most_stationary_species)

# Where are Black-bellied Plovers more abundant, at Grafham Water or at Roswell Pits?
# Filter the dataset for observations of Black-bellied Plovers at Stiffkey Fen
grafham_data <- cambridge_ebird[grepl("Grafham Water", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                 grepl("Common Chiffchaff", cambridge_ebird$common_name, ignore.case = TRUE), ]
roswell_data <- cambridge_ebird[grepl("Roswell Pits", cambridge_ebird$LOCALITY, ignore.case = TRUE) & 
                                    grepl("Common Chiffchaff", cambridge_ebird$common_name, ignore.case = TRUE), ]
grafham_data <- nrow(grafham_data)
roswell_data <- nrow(roswell_data)

if (stiffkey_count > holme_dunes_count) {
  print("Black-bellied Plovers are more abundant at Stiffkey Fen.")
} else if (stiffkey_count < holme_dunes_count) {
  print("Black-bellied Plovers are more abundant at Holme Dunes.")
} else {
  print("Black-bellied Plovers are equally abundant at both locations.")
}

# At which locality am I most likely to see a Ruddy Shelduck?
ruddy_shelduck_data <- cambridge_ebird %>%
  filter(common_name == "Ruddy Shelduck")

# Count the occurrences of Ruddy Shelducks in each locality
# Count the occurrences of Ruddy Shelducks in each locality
locality_counts <- ruddy_shelduck_data %>%
  group_by(LOCALITY) %>%
  summarise(observation_count = n())

# Identify the locality with the highest frequency of Ruddy Shelduck sightings
most_likely_locality <- locality_counts %>%
  filter(observation_count == max(observation_count)) %>%
  pull(LOCALITY)

# Print the result
print(most_likely_locality)

# Count the occurrences of Ruddy Shelducks in each locality
locality_counts <- ruddy_shelduck_data %>%
  group_by(LOCALITY) %>%
  summarise(
    observation_count = n(),
    distinct_sightings = n_distinct(date)
  )

# Identify the locality with the highest frequency of Ruddy Shelduck sightings
most_likely_locality_observation <- locality_counts %>%
  filter(observation_count == max(observation_count)) %>%
  pull(LOCALITY)

# Identify the locality with the greatest number of unique distinct sightings
most_likely_locality_sightings <- locality_counts %>%
  filter(distinct_sightings == max(distinct_sightings)) %>%
  pull(LOCALITY)

# Print the results
print(most_likely_locality_observation)
print(most_likely_locality_sightings)
# Which five species are always observed together at Titchwell Marsh?
survey_groups <- split(emma_data, emma_data$survey)

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

# Which bird species can only be seen after 5 pm at Holme Dunes?
observations_after_5pm <- drayton_data %>%
  filter(hour(time) >= 20)

# Identify the unique bird species observed after 5 pm
species_after_5pm <- unique(observations_after_5pm$common_name)

# Print the result
print(species_after_5pm)

# Are higher numbers of birds observed in the morning or in the afternoon?
cambridge_ebird$hour <- hour(cambridge_ebird$time)

# Aggregate observations by hour
observations_by_hour <- cambridge_ebird %>%
  filter(!is.na(hour)) %>% 
  group_by(hour) %>%
  summarise(total_obs = sum(obs, na.rm = TRUE))

# Divide the day into morning (before noon) and afternoon (noon onwards)
morning_obs <- sum(observations_by_hour$total_obs[observations_by_hour$hour < 12])
afternoon_obs <- sum(observations_by_hour$total_obs[observations_by_hour$hour >= 12])

# Print the results
if (morning_obs > afternoon_obs) {
  print("Higher numbers of birds are observed in the morning.")
} else if (morning_obs < afternoon_obs) {
  print("Higher numbers of birds are observed in the afternoon.")
} else {
  print("Equal numbers of birds are observed in the morning and afternoon.")
}


# Are more bird species observed in the morning or in the afternoon?
# Filter out rows where hour is NA
filtered_data <- cambridge_ebird %>%
  filter(!is.na(time))

# Extract the hour from the time column
filtered_data$hour <- hour(filtered_data$hour)

# Aggregate observations by hour and count unique bird species observed
observations_by_hour <- filtered_data %>%
  group_by(hour) %>%
  summarise(unique_species_count = n_distinct(common_name))

# Divide the day into morning (before noon) and afternoon (noon onwards)
morning_species_count <- sum(observations_by_hour$unique_species_count[observations_by_hour$hour < 12])
afternoon_species_count <- sum(observations_by_hour$unique_species_count[observations_by_hour$hour >= 12])

# Print the results
if (morning_species_count > afternoon_species_count) {
  print("More bird species are observed in the morning.")
} else if (morning_species_count < afternoon_species_count) {
  print("More bird species are observed in the afternoon.")
} else {
  print("Equal number of bird species are observed in the morning and afternoon.")
}

# What is the second rarest bird species at Coe Fen?
coe_data <- cambridge_ebird %>%
  filter(LOCALITY == "Coe Fen")

# Count observations for each bird species
species_obs_counts <- coe_data %>%
  group_by(common_name) %>%
  summarise(obs_count = sum(obs, na.rm = TRUE)) %>%
  arrange(obs_count)

# Select the second rarest bird species
second_rarest_species <- species_obs_counts$common_name[2]

# Print the result
print(second_rarest_species)

# Where are Gray Herons more likely to be observed, at Holme Dunes or at Whitlingham Country Park?

coe_h_data <- coe_data %>%
  filter(common_name == "Gray Heron")

wicken_h_data <- wicken_data %>%
  filter(common_name == "Gray Heron")

# Count the observations at each location
coe_count <- nrow(coe_h_data)
wick_count <- nrow(wicken_h_data)
coe_count
wick_count

# Compare the counts
if (holme_dunes_count > whitlingham_count) {
  print("Gray Herons are more likely to be observed at Holme Dunes.")
} else if (holme_dunes_count < whitlingham_count) {
  print("Gray Herons are more likely to be observed at Whitlingham Country Park.")
} else {
  print("Gray Herons are equally likely to be observed at both locations.")
}

# Which observer has the highest count of Marsh Harrier observations?
marsh_harrier_data <- cambridge_ebird %>%
  filter(common_name == "Western Marsh Harrier")

# Group the data by observer and count the number of observations for each observer
observer_counts <- marsh_harrier_data %>%
  group_by(observer) %>%
  summarise(observation_count = n())

# Find the observer with the highest count of Marsh Harrier observations
top_observer <- observer_counts %>%
  filter(observation_count == max(observation_count)) %>%
  pull(observer)

# Print the result
print(top_observer)

# Are Gray Herons more likely to be seen alongside Black-headed Gulls or Eurasian Wrens?
# Count the total number of observations for Gray Herons
total_gray_heron_obs <- sum(cambridge_ebird$common_name == "Gray Heron", na.rm = TRUE)

# Count the number of surveys containing Gray Herons
gray_heron_surveys <- unique(cambridge_ebird$urvey[cambridge_ebird$common_name == "Gray Heron"])

# Group the data by survey and count the number of surveys where both Gray Herons and Black-headed Gulls are observed
surveys_with_both_black_headed_gull <- cambridge_ebird %>%
  group_by(survey) %>%
  filter(any(common_name == "Gray Heron") & any(common_name == "Common Chiffchaff")) %>%
  summarise(count = n())

# Group the data by survey and count the number of surveys where both Gray Herons and Eurasian Wrens are observed
surveys_with_both_eurasian_wren <- cambridge_ebird %>%
  group_by(survey) %>%
  filter(any(common_name == "Gray Heron") & any(common_name == "Mallard")) %>%
  summarise(count = n())

# Calculate the proportions
proportion_with_black_headed_gull <- nrow(surveys_with_both_black_headed_gull) / nrow(gray_heron_surveys)
proportion_with_eurasian_wren <- nrow(surveys_with_both_eurasian_wren) / nrow(gray_heron_surveys)

# Output the proportions
proportion_with_black_headed_gull
proportion_with_eurasian_wren


# Filter data for Gray Herons, Black-headed Gulls, and Eurasian Wrens
gray_heron_data <- cambridge_ebird %>%
  filter(common_name == "Gray Heron")

black_headed_gull_data <- cambridge_ebird %>%
  filter(common_name == "Black-headed Gull")

eurasian_wren_data <- cambridge_ebird %>%
  filter(common_name == "Eurasian Wren")

# Count the number of surveys containing Gray Herons and Black-headed Gulls
cooccur_gull <- sum(gray_heron_data$survey %in% black_headed_gull_data$survey)
cooccur_gull
# Count the number of surveys containing Gray Herons and Eurasian Wrens
cooccur_wren <- sum(gray_heron_data$survey %in% eurasian_wren_data$survey)
cooccur_wren
# Print the results
if (cooccur_gull > cooccur_wren) {
  print("Gray Herons are more likely to be seen in the same surveys as Black-headed Gulls.")
} else if (cooccur_wren > cooccur_gull) {
  print("Gray Herons are more likely to be seen in the same surveys as Eurasian Wrens.")
} else {
  print("Gray Herons are equally likely to be seen in the same surveys as Black-headed Gulls and Eurasian Wrens.")
}


# At which location are Gray Herons and Black-headed gulls most commonly seen together?
# Filter the data for Gray Herons and Black-headed Gulls
heron_gull_data <- cambridge_ebird %>%
  filter(common_name %in% c("Gray Heron", "Black-headed Gull"))

# Group the filtered data by location and count the observations
heron_gull_counts <- heron_gull_data %>%
  group_by(LOCALITY) %>%
  summarise(total_obs = n())

# Find the location with the highest count of co-occurrences
most_common_location <- heron_gull_counts %>%
  filter(total_obs == max(total_obs))

# Print the result
most_common_location

# Which two species are most commonly observed together at Grantchester?
# Group data by survey
survey_groups <- split(grant_course_data, grant_course_data$survey)

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

# Find the pair with the lowes frequency
least_likely_pair <- names(pair_counts)[which.min(pair_counts)]

# Print the result
print(least_likely_pair)

# Which location has the least temporally consistent data?
# Calculate standard deviation of observation dates for each location
temporal_consistency <- cambridge_ebird %>%
  group_by(LOCALITY) %>%
  summarise(std_dev_date = sd(time, na.rm = TRUE))

# Find the location with the highest standard deviation, indicating least temporal consistency
least_consistent_location <- temporal_consistency %>%
  filter(std_dev_date == max(std_dev_date))

# Print the least consistent location
least_consistent_location

# What is the the latin name and total observation count of the most abundant bird species at Wicken Fen?

# Group the data by common_name and calculate the total observations for each species
species_obs_counts <- aggregate(obs ~ common_name, data = wicken_data, FUN = sum, na.rm = TRUE)

# Find the species with the highest total observations
most_abundant_species <- species_obs_counts[which.max(species_obs_counts$obs), "common_name"]

# Filter the data for the most abundant species at Holme Dunes
species_data <- wicken_data[wicken_data$common_name == most_abundant_species, ]

# Calculate the total observation count for the most abundant species
total_obs_count <- sum(species_data$obs, na.rm = TRUE)

# Print the result
total_obs_count

# Which bird species is usually observed earliest every day at Titchwell Marsh?
# Convert observation times to POSIXct format
#titchwell_marsh_data$observation_time <- as.POSIXct(titchwell_data$observation_time, format = "%H:%M:%S")

# Extract the hour of the day from observation times
smithy_data$hour <- format(smithy_data$time, "%H")

# Group the data by date and find the bird species observed earliest each day
earliest_species <- smithy_data %>%
  group_by(as.factor(date)) %>%
  slice(which.min(hour)) %>%
  select(common_name) 

# Find the most frequently observed earliest species
most_frequent_earliest_species <- names(sort(table(earliest_species$common_name), decreasing = TRUE))[1]

# Print the result
most_frequent_earliest_species



# Where are Charadrius hiaticulas more likely to be observed, at Stiffkey Fen or at Holme Dunes?
# Filter the dataset for observations of Common Ringed Plovers at Stiffkey Fen
library(stringr)
# Filter the dataset for observations of Common Ringed Plovers at localities containing "Stiffkey Fen"
grafham_common_ringed_plovers <- cambridge_ebird %>%
  filter(str_detect(LOCALITY, "Grafham Water") & common_name == "Mallard")

# Filter the dataset for observations of Common Ringed Plovers at localities containing "Holme Dunes"
roswell_common_ringed_plovers <- cambridge_ebird %>%
  filter(str_detect(LOCALITY, "Roswell Pits") & common_name == "Mallard")

# Calculate the total number of observations for Common Ringed Plovers at each location
grafham_common_ringed_plovers <- nrow(grafham_common_ringed_plovers)
roswell_common_ringed_plovers <- nrow(roswell_common_ringed_plovers)
grafham_common_ringed_plovers
roswell_common_ringed_plovers
# Compare the total number of observations to determine where Common Ringed Plovers are more likely to be observed
if (total_obs_stiffkey_fen > total_obs_holme_dunes) {
  message("Common Ringed Plovers are more likely to be observed at localities containing 'Stiffkey Fen'.")
} else if (total_obs_stiffkey_fen < total_obs_holme_dunes) {
  message("Common Ringed Plovers are more likely to be observed at localities containing 'Holme Dunes'.")
} else {
  message("Common Ringed Plovers are equally likely to be observed at localities containing 'Stiffkey Fen' and 'Holme Dunes'.")
}

# Filter data for Garganeys
garganey_data <- cambridge_ebird %>%
  filter(common_name == "Garganey")

# Calculate the average count of Garganeys per observation
average_garganey_count <- mean(garganey_data$obs, na.rm = TRUE)

# Print the result
print(average_garganey_count)


# List all unique species
all_species <- unique(cambridge_ebird$common_name)

# List species reported at Cambridge Botanic Garden
reported_species <- cambridge_ebird %>%
  filter(LOCALITY == "Cambridge Botanic Garden") %>%
  pull(common_name)

# Find species not reported at Cambridge Botanic Garden
not_reported_species <- setdiff(all_species, reported_species)

# Print the result
print(not_reported_species)

# 5. Hard inference questions ----

# Which species are rarely observed but have been spotted in high numbers when seen?
# Calculate the total number of observations for each species
total_obs_per_species <- cambridge_ebird %>%
  group_by(common_name) %>%
  summarise(total_obs = sum(obs, na.rm = TRUE)) %>%
  arrange(total_obs)

# Calculate the total number of sightings for each species
total_sightings_per_species <- cambridge_ebird %>%
  group_by(common_name) %>%
  summarise(total_sightings = n_distinct(survey)) %>%
  arrange(total_sightings)

# Join the two datasets
species_obs_summary <- inner_join(total_obs_per_species, total_sightings_per_species, by = "common_name")

# Calculate the average number of observations per sighting for each species
species_obs_summary <- species_obs_summary %>%
  mutate(avg_obs_per_sighting = total_obs / total_sightings) %>%
  arrange(avg_obs_per_sighting)

# Find species with low overall observation counts and high average observation counts
rare_high_obs_species <- species_obs_summary %>%
  filter(total_obs < median(total_obs) & avg_obs_per_sighting > median(avg_obs_per_sighting))

# View the result
print(rare_high_obs_species)


# Which species are more commonly observed but have been spotted in low numbers when seen?
# Calculate the total number of observations for each species
total_obs_per_species <- cambridge_ebird %>%
  group_by(common_name) %>%
  summarise(total_obs = sum(obs, na.rm = TRUE)) %>%
  arrange(desc(total_obs))

# Calculate the total number of sightings for each species
total_sightings_per_species <- cambridge_ebird %>%
  group_by(common_name) %>%
  summarise(total_sightings = n_distinct(survey)) %>%
  arrange(desc(total_sightings))

# Join the two datasets
species_obs_summary <- inner_join(total_obs_per_species, total_sightings_per_species, by = "common_name")

# Calculate the average number of observations per sighting for each species
species_obs_summary <- species_obs_summary %>%
  mutate(avg_obs_per_sighting = total_obs / total_sightings) %>%
  arrange(avg_obs_per_sighting)

# Find species with high overall observation counts and low average observation counts
common_low_obs_species <- species_obs_summary %>%
  filter(total_obs > median(total_obs) & avg_obs_per_sighting < median(avg_obs_per_sighting))

# View the result
print(common_low_obs_species)

# What is the average number of Garganeys spotted per observation?
# Filter the data for the Garganey species
garganey_data <- cambridge_ebird %>%
  filter(common_name == "Garganey")

# Calculate the total number of observations for Garganey
total_obs <- sum(garganey_data$obs, na.rm = TRUE)

# Calculate the total number of sightings for Garganey
total_sightings <- n_distinct(garganey_data$survey)

# Calculate the average number of observations per sighting for Garganey
avg_obs_per_sighting <- total_obs / total_sightings

# Print the result
print(avg_obs_per_sighting)

# Was any breeding activity observed at Fen Drayton?
names(drayton_data)[names(drayton_data) == "BREEDING CODE"] <- "breeding_code"
names(drayton_data)[names(drayton_data) == "BREEDING CATEGORY"] <- "breeding_category"

# Filter further to include observations with breeding activity
breeding_activity_obs <- drayton_data[!is.na(drayton_data$breeding_code) | !is.na(drayton_data$breeding_category), ]

# Check if any observations with breeding activity were found
if (nrow(breeding_activity_obs) > 0) {
  print("Breeding activity was observed at fen drayton.")
} else {
  print("No breeding activity was observed at fen drayton.")
}


# Count the number of occurrences
breeding_activity_count <- nrow(breeding_activity_obs)

# Print the result
print(breeding_activity_count)

# Count occurrences of each bird species
species_counts <- table(breeding_activity_obs$common_name)

# Find the species with the highest count
most_common_species <- names(which.max(species_counts))

# Print the result
print(most_common_species)

# Examine hunting behaviours
names(cambridge_ebird)[names(cambridge_ebird) == "SPECIES COMMENTS"] <- "species_comments"
predatory_obs <- cambridge_ebird[grep("(hunt|hunting)", cambridge_ebird$species_comments, ignore.case = TRUE), ]

# Print the filtered observations
print(predatory_obs)

# Which bird species are exclusively seen in the northwest of cambridgeshire?
# Find the minimum and maximum latitude and longitude values in the dataset
min_longitude <- min(cambridge_ebird$LONGITUDE, na.rm = TRUE)
max_longitude <- max(cambridge_ebird$LONGITUDE, na.rm = TRUE)
min_latitude <- min(cambridge_ebird$LATITUDE, na.rm = TRUE)
max_latitude <- max(cambridge_ebird$LATITUDE, na.rm = TRUE)

# Calculate the northwest bounds based on the maximum and minimum values
northwest_bounds <- list(
  min_longitude = min_longitude,
  max_longitude = (min_longitude + max_longitude) / 2,  # Adjust as needed
  min_latitude = (min_latitude + max_latitude) / 2,  # Adjust as needed
  max_latitude = max_latitude
)

# Filter the cambridge_ebird dataset based on the calculated boundaries
northwest_data <- cambridge_ebird[
  cambridge_ebird$LONGITUDE >= northwest_bounds$min_longitude &
    cambridge_ebird$LONGITUDE <= northwest_bounds$max_longitude &
    cambridge_ebird$LATITUDE >= northwest_bounds$min_latitude &
    cambridge_ebird$LATITUDE <= northwest_bounds$max_latitude,
]

# Identify bird species observed in the northwest
northwest_species <- unique(northwest_data$common_name)

# Identify bird species observed in other regions
other_species <- unique(cambridge_ebird$common_name[!cambridge_ebird$common_name %in% northwest_species])

# Identify bird species exclusive to the northwest
exclusive_species <- setdiff(northwest_species, other_species)

# Print or further analyze the exclusive bird species
print(exclusive_species)

# Filter dataset for observations in the northwest region
northwest_data <- cambridge_ebird[
  cambridge_ebird$LONGITUDE >= northwest_bounds$min_longitude &
    cambridge_ebird$LONGITUDE <= northwest_bounds$max_longitude &
    cambridge_ebird$LATITUDE >= northwest_bounds$min_latitude &
    cambridge_ebird$LATITUDE <= northwest_bounds$max_latitude,
]

# Identify bird species observed exclusively in the northwest
northwest_species <- unique(northwest_data$common_name)

# Filter dataset to exclude observations from the northwest region
non_northwest_data <- cambridge_ebird[
  !(cambridge_ebird$LONGITUDE >= northwest_bounds$min_longitude &
      cambridge_ebird$LONGITUDE <= northwest_bounds$max_longitude &
      cambridge_ebird$LATITUDE >= northwest_bounds$min_latitude &
      cambridge_ebird$LATITUDE <= northwest_bounds$max_latitude),
]

# Identify bird species observed outside the northwest region
non_northwest_species <- unique(non_northwest_data$common_name)

# Find bird species exclusive to the northwest region
exclusive_northwest_species <- setdiff(northwest_species, non_northwest_species)

# Print or further analyze exclusive northwest species
print(exclusive_northwest_species)

# Which is the southernmost species of plover?

# Filter for plover species
plover_data <- cambridge_ebird %>%
  filter(grepl("Plover", common_name, ignore.case = TRUE))

# Identify the southernmost species
southernmost_plover <- plover_data %>%
  filter(LATITUDE == min(LATITUDE, na.rm = TRUE))

# Output the result
southernmost_plover$common_name

# Which species are always solitary?

# Group the data by common name and count the unique observation counts
species_counts <- cambridge_ebird %>%
  group_by(common_name) %>%
  summarise(unique_obs_counts = n_distinct(obs))

# Filter for species with only one unique observation count
solitary_species <- species_counts %>%
  filter(unique_obs_counts == 1)

# Output the result
solitary_species$common_name

# At which location are the largest groups of the same bird species observed?
grouped_data <- cambridge_ebird %>%
  group_by(common_name, LOCALITY) %>%
  # group_by(LOCALITY) %>%
  summarise(group_size = obs)

# Find the location with the largest group size
largest_group <- grouped_data %>%
  arrange(desc(group_size)) %>%
  slice(1)

# Extract the location with the largest group size
largest_location <- largest_group$LOCALITY

# Which is the location with the highest diversity of birds?
location_diversity <- cambridge_ebird %>%
  group_by(LOCALITY) %>%
  summarise(unique_species_count = n_distinct(common_name))

# Find the location with the highest diversity of birds
most_diverse_location <- location_diversity %>%
  arrange(desc(unique_species_count)) %>%
  slice(1)

# Extract the location with the highest diversity
most_diverse_location_name <- most_diverse_location$LOCALITY
most_diverse_species_count <- most_diverse_location$unique_species_count

# Print the result
cat("The location with the highest diversity of birds is", most_diverse_location_name, "with", most_diverse_species_count, "unique species observed.\n")

# Find the location with the lowest diversity of birds
least_diverse_location <- location_diversity %>%
  arrange(unique_species_count) %>%
  slice(1)

# Extract the location with the lowest diversity
least_diverse_location_name <- least_diverse_location$LOCALITY
least_diverse_species_count <- least_diverse_location$unique_species_count

# Print the result
cat("The location with the lowest diversity of birds is", least_diverse_location_name, "with", least_diverse_species_count, "unique species observed.\n")

# Which birds have been seen on cloudy days?
names(cambridge_ebird)[names(cambridge_ebird) == "TRIP COMMENTS"] <- "trip_comments"

# Filter the data for rows where trip comments contain "cloud" or "cloudy"
cloudy_data <- paradise_data %>%
  filter(str_detect(trip_comments, "rain") | str_detect(trip_comments, "cloud"))

# Extract unique bird species observed on cloudy days
cloudy_birds <- unique(cloudy_data$common_name)

# Print the list of bird species observed on cloudy days
cat("Bird species observed on cloudy days:\n")
cat(cloudy_birds, sep = ", ")

# Which bird species are exclusively seen in fens?c
# Filter the dataset to include only records from fens
fen_data <- cambridge_ebird %>%
  filter(str_detect(LOCALITY, "Fen")) 

# Count occurrences of each species
species_counts <- table(fen_data$common_name)

# Find the species with the highest count
names(sort(species_counts, decreasing = TRUE))

# Print the most common species
print(most_common_species)

# What species are most commonly reported by group surveys?
names(cambridge_ebird)[names(cambridge_ebird) == "GROUP IDENTIFIER"] <- "group"

# Filter the dataset for group surveys
group_survey_data <- cambridge_ebird[!is.na(cambridge_ebird$group), ]

# Count the occurrences of each species in group surveys
species_counts <- table(group_survey_data$common_name)

# Sort the species counts in descending order
species_counts_sorted <- sort(species_counts, decreasing = TRUE)

# Get the top species (or species tied for the top)
top_species <- names(species_counts_sorted[species_counts_sorted == max(species_counts_sorted)])

# Print the top species
print(top_species)

# Which bird species are most likely to have species notes?
# Filter the dataset for species with non-empty species notes
species_with_notes <- cambridge_ebird[!is.na(cambridge_ebird$species_comments), ]

# Count the occurrences of each species with notes
species_counts <- table(species_with_notes$common_name)

# Sort the species counts in descending order
species_counts_sorted <- sort(species_counts, decreasing = TRUE)

# Get the top species (or species tied for the top)
top_species <- names(species_counts_sorted[species_counts_sorted == max(species_counts_sorted)])

# Print the top species
print(top_species)

# Calculate the total number of species observed per checklist for each observer
observer_species_counts <- aggregate(obs ~ observer, data = cambridge_ebird, FUN = function(x) length(unique(x)))

# Calculate the average number of species observed per checklist for each observer
observer_avg_species <- aggregate(obs ~ observer, data = cambridge_ebird, FUN = function(x) mean(length(unique(x))))

# Find the observer with the highest average number of species per checklist
max_avg_species_observer <- observer_avg_species[which.max(observer_avg_species$obs), ]

# Print the observer with the highest average number of species per checklist
print(max_avg_species_observer)

# What time of day am I most likely to spot a Smew?
# Filter the data for observations of Smew
smew_obs <- cambridge_ebird[cambridge_ebird$common_name == "Mallard", ]

# Extract the hour component from the observation times
#smew_obs$hour <- as.integer(format(smew_obs$observation_time, "%H"))

# Count the frequency of observations for each hour
hourly_counts <- table(smew_obs$hour)

# Find the hour with the highest frequency of observations
most_common_hour <- names(hourly_counts)[which.max(hourly_counts)]

# Print the most common hour for spotting Smew
print(most_common_hour)

# are weekends or weekdays better for spotting birds?
# Convert observation dates to weekdays (Monday = 1, ..., Sunday = 7)
cambridge_ebird$weekday <- weekdays(cambridge_ebird$date)

# Define a function to categorize days as either weekday or weekend
categorize_day <- function(day) {
  if (day %in% c("Saturday", "Sunday")) {
    return("Weekend")
  } else {
    return("Weekday")
  }
}

# Apply the categorize_day function to create a new column indicating weekday or weekend
cambridge_ebird$day_type <- sapply(cambridge_ebird$day_of_week, categorize_day)

# Count the frequency of observations on weekdays and weekends
observation_counts <- table(cambridge_ebird$day_type)

# Print the observation counts
print(observation_counts)

# Calculate the total number of unique species observed on weekdays and weekends
weekday_species <- length(unique(cambridge_ebird$common_name[cambridge_ebird$day_type == "Weekday"]))
weekend_species <- length(unique(cambridge_ebird$common_name[cambridge_ebird$day_type == "Weekend"]))

# Calculate the average number of unique species observed
average_weekday_species <- weekday_species / sum(cambridge_ebird$day_type == "Weekday")
average_weekend_species <- weekend_species / sum(cambridge_ebird$day_type == "Weekend")

# Print the results
print(paste("Average number of unique species observed on weekdays:", average_weekday_species))
print(paste("Average number of unique species observed on weekends:", average_weekend_species))

# Which birds might be overrepresented?
# Calculate the overall proportion of each bird species in the dataset
species_proportion <- prop.table(table(cambridge_ebird$common_name))

# Determine the expected proportion of each species based on their overall frequency
expected_proportion <- mean(species_proportion)

# Calculate the ratio of observed proportion to expected proportion
overrepresentation_ratio <- species_proportion / expected_proportion

# Identify species where the observed proportion is significantly higher than the expected proportion
overrepresented_species <- names(overrepresentation_ratio[overrepresentation_ratio > 1])

# Print the overrepresented species
print(overrepresented_species)
