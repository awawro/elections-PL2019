download.file("https://sejmsenat2019.pkw.gov.pl/sejmsenat2019/data/csv/obwody_glosowania_csv.zip",
              destfile = "input/districts/obwody_glosowania_csv.zip")
unzip("input/districts/obwody_glosowania_csv.zip", exdir = "input/districts")
#
download.file("https://sejmsenat2019.pkw.gov.pl/sejmsenat2019/data/csv/kandydaci_sejm_csv.zip",
              destfile = "input/candidates/kandydaci_sejm_csv.zip")
unzip("input/candidates/kandydaci_sejm_csv.zip", exdir = "input/candidates")
#
download.file("https://sejmsenat2019.pkw.gov.pl/sejmsenat2019/data/csv/wyniki_gl_na_kand_po_obwodach_sejm_csv.zip",
              destfile = "input/results/wyniki_gl_na_listy_po_obwodach_sejm_csv")
unzip("input/results/wyniki_gl_na_listy_po_obwodach_sejm_csv", exdir = "input/results")

download.file("https://github.com/ppatrzyk/polska-geojson/raw/master/powiaty/powiaty-medium.geojson",
              destfile = "input/maps/powiaty-medium.geojson")

download.file("https://github.com/ppatrzyk/polska-geojson/raw/master/wojewodztwa/wojewodztwa-medium.geojson",
              destfile = "input/maps/wojewodztwa-medium.geojson")