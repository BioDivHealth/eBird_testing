# Initial comparison of three different models with iterative improvements
# Elise Gallois, elise.gallois94@gmail.com
# 9th April 2024

# 1. Load libraries -----
library(tidyverse)
library(esquisse)

# 2. Load data  ----
model_testing <- read_csv("data/model_testing.csv")

# 3. Plot comparisons ----
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
