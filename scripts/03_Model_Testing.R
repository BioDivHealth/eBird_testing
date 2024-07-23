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
(basic_comparison <- ggplot(model_testing) +
  aes(x = quality_scoring, fill = quality_scoring) +
  geom_bar() +
  scale_fill_manual(
    values = c(Correct = "#36DF48",
               Unsure = "#CDBA22",
               Wrong = "#D94714")
  ) +
  theme_classic() +
  facet_wrap(vars(model)))

# 2 - By Query Type
# Define the new order and names for the levels
model_testing$model <- recode(model_testing$model, matrix_only = '1: No prompt', 
                        metadata_added = '2:Prompt: Basic metadata',
                        metadata_prompt = '3: Prompt: Thorough Metadata',
                        metadata_prompt_certain = '4: Prompt: Thorough Metadata with Examples',
                        CAMB_metadata_prompt_certain = '5: Prompt: Different county',
                        `4o_wolfram_prompt` = '6: Prompt: 4o mini & Wolfram')


ggplot(model_testing) +
  aes(x = quality_scoring, fill = query_type) +
  geom_bar() +
  labs(x = "Quality Scoring",
       y = "Count",
       legend_title = "Query Type") +
  scale_fill_viridis_d(option = "plasma", direction = 1) +
  theme_classic() +
  facet_wrap(vars(model), scales='free')

# 3 - Time-specific
model_testing %>%
  filter(time_spec %in% "S") %>%
  ggplot() +
  aes(x = quality_scoring) +
  geom_bar(fill = "#EBBB06") +
  theme_classic() +
  facet_wrap(vars(model))



