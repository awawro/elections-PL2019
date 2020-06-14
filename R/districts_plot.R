library(tidyverse)
library(ggridges)
library(viridis)
library(sf)

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

results_station_clean <- readRDS("output/clean/results_station_clean.rds")
results_candidate_clean <- readRDS("output/clean/results_candidate_clean.rds")
results_slate_clean <- readRDS("output/clean/results_slate_clean.rds")
results_candidate_full <- readRDS("output/clean/results_candidate_full.rds")
map_powiaty <- readRDS("output/clean/map_powiaty.rds")
map_wojewodztwa <- readRDS("output/clean/map_wojewodztwa.rds")

#turnover wojewodztwa
turnover_woj <- results_station_clean %>%
  group_by(wojewodztwo) %>%
  summarize(turnover = sum(wydane_karty) / sum(wyborcow_uprawnionych) * 100)

map_wojewodztwa %>%
  left_join(turnover_woj, by = c("nazwa" = "wojewodztwo")) %>%
  ggplot() +
    geom_sf(aes(fill = turnover)) +
    scale_fill_viridis(limits = c(45,80))

#turnover powiaty
turnover_pow <- results_station_clean %>%
  group_by(powiat) %>%
  summarize(turnover = sum(wydane_karty) / sum(wyborcow_uprawnionych) * 100)


map_powiaty %>%
  left_join(turnover_pow, by = c("nazwa" = "powiat")) %>%
  ggplot() +
  geom_sf(aes(fill = turnover)) +
  scale_fill_viridis(limits = c(45,80))


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

results_station_clean %>%
  filter(typ_obszaru %in% c("miasto", "wieś")) %>%
  ggplot(aes(x = wyborcow_uprawnionych, y = (wydane_karty / wyborcow_uprawnionych))) +
    stat_density2d(data = results_station_clean[results_station_clean$typ_obszaru == "miasto",], color = "blue", alpha = 0.5) +
    stat_density2d(data = results_station_clean[results_station_clean$typ_obszaru == "wieś",], color = "red", alpha= 0.5) +
    labs(x = "voters per station", y = "turnover") +
    expand_limits(y = c(0,1)) +
    #theme_bw() +
    facet_wrap("wojewodztwo")
