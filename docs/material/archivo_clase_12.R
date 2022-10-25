library(tidyverse) # tiene ggplot, dplyr, tidyr, y otros
library(eph)
dataset_individual <- get_microdata(year = 2022, trimester = 1, type = 'individual') # Importamos el dataset individual directamente desde la base de INDEC
dataset_individual


informalidad <- dataset_individual %>% 
  select(CAT_OCUP, PONDERA, PP07H) %>%   # Creamos un tibble seleccionando las 3 columnas (variables) de relevancia
  filter(CAT_OCUP==3,!is.na(PP07H)) %>%  # Filtramos solo las filas (observaciones) que sean CAT_OCUP==3 y no haya NA values en PP07H
  summarise(poblacion =sum(PONDERA),    # Creamos un summarise para computar una tasa, tal como hicimos en el TP Nº1
            informales =sum(PONDERA[PP07H==2]), 
            tasa_informalidad = informales/poblacion
  )


informalidad

# Notese que la tasa de informalidad ronda el 36%, tal como indica el informe de mercado de trabajo de INDEC (ver página 3 del informe)
informalidad$tasa_informalidad*100
