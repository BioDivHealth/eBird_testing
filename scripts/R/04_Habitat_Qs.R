
# 1. Load libraries -----
library(tidyverse) 
library(terra)
library(raster)
library(readxl)

# 2. Load data and save as RData for future use ----

# norfolk_ebird <- read_csv("~/Downloads/norfolk_ebird.csv") # too large for github
# save(norfolk_ebird, file = "data/norfolk_birds.RData")
load("data/norfolk_birds.RData")
View(norfolk_ebird) # "SCIENTIFIC NAME" has latin name

# load habitat data (SPECITS)
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


# Specify the path to the IUCN tif file
tif_file <- "/Volumes/T7 Shield/iucn_habitatclassification_composite_lvl2_ver004.tif"

# Open the tif file
habitat_data <- rast(tif_file)

plot(habitat_data)

# clip to UK extent
uk_extent <- extent(-10, 2, 49, 61)  # xmin, xmax, ymin, ymax
uk_clipped <- crop(habitat_data, uk_extent)
plot(uk_clipped)

# save smaller file for easy loading
output_file <- "data/UK_clipped_raster.tif"
writeRaster(uk_clipped, filename = output_file, filetype = "GTiff", overwrite = TRUE)

# 3. Extract habitat types from TIF ----
# bind coords from ebird data
coordinates <- cbind(norfolk_ebird$LONGITUDE, norfolk_ebird$LATITUDE)
points <- vect(coordinates, crs = crs(uk_clipped))

# extract values from uk_clipped IUCN tif
extracted_values <- extract(uk_clipped, points)

# create 'newcode' column within norfolk_ebird so I can later bind these codes to the key
norfolk_habitat$NewCode <- extracted_values[, 2]  

# import key 
iucn_key <- read_excel("data/IUCN_mapping_legend.xlsx")

# Ensure "NewCode" columns are of the same type
norfolk_habitat$NewCode <- as.character(norfolk_habitat$NewCode)
iucn_key$NewCode <- as.character(iucn_key$NewCode)

# Merge norfolk_ebird with iucn_key on "NewCode"
merged_data <- merge(norfolk_habitat, iucn_key, by = "NewCode", all.x = TRUE)

# Rename the "IUCNLevel" column to "Habitat" in the merged dataframe
merged_data <- rename(merged_data, Habitat = IUCNLevel)

# If you want to keep only the necessary columns, you can select them
norfolk_habitat <- merged_data[, c(names(norfolk_habitat), "Habitat")]

# Check the result
head(norfolk_habitat)

# drop species column
norfolk_habitat <- norfolk_habitat %>% dplyr::select(-Species)
norfolk_habitat <- norfolk_habitat %>% dplyr::select(-NewCode)

# rename columns in a bid to help LLM understanding
norfolk_habitat <- norfolk_habitat %>%
  rename(HabitatRange = HabitatTypes,
         ActualHabitat = Habitat)

# Write the dataframe to a CSV file
write.csv(norfolk_habitat, "data/norfolk_habitat.csv", row.names = FALSE)






