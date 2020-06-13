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
map_wojwodztwa <- readRDS("output/clean/map_wojewodztwa.rds")

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
    stat_density2d(data = results_station_clean[results_station_clean$typ_obszaru == "miasto",], color = "blue") +
    stat_density2d(data = results_station_clean[results_station_clean$typ_obszaru == "wieś",], color = "red") +
    #geom_point(alpha = 0.05, size = 0.1) +
    #geom_smooth(method = "lm", se = FALSE, color = "gray60", size = 0.5) +
    labs(x = "voters per station", y = "turnover") +
    expand_limits(y = c(0,1)) +
    theme_amw() +
    facet_wrap("wojewodztwo")
