# Testing questions - getting correct answers for habitat question answering
# Elise Gallois, elise.gallois94@gmail.com
# 28th mAY 2024

# 1. Load libraries -----
library(tidyverse)

# 2. Load data and save as RData for future use ----

# norfolk_ebird <- read_csv("~/Downloads/norfolk_ebird.csv") # too large for github
# save(norfolk_ebird, file = "data/norfolk_birds.RData")
load("data/norfolk_birds.RData")
View(norfolk_ebird) # "SCIENTIFIC NAME" has latin name

# load habitat data
habitat <- read_csv("data/habitat_both.csv")
View(habitat) # "Species" column has latin name

# change column name in ebird data
norfolk_ebird$Species <-  norfolk_ebird$`SCIENTIFIC NAME`

# filter only for birds
birds_habitat <- habitat %>%
  filter(group == "aves") %>% 
  filter(Suitable == "Suitable")

# left join on ebird and habitat data
norfolk_habitat <- left_join(norfolk_ebird,birds_habitat)

# Aggregate habitat data to ensure one record per species
# Here we concatenate habitat types into a single string per species
aggregated_habitat <- birds_habitat %>%
  group_by(Species) %>%
  summarize(HabitatTypes = paste(unique(Level_2_Habitat_Class), collapse = ", "))


aggregated_habitat <- birds_habitat %>%
  group_by(Species) %>%
  summarize(
    HabitatTypes = paste(unique(Level_1_Habitat_Class), collapse = ", "),
    Seasons = paste(unique(season), collapse = ", ")
  )

# left join on ebird and habitat data
norfolk_habitat <- left_join(norfolk_ebird, aggregated_habitat, by = "Species")


