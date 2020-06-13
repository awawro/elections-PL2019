library(tidyverse)
library(sf)

# Read data files into tibbles
districts_raw <- read_delim("input/districts/obwody_glosowania.csv", delim = ";") # not used yet
candidates_raw <- read_delim("input/candidates/kandydaci_sejm.csv", delim = ";")
results_files <- list.files(path = "input/results", pattern = "\\.csv", full.names = TRUE)
results_list_raw <- lapply(results_files, read_delim, delim = ";")

# Read map files into dfs
map_powiaty <- st_read("input/maps/powiaty-medium.geojson")
map_wojwodztwa <- st_read("input/maps/wojewodztwa-medium.geojson")
map_powiaty$nazwa <- str_sub(map_powiaty$nazwa, 8)

### Clean and subset results dataset
# prepare for rbind, stations meta only
results_station_list <- lapply(results_list_raw, '[', 3:32)
results_station_df <- do.call(rbind, results_station_list)
# rename columns
results_station_names <- colnames(results_station_df) # backup col names
colnames(results_station_df) <- c("nr_okregu", "nr_obwodu", "typ_obszaru", "typ_obwodu", "siedziba", "gmina", "powiat", "wojewodztwo",
                                 "otrzymanych_kart", "wyborcow_uprawnionych", "niewykorzystane_karty", "wydane_karty", "przez_pelnomocnika", "z_zaswiadczeniem",
                                 "wyslanych_pakietow", "otrzymanych_zwrotnych", "zwrotne_brak_oswiadczenia", "zwrotne_niepodpisane", "zwrotne_brak_koperty", "zwrotne_niezaklejona",
                                 "zwrotne_wrzucone_do_urny", "wyjetych_z_urny", "wyjetych_z_urny_kopert", "karty_niewazne", "karty_wazne", "glosy_niewazne", "glosy_niewazne_dwa_X",
                                 "glosy_niewazne_brak_X", "glosy_niewazne_X_uniewazniony", "glosy_wazne_lacznie")
# clean data
results_station_clean <- results_station_df %>%
  filter(otrzymanych_kart != "-") %>%
  mutate_at(vars("otrzymanych_kart":"glosy_wazne_lacznie"), as.numeric)

# prepare for rbind, candidates/slates only
results_candidate_list <- lapply(results_list_raw, '[', c(-1:-2, -5:-32)) %>%
  lapply(function(x) pivot_longer(x, cols = -(1:2)))

# clean and classify by slate/candidate
results_candidate_df <- do.call(rbind, results_candidate_list) %>%
  subset(!value %in% c("-", "XXXXX")) %>%
  mutate(type = if_else(str_detect(name, "^Lista"), "lista", "kandydat")) %>%
  rename(nr_okregu = Okręg, nr_obwodu = Numer, glosow_oddanych = value)

# subset candidates only, clean
results_candidate_clean <- subset(results_candidate_df, type == "kandydat") %>%
  separate(name, c("imiona_nazwisko", "nr_na_liscie"), sep = " - nr na liście ") %>%
  mutate_at(vars("nr_na_liscie":"glosow_oddanych"), as.numeric)

# subset slates only, clean
results_slate_clean <- subset(results_candidate_df, type == "lista") %>%
  separate(name, c("lista_nr", "komitet", "id"), sep = " - ") %>%
  mutate_at(vars("glosow_oddanych"), as.numeric)

### Clean and subset candidates dataset
candidates_df <- candidates_raw %>%
  select(nr_okregu = 'Nr okręgu', komitet = 'Nazwa komitetu', nr_na_liscie = 'Pozycja na liście', Nazwisko, Imiona, plec = Płeć, zawod = Zawód, przynaleznosc = 'Przynależność do partii') %>%
  unite("imiona_nazwisko", c(Imiona, Nazwisko), sep = " ")

# join candidate results and info 
results_candidate_full <- results_candidate_clean %>%
  left_join(candidates_df, by = c("imiona_nazwisko", "nr_okregu", "nr_na_liscie")) %>%
  mutate(ID_komisji = paste(nr_okregu, nr_obwodu, sep = "_"))

### Output data frames: wyniki_komisje_clean, wyniki_kandydaci_clean, wyniki_listy_clean, kandydaci_df, wyniki_kandydaci_joined
### mapa_powiaty, mapa_wojewodztwa

saveRDS(results_station_clean, "output/clean/results_station_clean.rds")
saveRDS(results_candidate_clean, "output/clean/results_candidate_clean.rds")
saveRDS(results_slate_clean, "output/clean/results_slate_clean.rds")
saveRDS(results_candidate_full, "output/clean/results_candidate_full.rds")
saveRDS(map_powiaty, "output/clean/map_powiaty.rds")
saveRDS(map_wojwodztwa, "output/clean/map_wojewodztwa.rds")