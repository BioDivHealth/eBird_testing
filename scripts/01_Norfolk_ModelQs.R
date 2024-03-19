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

# What is the third most abundant bird species at Titchwell Marsh?
species_counts <- aggregate(obs ~ common_name, data = titchwell_data, FUN = sum)
sorted_species <- species_counts[order(-species_counts$obs), ]
third_most_abundant_species <- sorted_species$common_name[3]
print(third_most_abundant_species)

# Which bird species are only observed once at Snettisham RSPB Reserve?
snettisham_data <- norfolk_ebird[norfolk_ebird$LOCALITY == "Snettisham RSPB Reserve", ignore.case = TRUE]
species_counts <- table(snettisham_data$common_name)
only_observed_species <- names(species_counts)[species_counts == 1]
print(only_observed_species)

# Where are Barnacle Goose more likely to be observed, at Stiffkey Fen or at Titchwell Marsh?
stiffkey_fen_common_buzzard <- norfolk_ebird[grepl("Stiffkey Fen", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                               grepl("Barnacle Goose", norfolk_ebird$common_name, ignore.case = TRUE), ]

total_obs_stiffkey_fen <- sum(stiffkey_fen_common_buzzard$obs, na.rm = TRUE)

titchwell_marsh_common_buzzard <- norfolk_ebird[grepl("Titchwell Marsh", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                                  grepl("Barnacle Goose", norfolk_ebird$common_name, ignore.case = TRUE), ]
total_obs_titchwell_marsh <- sum(titchwell_marsh_common_buzzard$obs, na.rm = TRUE)

# Compare the observation counts
if (total_obs_stiffkey_fen > total_obs_titchwell_marsh) {
  print("Barnacle Goose are more abundant at Stiffkey Fen.")
} else if (total_obs_stiffkey_fen < total_obs_titchwell_marsh) {
  print("Barnacle Goose are more abundant at Titchwell Marsh.")
} else {
  print("Barnacle Goose are equally abundant at Stiffkey Fen and Titchwell Marsh.")
}

# Which bird species is most likely to be observed in a stationary position at Titchwell Marsh? 
titchwell_data <- norfolk_ebird[grepl("Titchwell", norfolk_ebird$LOCALITY, ignore.case = TRUE), ]
stationary_counts <- table(titchwell_data$common_name[titchwell_data$protocol == "Stationary"])
most_stationary_species <- names(stationary_counts)[which.max(stationary_counts)]
print(most_stationary_species)

# Where are Black-bellied Plovers more abundant, at Stiffkey Fen or at Holme Dunes?
# Filter the dataset for observations of Black-bellied Plovers at Stiffkey Fen
stiffkey_data <- norfolk_ebird[grepl("Stiffkey Fen", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                 grepl("Black-bellied Plover", norfolk_ebird$common_name, ignore.case = TRUE), ]
holme_dunes_data <- norfolk_ebird[grepl("Holme Dunes", norfolk_ebird$LOCALITY, ignore.case = TRUE) & 
                                 grepl("Black-bellied Plover", norfolk_ebird$common_name, ignore.case = TRUE), ]
stiffkey_count <- nrow(stiffkey_data)
holme_dunes_count <- nrow(holme_dunes_data)

if (stiffkey_count > holme_dunes_count) {
  print("Black-bellied Plovers are more abundant at Stiffkey Fen.")
} else if (stiffkey_count < holme_dunes_count) {
  print("Black-bellied Plovers are more abundant at Holme Dunes.")
} else {
  print("Black-bellied Plovers are equally abundant at both locations.")
}

# At which locality am I most likely to see a Ruddy Shelduck?
ruddy_shelduck_data <- norfolk_ebird %>%
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


# Which five species are always observed together at Titchwell Marsh?
survey_groups <- split(titchwell_data, titchwell_data$survey)

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
observations_after_5pm <- holme_dunes_data %>%
  filter(hour(time) >= 20)

# Identify the unique bird species observed after 5 pm
species_after_5pm <- unique(observations_after_5pm$common_name)

# Print the result
print(species_after_5pm)

# Are higher numbers of birds observed in the morning or in the afternoon?
norfolk_ebird$hour <- hour(norfolk_ebird$time)

# Aggregate observations by hour
observations_by_hour <- norfolk_ebird %>%
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
filtered_data <- norfolk_ebird %>%
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

# What is the second rarest bird species at Whitlingham Country Park?
# Filter the dataset for observations only from Whitlingham Country Park
whitlingham_data <- norfolk_ebird %>%
  filter(LOCALITY == "Whitlingham Country Park")

# Count observations for each bird species
species_obs_counts <- whitlingham_data %>%
  group_by(common_name) %>%
  summarise(obs_count = sum(obs, na.rm = TRUE)) %>%
  arrange(obs_count)

# Select the second rarest bird species
second_rarest_species <- species_obs_counts$common_name[2]

# Print the result
print(second_rarest_species)

# Where are Gray Herons more likely to be observed, at Holme Dunes or at Whitlingham Country Park?

holme_dunes_data <- holme_dunes_data %>%
  filter(common_name == "Gray Heron")

whitlingham_data <- whitlingham_data %>%
  filter(common_name == "Gray Heron")

# Count the observations at each location
holme_dunes_count <- nrow(holme_dunes_data)
whitlingham_count <- nrow(whitlingham_data)

# Compare the counts
if (holme_dunes_count > whitlingham_count) {
  print("Gray Herons are more likely to be observed at Holme Dunes.")
} else if (holme_dunes_count < whitlingham_count) {
  print("Gray Herons are more likely to be observed at Whitlingham Country Park.")
} else {
  print("Gray Herons are equally likely to be observed at both locations.")
}

# Which observer has the highest count of Marsh Harrier observations?
marsh_harrier_data <- norfolk_ebird %>%
  filter(common_name == "Western Marsh Harrier")

# Group the data by observer and count the number of observations for each observer
observer_counts <- marsh_harrier_data %>%
  group_by(observer) %>%
  summarise(observation_count = n())

# Find the observer with the highest count of Marsh Harrier observations
top_observer <- observer_counts %>%
  filter(observation_count == min(observation_count)) %>%
  pull(observer)

# Print the result
print(top_observer)

# Are Gray Herons more likely to be seen alongside Black-headed Gulls or Eurasian Wrens?
# Count the total number of observations for Gray Herons
total_gray_heron_obs <- sum(norfolk_ebird$common_name == "Gray Heron", na.rm = TRUE)

# Count the number of surveys containing Gray Herons
gray_heron_surveys <- unique(norfolk_ebird$urvey[norfolk_ebird$common_name == "Gray Heron"])

# Group the data by survey and count the number of surveys where both Gray Herons and Black-headed Gulls are observed
surveys_with_both_black_headed_gull <- norfolk_ebird %>%
  group_by(survey) %>%
  filter(any(common_name == "Gray Heron") & any(common_name == "Black-headed Gull")) %>%
  summarise(count = n())

# Group the data by survey and count the number of surveys where both Gray Herons and Eurasian Wrens are observed
surveys_with_both_eurasian_wren <- norfolk_ebird %>%
  group_by(survey) %>%
  filter(any(common_name == "Gray Heron") & any(common_name == "Eurasian Wren")) %>%
  summarise(count = n())

# Calculate the proportions
proportion_with_black_headed_gull <- nrow(surveys_with_both_black_headed_gull) / nrow(surveys_with_gray_heron)
proportion_with_eurasian_wren <- nrow(surveys_with_both_eurasian_wren) / nrow(surveys_with_gray_heron)

# Output the proportions
proportion_with_black_headed_gull
proportion_with_eurasian_wren

# At which location are Gray Herons and Black-headed gulls most commonly seen together?
# Filter the data for Gray Herons and Black-headed Gulls
heron_gull_data <- norfolk_ebird %>%
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

# Which two species are most commonly observed together at Cromer Golf Course?
# Group data by survey
survey_groups <- split(cromer_golf_course_data, cromer_golf_course_data$survey)

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
temporal_consistency <- norfolk_ebird %>%
  group_by(LOCALITY) %>%
  summarise(std_dev_date = sd(time, na.rm = TRUE))

# Find the location with the highest standard deviation, indicating least temporal consistency
least_consistent_location <- temporal_consistency %>%
  filter(std_dev_date == max(std_dev_date))

# Print the least consistent location
least_consistent_location

# What is the the latin name and total observation count of the most abundant bird species at Holme Dunes?

# Group the data by common_name and calculate the total observations for each species
species_obs_counts <- aggregate(obs ~ common_name, data = holme_dunes_data, FUN = sum, na.rm = TRUE)

# Find the species with the highest total observations
most_abundant_species <- species_obs_counts[which.max(species_obs_counts$obs), "common_name"]

# Filter the data for the most abundant species at Holme Dunes
species_data <- holme_dunes_data[holme_dunes_data$common_name == most_abundant_species, ]

# Calculate the total observation count for the most abundant species
total_obs_count <- sum(species_data$obs, na.rm = TRUE)

# Print the result
total_obs_count

# Which bird species is usually observed earliest every day at Titchwell Marsh?
# Convert observation times to POSIXct format
#titchwell_marsh_data$observation_time <- as.POSIXct(titchwell_data$observation_time, format = "%H:%M:%S")

# Extract the hour of the day from observation times
titchwell_data$hour <- format(titchwell_data$time, "%H")

# Group the data by date and find the bird species observed earliest each day
earliest_species <- titchwell_data %>%
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
stiffkey_fen_common_ringed_plovers <- norfolk_ebird %>%
  filter(str_detect(LOCALITY, "Stiffkey Fen") & common_name == "Common Ringed Plover")

# Filter the dataset for observations of Common Ringed Plovers at localities containing "Holme Dunes"
holme_dunes_common_ringed_plovers <- norfolk_ebird %>%
  filter(str_detect(LOCALITY, "Holme Dunes") & common_name == "Common Ringed Plover")

# Calculate the total number of observations for Common Ringed Plovers at each location
total_obs_stiffkey_fen <- nrow(stiffkey_fen_common_ringed_plovers)
total_obs_holme_dunes <- nrow(holme_dunes_common_ringed_plovers)

# Compare the total number of observations to determine where Common Ringed Plovers are more likely to be observed
if (total_obs_stiffkey_fen > total_obs_holme_dunes) {
  message("Common Ringed Plovers are more likely to be observed at localities containing 'Stiffkey Fen'.")
} else if (total_obs_stiffkey_fen < total_obs_holme_dunes) {
  message("Common Ringed Plovers are more likely to be observed at localities containing 'Holme Dunes'.")
} else {
  message("Common Ringed Plovers are equally likely to be observed at localities containing 'Stiffkey Fen' and 'Holme Dunes'.")
}

# 5. Hard inference questions ----

# Which species are rarely observed but have been spotted in high numbers when seen?
# Calculate the total number of observations for each species
total_obs_per_species <- norfolk_ebird %>%
  group_by(common_name) %>%
  summarise(total_obs = sum(obs, na.rm = TRUE)) %>%
  arrange(total_obs)

# Calculate the total number of sightings for each species
total_sightings_per_species <- norfolk_ebird %>%
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
total_obs_per_species <- norfolk_ebird %>%
  group_by(common_name) %>%
  summarise(total_obs = sum(obs, na.rm = TRUE)) %>%
  arrange(desc(total_obs))

# Calculate the total number of sightings for each species
total_sightings_per_species <- norfolk_ebird %>%
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
garganey_data <- norfolk_ebird %>%
  filter(common_name == "Garganey")

# Calculate the total number of observations for Garganey
total_obs <- sum(garganey_data$obs, na.rm = TRUE)

# Calculate the total number of sightings for Garganey
total_sightings <- n_distinct(garganey_data$survey)

# Calculate the average number of observations per sighting for Garganey
avg_obs_per_sighting <- total_obs / total_sightings

# Print the result
print(avg_obs_per_sighting)

# Was any breeding activity observed at Titchwell Marsh?
names(titchwell_data)[names(titchwell_data) == "BREEDING CODE"] <- "breeding_code"
names(titchwell_data)[names(titchwell_data) == "BREEDING CATEGORY"] <- "breeding_category"

# Filter further to include observations with breeding activity
breeding_activity_obs <- titchwell_data[!is.na(titchwell_data$breeding_code) | !is.na(titchwell_data$breeding_category), ]

# Check if any observations with breeding activity were found
if (nrow(breeding_activity_obs) > 0) {
  print("Breeding activity was observed at Titchwell Marsh.")
} else {
  print("No breeding activity was observed at Titchwell Marsh.")
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
names(norfolk_ebird)[names(norfolk_ebird) == "SPECIES COMMENTS"] <- "species_comments"
predatory_obs <- norfolk_ebird[grep("(hunt|hunting)", norfolk_ebird$species_comments, ignore.case = TRUE), ]

# Print the filtered observations
print(predatory_obs)

# Which bird species are exclusively seen in the northwest of Norfolk?
# Find the minimum and maximum latitude and longitude values in the dataset
min_longitude <- min(norfolk_ebird$LONGITUDE, na.rm = TRUE)
max_longitude <- max(norfolk_ebird$LONGITUDE, na.rm = TRUE)
min_latitude <- min(norfolk_ebird$LATITUDE, na.rm = TRUE)
max_latitude <- max(norfolk_ebird$LATITUDE, na.rm = TRUE)

# Calculate the northwest bounds based on the maximum and minimum values
northwest_bounds <- list(
  min_longitude = min_longitude,
  max_longitude = (min_longitude + max_longitude) / 2,  # Adjust as needed
  min_latitude = (min_latitude + max_latitude) / 2,  # Adjust as needed
  max_latitude = max_latitude
)

# Filter the norfolk_ebird dataset based on the calculated boundaries
northwest_data <- norfolk_ebird[
  norfolk_ebird$LONGITUDE >= northwest_bounds$min_longitude &
    norfolk_ebird$LONGITUDE <= northwest_bounds$max_longitude &
    norfolk_ebird$LATITUDE >= northwest_bounds$min_latitude &
    norfolk_ebird$LATITUDE <= northwest_bounds$max_latitude,
]

# Identify bird species observed in the northwest
northwest_species <- unique(northwest_data$common_name)

# Identify bird species observed in other regions
other_species <- unique(norfolk_ebird$common_name[!norfolk_ebird$common_name %in% northwest_species])

# Identify bird species exclusive to the northwest
exclusive_species <- setdiff(northwest_species, other_species)

# Print or further analyze the exclusive bird species
print(exclusive_species)

# Filter dataset for observations in the northwest region
northwest_data <- norfolk_ebird[
  norfolk_ebird$LONGITUDE >= northwest_bounds$min_longitude &
    norfolk_ebird$LONGITUDE <= northwest_bounds$max_longitude &
    norfolk_ebird$LATITUDE >= northwest_bounds$min_latitude &
    norfolk_ebird$LATITUDE <= northwest_bounds$max_latitude,
]

# Identify bird species observed exclusively in the northwest
northwest_species <- unique(northwest_data$common_name)

# Filter dataset to exclude observations from the northwest region
non_northwest_data <- norfolk_ebird[
  !(norfolk_ebird$LONGITUDE >= northwest_bounds$min_longitude &
      norfolk_ebird$LONGITUDE <= northwest_bounds$max_longitude &
      norfolk_ebird$LATITUDE >= northwest_bounds$min_latitude &
      norfolk_ebird$LATITUDE <= northwest_bounds$max_latitude),
]

# Identify bird species observed outside the northwest region
non_northwest_species <- unique(non_northwest_data$common_name)

# Find bird species exclusive to the northwest region
exclusive_northwest_species <- setdiff(northwest_species, non_northwest_species)

# Print or further analyze exclusive northwest species
print(exclusive_northwest_species)

# Which is the southernmost species of plover?

# Filter for plover species
plover_data <- norfolk_ebird %>%
  filter(grepl("Plover", common_name, ignore.case = TRUE))

# Identify the southernmost species
southernmost_plover <- plover_data %>%
  filter(LATITUDE == min(LATITUDE, na.rm = TRUE))

# Output the result
southernmost_plover$common_name

# Which species are always solitary?

# Group the data by common name and count the unique observation counts
species_counts <- norfolk_ebird %>%
  group_by(common_name) %>%
  summarise(unique_obs_counts = n_distinct(obs))

# Filter for species with only one unique observation count
solitary_species <- species_counts %>%
  filter(unique_obs_counts == 1)

# Output the result
solitary_species$common_name

# At which location are the largest groups of the same bird species observed?
grouped_data <- norfolk_ebird %>%
  group_by(common_name) %>%
  group_by(LOCALITY) %>%
  summarise(group_size = n())

# Find the location with the largest group size
largest_group <- grouped_data %>%
  arrange(desc(group_size)) %>%
  slice(1)

# Extract the location with the largest group size
largest_location <- largest_group$LOCALITY

# Which is the location with the highest diversity of birds?
location_diversity <- norfolk_ebird %>%
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












