library(tidyverse)
library(ggridges)
library(viridis)
library(sf)
library(XML)
library(httr)

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

results_station_clean <- readRDS("output/clean/results_station_clean.rds")
results_candidate_clean <- readRDS("output/clean/results_candidate_clean.rds")
results_slate_clean <- readRDS("output/clean/results_slate_clean.rds")
results_candidate_full <- readRDS("output/clean/results_candidate_full.rds")
map_powiaty <- readRDS("output/clean/map_powiaty.rds")
map_wojewodztwa <- readRDS("output/clean/map_wojewodztwa.rds")
powiaty_table <- readRDS("output/clean/powiaty_table.rds")

# ballots received
results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś", "zagranica")) %>%
  ggplot(aes(x = wyborcow_uprawnionych, y = otrzymanych_kart)) +
  geom_point(alpha = 0.1) +
  geom_abline(linetype = 3) +
  facet_wrap("typ_obszaru")

results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś", "zagranica")) %>%
  ggplot(aes(x = typ_obszaru, y = (otrzymanych_kart / wyborcow_uprawnionych * 100))) +
    geom_point() +
    labs(y = "y", x="voivodeship") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś", "zagranica")) %>%
  #group_by(typ_obszaru, wojewodztwo) %>%
  mutate(perc_received = otrzymanych_kart / wyborcow_uprawnionych * 100) %>%
  arrange(desc(perc_received))

#test
turnover_woj <- results_station_clean %>%
  group_by(wojewodztwo) %>%
  summarize(turnover = sum(wydane_karty) / sum(wyborcow_uprawnionych) * 100, .groups = 'drop')

map_wojewodztwa %>%
  left_join(turnover_woj, by = c("nazwa" = "wojewodztwo")) %>%
  ggplot() +
  geom_sf(aes(fill = turnover), size = 0.1, color = "white") +
  scale_fill_viridis(limits = c(46,78), breaks = c(50, 55, 60, 65, 70, 75), name = "turnover / %", option = "E") +
  theme_void() +
  theme(legend.position = "right")