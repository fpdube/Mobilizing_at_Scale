##############
##
## Ce fichier télécharge des données du World Development Indicators de la BM
## et fait un tableau du nb de pers. vivant sous différents seuils de la pauvreté
##
##############
require(wbstats)

Cache <- wb_cache()
cache("Cache")
jour_telech <- today()
cache("jour_telech")

# Données
# View(wb_search("poverty headcount", cache = Cache))
# SI.POV.DDAY: Poverty headcount ratio at $2.15 a day (2017 PPP) (% of population)
# SI.POV.LMIC: Poverty headcount ratio at $3.65 a day (2017 PPP) (% of population)
# SI.POV.UMIC: Poverty headcount ratio at $6.85 a day (2017 PPP) (% of population)
# SP.POP.TOTL: Population mondiale
# 

Pov_brut <- wb_data(
  indicator = c("SI.POV.DDAY",
                "SI.POV.LMIC",
                "SI.POV.UMIC",
                "SP.POP.TOTL"),
  country = "income_levels_only",
  # Nb. of most recent values
  mrv = 32,
  # Fill in gaps with last observation
  gapfill = TRUE,
  cache = Cache,
  lang = "en"
) |> rename(
  pov2.15 = SI.POV.DDAY,
  pov3.65 = SI.POV.LMIC,
  pov6.85 = SI.POV.UMIC,
  pop = SP.POP.TOTL,
  year = date
)
cache("Pov_brut")

# Transforme les ratios de pauvreté en nombre absolu
# Additionne les quatre niveaux de pauvreté.
Pov <- Pov_brut |>
  mutate(across(starts_with("pov"), ~ . * pop / 100)) |>
  filter(!(iso3c %in% c("XD", "XY"))) |> 
  group_by(year) |> 
  summarize(across(where(is.numeric), sum)) |> 
  na.omit()
cache("Pov")


