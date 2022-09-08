library(tidyverse)  # Core Tidy: incluye ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, y forcats
library(eph)  # paquete para interactuar con Databases de la EPH
library(lubridate) # paquete para trabajar con dates y datetimes


############################## Cómo creamos variables de date & time?

# 1) Funciones básicas de Lubridate para obtener la fecha y hora actual:
today()
now()

# 2) Conviertiendo strings o extrayendo de objetos date/time ya existentes:
fecha_hoy <- "06/09/2022"
# Con Parsers de readr package:
parse_date(fecha_hoy, format = "%m/%d/%Y")  # formato month day year (con 4 digitos)
parse_date("06/09/22", format = "%d/%m/%y")  # formato day month year
parse_date("06/09/22", format = "%y/%m/%d")  # formato year month day
parse_date("6 Septiembre 2022", "%d %B %Y", locale = locale("es"))  # formato day month year con el mes en palabra, por eso seteamos lenguaje ESPAÑOL

# Con Parsers de lubridate package:
dmy(fecha_hoy) 

# 3) Agrupando componentes individuales en uno solo date/time: ejemplo con EPH

### Primero separamos la variable Fecha de nacimiento en 3 variables nuevas (año, mes y dia)
dataset_individual_2022 <- get_microdata(year = 2022, trimester = 1, type = 'individual')
glimpse(dataset_individual_2022$CH05) # Vemos en qué formato viene
class(dataset_individual_2022$CH05)  # El type nativo de la variable es char
dataset_individual_2022 <- dataset_individual_2022 %>% rename(FEC_NAC = CH05) # Renombramos la variable de fecha de nacimiento
  
dataset_dates <- dataset_individual_2022 %>% 
  separate(col = FEC_NAC, into = c("Dia", "Mes", "Año"), sep = "/")  # Separamos en tres variables nuevas especificando el separador "/"

View(dataset_dates)

# Evaluemos, por las dudas, que no hayamos hecho algun error y la columna nueva mes sea correcta
max(dataset_dates$Mes)  # Qué valor es el mayor? 12
with(dataset_dates, dataset_dates$Mes>12)  # Otro ejemplo... Es mayor que 12? False
typeof(dataset_dates$Año)  # Sigue siendo char

# Creemos entonces dos nuevas variables a partir de los 3 componentes char individuales. 
# En este caso usamos make_date() y make_datetime() para ver los distintos resultados
dataset_dates <- dataset_dates %>% 
  mutate(
    Fecha = make_date(Año, Mes, Dia), Fecha_hora = make_datetime(Año, Mes, Dia), .after = Año
  )

View(dataset_dates)
class(dataset_dates$Fecha)       # Clase Date
class(dataset_dates$Fecha_hora)  # "POSIXct" o "POSIXt"  es el type que usa R para almacenar tiempo, a diferencia de date.


# Por último, para switchear entre date y date-times:
as_date(now())  # Input: date-time --> Output: date
as_datetime(today())  # Input: date --> Output: datetime
# Switcheando en un mismo tibble
dataset_dates <- dataset_dates %>% 
  mutate(Fecha_hora = as_date(Fecha_hora))

dataset_dates$Fecha_hora <- NULL   # Borramos y actualizamos 


############################## Cómo extraemos componentes de date & time?
year(dataset_dates$Fecha)  # Extraemos el año
day(dataset_dates$Fecha)   # Extraemos el día 
hour(now())      # Extraemos la hora
minute(now())    # Extraemos el minuto
# Las funciones para acceder a los componentes se pueden usar
# para definir dichos componentes tambien de un objeto. Por ejemplo:
fecha_hoy <- dmy(fecha_hoy)  # Parseamos la fecha string a un type date
year(fecha_hoy) <- 2025      # Extraemos el componente año y lo definimos igual a otro valor
fecha_hoy

############################## Problema hipótetico: 
# tenemos fechas de nacimiento en la EPH y queremos cálcular/graficar cuántos individuos nacieron por día de semana, sin importar el año.
dataset_dates <- dataset_dates %>%
  mutate( dia_semana = wday(Fecha, label=TRUE, abbr = FALSE, week_start = 1, locale = Sys.setlocale("LC_TIME", locale="ES")), .after=Fecha)    # Extraemos y creamos una nueva variable para día de semana con Label
# Nota: la opcion de locale=sys.setlocale la pueden quitar si ya poseen en su computadora el idioma de sistema en español


ggplot(data = dataset_dates) + geom_bar(mapping = aes(x= dia_semana)) +
  labs(x= "Día de semana", y="Nacimientos") + theme_light() +
  ggtitle("Nacimientos por días de semana - EPH 2022")

# Como se puede ver, hay algo raro en el resultado. Lunes triplica aprox. la cantidad media
sum(dataset_dates$dia_semana == "lunes")  # Check de la cantidad total de lunes
sum(dataset_dates$dia_semana == "viernes") # Check de la cantidad total de viernes

# Problema: no casualmente las fechas en Excel comienzan el 01-01-1900, 
# por lo que corresponden a individuos que no respondieron (en diseño de registro EPH es NO SABE/NO RESPONDE)
make_date("9999")  # Los valores para NO SABE/NO RESPONDE es 9, 99, 999 o 9999
# Son un tipo de NA values, y en este caso lo resolveremos eliminando dichas observaciones
dataset_dates_2 <- subset(dataset_dates, !(Fecha == "1900-01-01"))

# Volvemos a graficar:
ggplot(data = dataset_dates_2) + geom_bar(mapping = aes(x= dia_semana)) +
  labs(x= "Día de semana", y="Nacimientos") + theme_light() +
  ggtitle("Nacimientos por días de semana - EPH 2022")
############################## 


############################## Operaciones aritméticas con dates:

edad <- today() - dmy(27081998)
edad  # Diferencia de tiempo 
class(edad)  # clase difftime

### Usando clase Duration:
as.duration(edad)
ddays(0:5)
dweeks(6)
edad <- 2 * dyears(30) - dweeks(300)
edad
class(edad)  # clase duration
tomorrow <- today() + ddays(1)
tomorrow

### Usando clase Period:
days(0:5)
weeks(6)
edad <- 2 * years(30) - weeks(300)
edad
class(edad) # clase period
tomorrow <- today() + days(1)
tomorrow


#### Bonus - Ejemplo: función que calcula y devuelve la edad cuando uno ingresa la fecha de cumpleaños, utilizando metodos de lubridate

my_bd <- function(birthday) {
  as.numeric(as.duration(today() - birthday), "years") %/% 1
}

birthday <- dmy(27081998)
my_bd(birthday)











