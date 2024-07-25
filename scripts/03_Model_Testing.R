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

# 4 - Consistency scoring -----
# Stacked bar plot by Q_ID
(stacked_bar_plot <- ggplot(model_testing) +
  aes(x = Q_ID, fill = quality_scoring) +
  geom_bar(position = "fill") +
  scale_fill_manual(
    values = c(Correct = "#36DF48",
               Unsure = "#CDBA22",
               Wrong = "#D94714")
  ) +
  labs(y = "Proportion", x = "Question ID") +
  theme_classic() +
  facet_wrap(vars(model), scales = "free_x") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)))

# Heatmap of consistency
(consistency_heatmap <- ggplot(model_testing) +
  aes(x = Q_ID, y = model, fill = quality_scoring) +
  geom_tile() +
  scale_fill_manual(
    values = c(Correct = "#36DF48",
               Unsure = "#CDBA22",
               Wrong = "#D94714")
  ) +
  labs(y = "Model", x = "Question ID") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)))


# Facet grid of proportions by model and Q_ID
(proportions_grid <- model_testing %>%
  group_by(model, Q_ID) %>%
  count(quality_scoring) %>%
  mutate(proportion = n / sum(n)) %>%
  ggplot() +
  aes(x = Q_ID, y = proportion, fill = quality_scoring) +
  geom_col() +
  scale_fill_manual(
    values = c(Correct = "#36DF48",
               Unsure = "#CDBA22",
               Wrong = "#D94714")
  ) +
  labs(y = "Proportion", x = "Question ID") +
  theme_classic() +
  facet_wrap(vars(model), scales = "free_x") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)))


# Recode the model column to ensure it is ordered correctly for plotting
model_testing$model <- factor(model_testing$model, levels = c('1: No prompt', 
                                                              '2:Prompt: Basic metadata',
                                                              '3: Prompt: Thorough Metadata',
                                                              '4: Prompt: Thorough Metadata with Examples',
                                                              '5: Prompt: Different county',
                                                              '6: Prompt: 4o mini & Wolfram'))

# Calculate proportions for each quality scoring category per model
proportions_time_series <- model_testing %>%
  group_by(model, quality_scoring) %>%
  summarize(count = n()) %>%
  mutate(proportion = count / sum(count))

# Plotting the proportions over time (model versions)
(line_plot <- ggplot(proportions_time_series) +
  aes(x = model, y = proportion, color = quality_scoring, group = quality_scoring) +
  geom_line(size = 1.5) +
  geom_point(size = 3) +
  scale_color_manual(
    values = c(Correct = "#36DF48",
               Unsure = "#CDBA22",
               Wrong = "#D94714")
  ) +
  labs(y = "Proportion", x = "Model Version", title = "Quality Scoring Proportions Over Model Versions") +
  theme_classic() +
 # facet_wrap(vars(as.factor(query_type)), scales = "free_x") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)))

# 5 - Transition matrix ----
# convert quality_scoring to a numeric scale
model_testing <- model_testing %>%
  mutate(score = case_when(
    quality_scoring == "Correct" ~ 2,
    quality_scoring == "Unsure" ~ 1,
    quality_scoring == "Wrong" ~ 0
  ))

# compute changes over model iterations for each Q_ID
model_testing <- model_testing %>%
  group_by(Q_ID) %>%
  arrange(Q_ID, model) %>%
  mutate(change = score - lag(score))

# format the transition matrix
transition_matrix <- model_testing %>%
  filter(!is.na(change)) %>%
  group_by(model, Q_ID) %>%
  summarize(avg_change = mean(change, na.rm = TRUE))

transition_matrix

# Calculate the change in score for each Q_ID between successive models
model_testing <- model_testing %>%
  arrange(Q_ID, model) %>%
  group_by(Q_ID) %>%
  mutate(score_change = score - lag(score)) %>%
  filter(!is.na(score_change))

# Plotting the changes in scores
(change_plot <- ggplot(model_testing, aes(x = model, y = score_change, group = Q_ID, color = as.factor(Q_ID))) +
    geom_line(size = 1) +
    geom_point(size = 2) +
    scale_y_continuous(limits = c(-2, 2), breaks = -2:2, labels = c("Decrease", "No Change", "Increase")) +
    labs(y = "Change in Quality Score", x = "Model Version", title = "Volatility in Quality Scores by Q_ID") +
    theme_classic() +
    theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1)))


