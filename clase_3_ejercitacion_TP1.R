# install.packages('eph') # Instalamos el paquete de EPH
library(eph) # Paquete EPH: https://cran.r-project.org/web/packages/eph/vignettes/eph.html
library(tidyverse) # Core Tidy: incluye ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, y forcats

ls('package:eph') # Con la función ls listamos los objetos de un paquete, así podemos ver qué funciones tiene.
help(package = eph) # Abrimos la documentación.

# Importamos el dataset directamente con el paquete EPH. Se busca por AÑO, TRIMESTRE y TIPO DE BASE (individual u hogar). 
dataset_individual <- get_microdata(year = 2022, trimester = 1, type = 'individual')

# Importamos el dataset de hogares
dataset_hogares <- get_microdata(year = 2022, trimester = 1, type = 'hogar')

# Apéndice: si quisieran descargar varios años en la misma base, es posible por medio de indicarlo en el parámetro de la siguiente manera:
dataset_2004_2008 <- get_microdata(
  year = 2004:2008,
  trimester = 1,
  type = 'individual',
  vars = c('PONDERA', 'TRIMESTRE', 'CH03', 'ESTADO')
)


#################### TP1[f] Vuelva a estimar (a) solo para el caso de las mujeres, distinguiendo si hay o no hijos menores de 18 años en el hogar

# Primer vistazo a las variables.  
names(dataset_individual)
names(dataset_hogares) # Identifiquemos NRO_HOGAR y CODUSU que son las variables de nuestro interés para el punto (F) del TP1


# Veamos de todas maneras qué variables se repiten en ambos datasets. ¿Cuántas y cuáles son?
shared_variables <- names(dataset_individual[names(dataset_individual) %in% names(dataset_hogares)]) # Devuelve columnas/variables que aparecen en AMBOS datasets
shared_variables # Observamos que son 23 en total
length(shared_variables) 

# En función de lo anterior, podemos hacer un Full join con las 23 variables en común de ambos datasets
# Es el Join más sencillo, ya que no especificamos el parámetro by=, ergo no clona variables repetidas, sino que el JOIN lo hace con TODAS las que encuentra en comun
data_full <- full_join(x = dataset_individual, y = dataset_hogares)  
names(data_full) # Cómo controlamos que estén todas las variables y sin repetirse en el nuevo set? 177 + 88 - 23 = 242

View(data_full)
# ¿Cómo identificamos que haya o no hijos menores de edad? 
# Condiciones lógicas solicitadas: según el diseño de registro tenemos que
# (1) CH03==3, es decir, relación de parentesco =3 cuando es hijo/a
# (2) CH06<18, o sea, edad menor a 18 para dicho individuo


data_full <- data_full %>%
  rename(PARENTESCO = CH03, EDAD = CH06, GENERO = CH04) %>% # Con el rename hacemos el código más intuitivo luego
  select(CODUSU, NRO_HOGAR, GENERO, PARENTESCO, EDAD, PONDERA, ESTADO, everything())  # Reordenamos las columnas al inicio para fines prácticos

# Hay muchas formas de crear la nueva variable, esta puede ser una alternativa de tantas:

data_full_Nueva <- data_full %>% 
  mutate(HIJOS_MENORES = case_when(EDAD<18 & PARENTESCO==3 ~ 1), .after = EDAD) %>%   # Agregamos una variable nueva que tiene 1 si hay hijos menores o NA caso contrario
  group_by(CODUSU) %>%  # Ordenamos por hogares
  fill(HIJOS_MENORES, .direction = 'updown') %>%  # Reemplazamos los NA de los grupos de hogares donde habia un hijo menor por un 1
  replace_na(list(HIJOS_MENORES = 0)) %>%  # Reemplazamos los NA restantes (donde no hay hijos menores) por un 0'
  ungroup() # Desagrupamos por hogares


View(data_full_Nueva)

########################## Tasa de participación laboral para todos los trabajadores:


tasas_actividad_total <- data_full_Nueva %>% 
  group_by(HIJOS_MENORES) %>% 
  summarise(
    pob_Total = sum(PONDERA),
    pea_1 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=25 & EDAD<=34]), tasa_actividad_1 = pea_1/pob_Total,
    pea_2 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=35 & EDAD<=44]), tasa_actividad_2 = pea_2/pob_Total,
    pea_3 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=45 & EDAD<=54]), tasa_actividad_3 = pea_3/pob_Total,
    pea_4 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=55 & EDAD<=64]), tasa_actividad_4 = pea_4/pob_Total,
  )

tasas_actividad_total <- tasas_actividad_total %>% 
  pivot_longer( cols = c(4,6,8,10), names_to = "Tasas", values_to = "Valor") %>% 
  select(-(2:6))

print(tasas_actividad_total)


########################## Tasa de participación laboral segmentada por género:

tasas_actividad_genero <- data_full_Nueva %>% 
  group_by(GENERO, HIJOS_MENORES) %>% 
  summarise(
    pob_total = sum(PONDERA),
    pea_1 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=25 & EDAD<=34]), tasa_actividad_1 = pea_1/pob_total,
    pea_2 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=35 & EDAD<=44]), tasa_actividad_2 = pea_2/pob_total,
    pea_3 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=45 & EDAD<=54]), tasa_actividad_3 = pea_3/pob_total,
    pea_4 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=55 & EDAD<=64]), tasa_actividad_4 = pea_4/pob_total,
  )

tasas_actividad_genero <- tasas_actividad_genero %>% 
  pivot_longer(cols = c(5,7,9,11), names_to = "Tasas", values_to = "Valor") %>% 
  select(-(3:7)) # Eliminamos nuevamente las PEA


tasas_actividad_genero <- tasas_actividad_genero %>% 
  mutate(
    GENERO = case_when(
      GENERO==1 ~ "Masculino",
      GENERO==2 ~ "Femenino",
    )
  )
print(tasas_actividad_genero)

# Si se quisieran presentar solamente las tasas del género femenino:
tasas_actividad_femenino <- filter(tasas_actividad_genero, GENERO=="Femenino")

print(tasas_actividad_femenino)
