library(eph) # Paquete EPH: https://cran.r-project.org/web/packages/eph/vignettes/eph.html
library(tidyverse) # Core Tidy: incluye ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, y forcats

dataset_individual <- get_microdata(year = 2022, trimester = 1, type = 'individual') # Importamos el dataset individual directamente desde la base de INDEC


# TP Nº1 - EJERCICIO 1(a)
# Calcule la correlación entre la condición de ocupado y los años de educación de las personas.
# Aclaración: para ello construya la variable años de educación de la siguiente manera: Sin instrucción=0,
# Primaria Incompleta (incluye educación especial)=5, Primaria Completa=7, 
# Secundaria Incompleta=10, Secundaria Completa=12, 
# Superior Universitaria Incompleta=13, Superior Universitaria Completa=17

# Creamos la variable nueva "Años de Educación" según el criterio lógico indicado en la consigna. Por fines prácticos, se acomoda la variable al lado de nivel educativo
dataset_individual <- dataset_individual %>% 
  mutate(años_educacion = case_when(NIVEL_ED == 7 ~ 0, 
                                    NIVEL_ED == 1 ~ 5,
                                    NIVEL_ED == 2 ~ 7,
                                    NIVEL_ED == 3 ~ 10,
                                    NIVEL_ED == 4 ~ 12,
                                    NIVEL_ED == 5 ~ 13,
                                    NIVEL_ED == 6 ~ 17), 
         .after = NIVEL_ED) 

# Solo se hace un rename para mantener el ESTÁNDAR predefinido del dataset, aunque no sea la forma correcta de nombrar variables
dataset_individual <- dataset_individual %>% rename(AÑOS_ED = años_educacion)  
  
# Cómputo de correlaciones:
# Resolución básica: con paquete nativo Stats de R usando el método cor()

estado_ocupado <- dataset_individual$ESTADO==1
años_ed <- dataset_individual$AÑOS_ED
  
correlation_1 <- cor(x = estado_ocupado , y = años_ed)
correlation_2 <- cor(x = estado_ocupado , y = años_ed, method = "spearman")
correlation_3 <- cor(x = estado_ocupado , y = años_ed, method = "kendall")


# Test de correlacion entre observaciones agrupadas. Devuelve el coeficiente de corr y el p-value
estado_ocupado <- as.numeric(as.factor(estado_ocupado))  # Como el método cor.test trabaja con vectores numéricos, transformamos la variable de vector lógico a numérico
correlation_test <- cor.test(x = estado_ocupado, y = años_ed)
correlation_test

correlation_test$p.value # El resultado como objeto tiene varias variables almacenadas (p-value, stat, etc.)

# Trabajando con un dataframe o tibble podemos usar el parametro de formula y data:
correlation_test_2 <- cor.test(
  formula= ~ ESTADO + AÑOS_ED,
  data = dataset_individual,
  subset = CH07 == 1
)

correlation_test_2

# Alternativas de resolución: con paquete "Correlation". Mucho más avanzado en términos de parámetros que ofrece.
# install.packages("correlation")
# Para visualizar las correlaciones en gráficos, pueden usar el paquete "ggpubr" o el paquete "corrplot"
# install.packages("ggpubr")
# install.packages("corrplot")


#################################################################################################

# EJERCICIO 1 (e)
# Cómputo de informalidad: para esto es conveniente repasar el registro de diseño de la EPH y familiarizarse con más variables de la encuesta acerca de los trabajadores

# Para evaluar la informalidad a partir de la EPH, debemos considerar aquellos trabajadores que sean:
# (1) Empleados en relación de dependencia (CAT_OCUP == 3)
# (2) Que por aquel trabajo NO tengan descuento jubilatorio (PP07H == 2). Recuerden que esa variable es exclusiva para los asalariados

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




