

library(rgbif)
library(dplyr)

# Step 1: Load the CSV File
load("data/norfolk_birds.RData")


# Assuming the CSV file has a column named 'species_name'
names(norfolk_ebird)[names(norfolk_ebird) == "SCIENTIFIC NAME"] <- "scientificName"
species_data <- unique(norfolk_ebird$scientificName)  # Keep only unique species names


# Initialize an empty data frame to store results
results <- data.frame(species = character(),
                      longitude = numeric(),
                      latitude = numeric(),
                      stringsAsFactors = FALSE)



# Step 2: Query GBIF API for each species name
query_gbif <- function(species) {
  occ_data <- occ_search(scientificName = species, limit = 10) # Adjust the limit as needed
  if (!is.null(occ_data$data) && nrow(occ_data$data) > 0) {
    coords <- occ_data$data[, c("scientificName", "decimalLongitude", "decimalLatitude")]
    return(coords)
  }
  return(NULL)
}

# run through each species name and query the API
for (species in species_list) {
  coords <- query_gbif(species)
  if (!is.null(coords)) {
    results <- bind_rows(results, coords)
  }
}

# Step 3: Store Results into a new CSV file
write.csv(results, "data/GBIF_results.csv", row.names = FALSE)

print("GBIF coordinates data has been successfully retrieved and saved.")
