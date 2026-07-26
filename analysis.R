library(tidyverse)
library(tidytuesdayR)
library(skimr)


nde_experiences <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-07-21/nde_experiences.csv')

nde_experiences

glimpse(nde_experiences)

skim(nde_experiences)

theme_long <- nde_experiences %>%
  select(entry_id, ai_obe, ai_unity, ai_hellish, ai_clinical, 
         ai_esp, ai_past_lives, ai_world_future, ai_aliens) %>%
  pivot_longer(cols = starts_with("ai_"), 
               names_to = "theme", 
               values_to = "present")

head(theme_long, 20)


theme_counts <- theme_long %>%
  group_by(theme) %>%
  summarise(
    n_present = sum(present, na.rm = TRUE),
    total = n(),
    pct = n_present / total * 100
  ) %>%
  arrange(desc(pct))

theme_counts



ggplot(theme_counts, aes(x = reorder(theme, pct), y = pct)) +
  geom_col(fill = "#2c7fb8") +
  coord_flip() +
  labs(
    title = "What themes show up in near death experience narratives",
    subtitle = "Share of 589 reported experiences (NDERF dataset)",
    x = NULL,
    y = "Percent of stories"
  ) +
  theme_minimal(base_size = 13)

ggsave("theme_overall.png", width = 8, height = 6, dpi = 300)



theme_by_gender <- nde_experiences %>%
  select(entry_id, gender, ai_obe, ai_unity, ai_hellish, ai_clinical, 
         ai_esp, ai_past_lives, ai_world_future, ai_aliens) %>%
  pivot_longer(cols = starts_with("ai_"), 
               names_to = "theme", 
               values_to = "present") %>%
  group_by(theme, gender) %>%
  summarise(
    n_present = sum(present, na.rm = TRUE),
    total = n(),
    pct = n_present / total * 100,
    .groups = "drop"
  )



theme_by_gender


ggplot(theme_by_gender, aes(x = reorder(theme, pct), y = pct, fill = gender)) +
  geom_col(position = "dodge") +
  coord_flip() +
  scale_fill_manual(values = c("F" = "#e07a8b", "M" = "#2c7fb8")) +
  labs(
    title = "Near death experience themes by gender",
    subtitle = "Share of stories reporting each theme (NDERF dataset, n = 589)",
    x = NULL,
    y = "Percent of stories",
    fill = "Gender"
  ) +
  theme_minimal(base_size = 13)

ggsave("theme_by_gender.png", width = 8, height = 6, dpi = 300)
