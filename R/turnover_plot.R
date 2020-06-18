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

#turnover wojewodztwa
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

#turnover powiaty
turnover_pow <- results_station_clean %>%
  group_by(powiat) %>%
  summarize(turnover = sum(wydane_karty) / sum(wyborcow_uprawnionych) * 100, .groups = 'drop')

map_powiaty %>%
  left_join(turnover_pow, by = c("nazwa" = "powiat")) %>%
  ggplot() +
    geom_sf(aes(fill = turnover)) +
    geom_sf(data = map_wojewodztwa, size = 0.1, fill = NA, color = "white") +
    scale_fill_viridis(limits = c(46,78), breaks = c(50, 55, 60, 65, 70, 75), name = "turnover / %", option = "E") +
    theme_void() +
    theme(legend.position = "right")

#turnover by area/voivodeship
results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  ggplot(aes(x = wojewodztwo, y = (wydane_karty / wyborcow_uprawnionych * 100), fill = typ_obszaru)) +
    stat_boxplot(outlier.shape = NA) +
    labs(y = "turnover / %", x="voivodeship") +
    scale_fill_discrete(name = "area type", labels = c("urban", "rural")) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

# turnover by %voters in urban areas
turnover_byurbanvoters <- results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  group_by(powiat, typ_obszaru) %>%
  summarize(n_voters = sum(wyborcow_uprawnionych), .groups = 'drop') %>%
  pivot_wider(names_from = typ_obszaru, values_from = n_voters) %>%
  replace_na(list(miasto = 0, wieś = 0)) %>%
  mutate(perc_urban = miasto / (miasto + wieś) * 100) %>%
  left_join(turnover_pow, by = "powiat")

ggplot(turnover_byurbanvoters, aes(x = perc_urban, y = turnover)) +
  geom_point() +
  geom_smooth(formula = (y ~ x), method = 'lm') +
  geom_smooth(data = turnover_byurbanvoters[turnover_byurbanvoters$perc_urban<100, ], formula = (y ~ x), method = 'lm', color = "red") +
  labs(y = "turnover / %", x="voters in urban areas / %") +
  expand_limits(y = c(40,80))

#turnover by powiat density
results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  group_by(powiat) %>%
  summarize(turnover = sum(wydane_karty) / sum(wyborcow_uprawnionych) * 100, n_stations = n(), n_voters = sum(wyborcow_uprawnionych), .groups = 'drop') %>%
  left_join(powiaty_table, by = "powiat") %>%
  mutate(area_perstation = powierzchnia / n_stations) %>%
  ggplot(aes(x = area_perstation, y = turnover)) +
    geom_point() +
    geom_smooth(formula = (y ~ x), method = 'lm') +
    labs(x = "area per station / km2", y = "turnover / %") +
    expand_limits(y = c(40,80))
    
#turnover by gmina density
results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  group_by(gmina) %>%
  summarize(turnover = sum(wydane_karty) / sum(wyborcow_uprawnionych) * 100, n_stations = n(), n_voters = sum(wyborcow_uprawnionych), .groups = 'drop') %>%
  left_join(gminy_table, by = "gmina") %>%
  mutate(area_perstation = powierzchnia / n_stations) %>%
  filter(area_perstation < 20) %>%
  ggplot(aes(x = area_perstation, y = turnover)) +
    geom_point() +
    geom_smooth(formula = (y ~ x), method = 'lm') +
    labs(x = "area per station / km2", y = "turnover / %") +
    expand_limits(y = c(40,80))

#turnover by area/station size/voivodeship
results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  ggplot(aes(x = wyborcow_uprawnionych, y = (wydane_karty / wyborcow_uprawnionych * 100))) +
  stat_density2d(data = results_station_clean[results_station_clean$typ_obszaru == "miasto",], color = "blue", alpha = 0.5) +
  stat_density2d(data = results_station_clean[results_station_clean$typ_obszaru == "wieś",], color = "red", alpha= 0.5) +
  labs(x = "registered voters per station", y = "turnover / %") +
  expand_limits(y = c(0,100)) +
  facet_wrap("wojewodztwo")

## tests
results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  ggplot(aes(x=wojewodztwo, y=(niewykorzystane_karty/otrzymanych_kart), fill = typ_obszaru)) +
  stat_boxplot(outlier.shape = NA) +
  labs(y="% unused ballots", x="voivodeship") +
  coord_flip()

results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  ggplot(aes(y = wojewodztwo, x = wyborcow_uprawnionych, fill = typ_obszaru)) +
  geom_density_ridges(draw_baseline = FALSE, alpha = 0.5) +
  labs(x = "voters per station", y = "voivodeship", fill = "area type") +
  theme(legend.position = "bottom") +
  scale_color_manual(values = cbPalette[c(3,2)])


  
