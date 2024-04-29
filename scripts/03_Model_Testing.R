# Initial comparison of three different models with iterative improvements
# Elise Gallois, elise.gallois94@gmail.com
# 29th April 2024 
# :)


# 1. Load libraries -----
library(tidyverse)
library(esquisse) 
library(viridis)

# 2. Load data  ----
model_testing <- read_csv("data/model_testing.csv")

# 3. Plot comparisons ----

# 1 - Simple truth breakdown 
ggplot(model_testing) +
  aes(x = quality_scoring, fill = quality_scoring) +
  geom_bar() +
  scale_fill_manual(
    values = c(Correct = "#36DF48",
               Unsure = "#CDBA22",
               Wrong = "#D94714")
  ) +
  theme_classic() +
  facet_wrap(vars(model))

# 2 - By Query Type
ggplot(model_testing) +
  aes(x = quality_scoring, fill = query_type) +
  geom_bar() +
  scale_fill_viridis_d(option = "plasma", direction = 1) +
  theme_classic() +
  facet_wrap(vars(model))

 # 3 - Time-specific
model_testing %>%
  filter(time_spec %in% "S") %>%
  ggplot() +
  aes(x = quality_scoring) +
  geom_bar(fill = "#EBBB06") +
  theme_classic() +
  facet_wrap(vars(model))




