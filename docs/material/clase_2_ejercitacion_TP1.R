# install.packages('eph') # Instalamos el paquete de EPH
library(eph) # Paquete EPH: https://cran.r-project.org/web/packages/eph/vignettes/eph.html
library(tidyverse) # Core Tidy: incluye ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, y forcats
library(readxl) # Para importar y leer archivos Excel xls

options(digits = 4) # Funcion para configurar parametros de base R


ls('package:eph') # Con la función ls listamos los objetos de un paquete, así podemos ver qué funciones tiene.
help(package = eph) # Abrimos la documentación.

# Opcion 1: Importamos el dataset localmente desde nuestra pc, en formato XLSX. NO hace falta pasar parametros de sheet, columns, etc.
dataset_individual <- read_xlsx(
  path = "G:\\My Drive\\Universidad\\UCEMA\\Economía Laboral\\2023 Practica\\4 - Soluciones TP\\TP 1\\Dataset 1Q 2022\\EPH_usu_1er_Trim_2022_xlsx\\usu_individual_T122.xlsx"
  )

# Opcion 2: Importamos el dataset directamente con el paquete EPH. Se busca por AÑO, TRIMESTRE y TIPO DE BASE (individual u hogar). 
dataset_individual <- get_microdata(year = 2022, trimester = 1, type = 'individual')

warnings() # Para chequear manualmente las advertencias que arrojó la importación del dataset

typeof(dataset_individual) # # Acostumbrense cuando sea necesario a verificar el tipo de objeto con el que están trabajando

# Primer observacion general del dataset. Métodos:
str(dataset_individual) # str=structure. Vistazo reducido
glimpse(dataset_individual) # Glimpse=Vistazo ampliado. Es una versión transpuesta de print.
View(dataset_individual) # Abrir el viewer
names(dataset_individual) # para visualizar las variables (column names)
summary(dataset_individual) [,c(14,27,28,133)] # resumen de las principales estadísticas descriptivas (de las variables 14,27,28,133)
head(dataset_individual) # Devuelve las primeras partes del dataset
tail(dataset_individual) # Devuelve las últimas partes del dataset



# Los nombres de las variables son abreviaciones técnicas que desconocemos, hay que verificar el diseño de registro. 
# Para un código más friendly, hacemos un rename de variables:

dataset_individual <- dataset_individual %>%
  rename(PARENTESCO = CH03, GENERO = CH04, EDAD = CH06, ECIVIL = CH07, EDUCACION = CH12)

names(dataset_individual) # Notese cómo quedaron nuestros nombres de variables


# Primeros cálculos que podemos contrastar con el informe técnico de la EPH (página 3). 
# Recuerden que "the pipe" %>% es la funcion operacional que nos permite pasar el output de una funcion o argumento a la siguiente, de manera secuencial.

poblacion_general <- dataset_individual %>% 
  summarise(poblacion_total = sum(PONDERA), ocupados =sum(PONDERA[ESTADO==1]), desocupados = sum(PONDERA[ESTADO==2]), pea = ocupados+desocupados)
# Recuerden que summarise (o summarize) era la función que nos permite crear multiples variables de resumen simultaneamente.
print(poblacion_general)

tasa_empleo <- poblacion_general$ocupados / poblacion_general$poblacion_total
print(tasa_empleo) # Coincide con el informe técnico

tasa_actividad <- poblacion_general$pea / poblacion_general$poblacion_total
print(tasa_actividad)
  
tasa_desocupacion <- poblacion_general$desocupados / poblacion_general$pea
print(tasa_desocupacion, digits = 9) # con el parámetro digits pueden aumentar la precision del número


# Así, podemos recrear el Cuadro 1.1 del Informe técnico de Mercado de Trabajo de la EPH (página 5). Primero debemos crear algunas variables extra:
cuadro_1.1_intermedio<- dataset_individual %>% 
  summarise(poblacion = sum(PONDERA),
            ocupados = sum(PONDERA[ESTADO==1]),
            desocupados = sum(PONDERA[ESTADO==2]),
            pea = ocupados+desocupados,
            ocupados_demand = sum(PONDERA[ESTADO==1&PP03J==1]),
            subocup_demand = sum(PONDERA[ESTADO==1&INTENSI==1&PP03J==1]),
            subocup_no_demand = sum(PONDERA[ESTADO==1&INTENSI==1&PP03J %in% c(2,9)]),
            subocup = subocup_demand+subocup_no_demand,
            tasa_Actividad = pea/poblacion,
            tasa_Empleo = ocupados/poblacion,
            tasa_Desocupacion = desocupados/pea,
            tasa_ocupados_demandantes = ocupados_demand/pea,
            tasa_Subocupacion = subocup/pea,
            tasa_Subocupacion_demandante = subocup_demand/pea,
            tasa_Subocupacion_no_demandante = subocup_no_demand/pea)

print(cuadro_1.1_intermedio)
glimpse(cuadro_1.1_intermedio) # Como se puede notar, está construido con 1 fila y 15 columnas/variables. 

# Seleccionamos solamente las variables del cuadro de la página 5 (las tasas). Todas las variables menos de la 1 a 8
cuadro_1.1 <- cuadro_1.1_intermedio %>% 
  select(-(1:8))

print(cuadro_1.1)
glimpse(cuadro_1.1) # Acá se ve mejor como glimpse es un "print transpuesto". 


# Vamos a pivotear/transponer la tabla para que quede como en el informe técnico (al igual que glimpse)
# Recomendado: lean el manual de pivot_longer. El argumento names_to es para crear la columna donde iran los nombres de las columnas viejas
# El argumento values_to es para crear la columna donde iran los valores correspondientes a esas columnas viejas
cuadro_1.1 <- cuadro_1.1 %>% 
  pivot_longer(cols=1:7, names_to = "Tasas", values_to = "Valor") 

print(cuadro_1.1)
glimpse(cuadro_1.1) # Notese como glimpse ahora nos transpone la impresion



# Dado que la emplearemos siempre, almacenemos en una variable a la poblacion total
poblacion_Total <- sum(dataset_individual$PONDERA)
print(poblacion_Total)
typeof(poblacion_Total) # Solo para chequear, la variable es un double (nro decimal)

########################### Ejercicio (A): Tasa de participacion laboral por edad y por genero.
##### Podemos trabajar con el dataset de distintas formas, según consideren la más conveniente.

#### Alternativa 1) Cálculo Directo sobre el dataset
# Cálculo de las tasas SIN diferenciar por genero

tasas_actividad_total_1 <- dataset_individual %>% 
  summarise(
    pea_1 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=25 & EDAD<=34]), tasa_actividad_1 = pea_1/poblacion_Total,
    pea_2 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=35 & EDAD<=44]), tasa_actividad_2 = pea_2/poblacion_Total,
    pea_3 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=45 & EDAD<=54]), tasa_actividad_3 = pea_3/poblacion_Total,
    pea_4 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=55 & EDAD<=64]), tasa_actividad_4 = pea_4/poblacion_Total,
      )
print(tasas_actividad_total_1)

tasas_actividad_total_1 <- tasas_actividad_total_1 %>% 
  pivot_longer(tasas_actividad_total_1, cols = c(2,4,6,8), names_to = "Tasas", values_to = "Valor") %>%  # Transponemos el tibble 
  select(-(1:4))   # Nos quedamos unicamente con las tasas de participacion laboral (excluimos las PEA)

print(tasas_actividad_total_1)
ggplot(tasas_actividad_total_1) + geom_bar(mapping=aes(x = Tasas, y = Valor), stat = "identity")  


##################### Alternativa 2) Agrupando el dataset por Genero (por ejemplo para el ejercicio A) 
## Con una linea de código más (group_by) hemos obtenido el doble de tasas, i.e. las que solicitaban en el enunciado

tasas_actividad_genero <- dataset_individual %>% 
  group_by(GENERO) %>% 
  summarise(
    pob_total = sum(PONDERA),
    pea_1 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=25 & EDAD<=34]), tasa_actividad_1 = pea_1/pob_total,
    pea_2 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=35 & EDAD<=44]), tasa_actividad_2 = pea_2/pob_total,
    pea_3 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=45 & EDAD<=54]), tasa_actividad_3 = pea_3/pob_total,
    pea_4 =sum(PONDERA[ESTADO ==1 | ESTADO==2 & EDAD>=55 & EDAD<=64]), tasa_actividad_4 = pea_4/pob_total,
    )

tasas_actividad_genero <- tasas_actividad_genero %>% 
  pivot_longer(cols = c(4,6,8,10), names_to = "Tasas", values_to = "Valor") %>% 
  select(-(2:6)) # Eliminamos nuevamente las PEA

print(tasas_actividad_genero)


# Antes de graficar, podemos renombrar para fines practicos las variables categoricas de Género
tasas_actividad_genero <- tasas_actividad_genero %>% 
  mutate(
    GENERO = case_when(
      GENERO==1 ~ "Masculino",
      GENERO==2 ~ "Femenino"
    )
  )

ggplot(tasas_actividad_genero) + geom_bar(mapping=aes(x = Tasas, y = Valor, color=GENERO), stat = "identity")


