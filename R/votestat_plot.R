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

area_names <- c(miasto = "urban", wieś = "rural", zagranica = "overseas")
station_names <- c('areszt śledczy' = "jail", 'dom pomocy społecznej' = "nursing facility", stały = 'permanent', 'dom studencki' = "dormitory", 'zakład karny' = "prison", 'zakład leczniczy' = "healthcare center")

# ballots received by area
results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś", "zagranica")) %>%
  ggplot(aes(x = wyborcow_uprawnionych, y = otrzymanych_kart)) +
  geom_point(alpha = 0.5, size = 0.2) +
  geom_abline(linetype = 3, color = "red") +
  labs(x = "registered voters per station", y = "ballots delivered") +
  facet_wrap("typ_obszaru", labeller = labeller(typ_obszaru = area_names))

# ballots received by type
results_station_clean %>%
  filter(typ_obwodu %in% c("areszt śledczy", "dom pomocy społecznej", "stały", "dom studencki", "zakład karny", "zakład leczniczy")) %>%
  ggplot(aes(x = wyborcow_uprawnionych, y = otrzymanych_kart)) +
  geom_point(alpha = 0.5, size = 0.2) +
  geom_abline(linetype = 3) +
  labs(x = "registered voters per station", y = "ballots delivered") +
  facet_wrap("typ_obwodu", nrow = 2, labeller = labeller(typ_obwodu = station_names))

# voting right proof
results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  ggplot(aes(x = wojewodztwo, y = (z_zaswiadczeniem / wydane_karty * 100), fill = typ_obszaru)) +
  stat_summary(geom = "bar", fun = mean, position = "dodge") +
  stat_summary(geom = "hline", fun = mean, aes(x = 1, yintercept = ..y.., color = typ_obszaru), linetype = 4, size = 1) +
  labs(x = "voivodeship", y = "% voters with a proof of voter registration") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = cbPalette[c(3,2)]) +
  scale_color_manual(values = cbPalette[c(3,2)])

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