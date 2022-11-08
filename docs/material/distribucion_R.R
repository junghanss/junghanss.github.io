# Importación de librerias:
library(tidyverse) # ggplot, dplyr, tidyr, etc
library(ggthemes)  # Para tener más estilos de gráficos
library(ggrepel)   # Para tener etiquetas de texto mejores que las de ggplot
library(eph)
library(forcats)
dataset_individual <- get_microdata(year = 2021, trimester = 1, type = "individual")

# Primeras observaciones:
# Calculamos los ingresos medios laborales (ocupacion principal) por género
# Recordemos que la variable P21 es el monto de ingreso de la ocupación principal. A su vez, PONDIIO es el ponderador del ingreso de la ocupacion principal.

summary(dataset_individual$P21) # Primer vistazo a P21

ingreso_genero <- dataset_individual %>%  
  select(P21 , PONDIIO, CH04) %>%
  filter(P21>0) %>%   # Filtramos aquellas observaciones positivas
  group_by(CH04) %>%  # Agrupamos por genero
  summarise(p21_media_ponderada = weighted.mean(P21, PONDIIO), p21_media_aritmetica = mean(P21) )  # Calculamos la media ponderada

#  summarise(p21_medio_hombre = weighted.mean(P21[CH04==1], PONDIIO[CH04==1]), p21_medio_mujer = weighted.mean(P21[CH04==2], PONDIIO[CH04==2]))
ingreso_genero


# Calculamos los ingresos medios laborales (ocupacion principal) por género y por grupos de edad                                     

ingreso_genero_edad <- dataset_individual %>%  
  select(P21 , PONDIIO, CH04, CH06) %>%  # Seleccionamos las variables de ingreso, el ponderador, el genero y la edad
  filter(P21>0, CH06 %in% c(18:60)) %>%  # Filtramos las observaciones de ingreso>0 y edad en el rango de 18 a 60 años
  mutate(EDAD = case_when(CH06 %in% c(18:30) ~ "18 a 30",      # Creamos tres simples grupos de edad
                          CH06 %in% c(31:45) ~"31 a 45",        
                          CH06 %in% c(46:60) ~ "46 a 60"),
         CH04               = case_when(CH04== 1 ~ "Hombre", # Renombramos el genero en la misma funcion
                                        CH04== 2 ~ "Mujer")) %>% 
  rename(GENERO = CH04) %>% 
  group_by(GENERO, EDAD) %>%  
  summarise(p21_media_ponderada = weighted.mean(P21, PONDIIO), p21_media_aritmetica = mean(P21))

ingreso_genero_edad 


# Ejercicio (a): Caracterice la distribucion del ingreso per capita familiar y del ingreso laboral de la ocupacion principal. 
# Presente la media, el desvıo estandar, la mediana, el modo y los deciles. 
# Utilice ponderadores y excluya a aquellos individuos pertenecientes a hogares con respuestas incoherentes o incompletas. 
# Comente.

# De igual manera que en los cómputos anteriores:
# Consideramos DECOCUR que es la variable para el Nº de decil de ingreso de la ocupacion principal del total EPH
# Cómputo para el ingreso laboral por ocupacion principal
ingresos_ocupacion_principal <- dataset_individual %>%  
  select(P21 , PONDIIO, DECOCUR) %>%
  filter(P21>0) %>%   # Filtramos aquellas observaciones positivas
  mutate(DECOCUR = factor(DECOCUR, levels = c(1:10))) %>% # Parseamos decocur como un factor y le indicamos el orden de las categorias (de 1 a 10 ascendente)
  group_by(DECOCUR) %>%  # Agrupamos por decil
  summarise(Media_Ponderada = weighted.mean(P21, PONDIIO), Media = mean(P21),
            Desvio = sd(P21), Minimo = min(P21), Maximo = max(P21))  # Calculamos las estadísticas deseadas

ingresos_ocupacion_principal

# Cómputo para el ingreso per capita familiar. Debemos usar las siguientes variables:
# IPCF que es el Monto del ingreso per cápita familiar
# PONDIH es el ponderador para ingreso per capita familiar
# DECCFR que es el Nº de decil de ingreso per capita familiar

ingresos_pc_familiar <- dataset_individual %>%  
  select(IPCF , PONDIH, DECCFR) %>%
  filter(IPCF>0) %>%   # Filtramos aquellas observaciones positivas
  mutate(DECCFR = factor(DECCFR, levels = c(1:10))) %>% # Parseamos decocur como un factor y le indicamos el orden de las categorias (de 1 a 10 ascendente)
  group_by(DECCFR) %>%  # Agrupamos por decil
  summarise(Media_Ponderada = weighted.mean(IPCF, PONDIH), Media = mean(IPCF),
            Desvio = sd(IPCF), Minimo = min(IPCF), Maximo = max(IPCF))  # Calculamos las estadísticas deseadas

ingresos_pc_familiar



# Cómputo de gráficos de la distribución del ingreso
# (1) Box plot: 
# Recuerden que para los boxplot se grafiquen correctamente es importante que las variables sean del mismo tipo (ejemplo genero y nivel educativo con categoricas y no continuas)

# Creamos el dataframe con la data específica que necesitamos para los gráficos:
gdata1 <- dataset_individual %>% 
  filter(P21>0, !is.na(NIVEL_ED)) %>%  # Filtramos filas para P21 mayor que cero y valores no NA de nivel educativo
  mutate(NIVEL_ED = as.factor(NIVEL_ED), # Como son categoricas, debemos convertirlas en factors (nótese que no hizo falta cargar la libreria 'forcats')
         CH04     = as.factor(CH04)) 

summary(gdata1$P21)

# Box plot por nivel educativo
ggplot(gdata1, aes(x = NIVEL_ED, y = P21)) +
  geom_boxplot()+
  scale_y_continuous(limits = c(0, 200000)) # Restringimos el gráfico hasta ingresos de $ 200.000

# Box plot por genero
ggplot(gdata1, aes(x = CH04, y = P21)) +
  geom_boxplot()+
  scale_y_continuous(limits = c(0, 200000)) # Restringimos el gráfico hasta ingresos de $ 200.000


# Box plots por nivel educativo y sexo (version 1: subplots por genero)
ggplot(gdata1, aes(x= NIVEL_ED, y = P21, group = NIVEL_ED, fill = NIVEL_ED )) +
  geom_boxplot()+
  scale_y_continuous(limits = c(0, 200000))+
  facet_wrap(~ CH04, labeller = "label_both")

# Box plots por nivel educativo y sexo (version 2: subplots por nivel educativo)
ggplot(gdata1, aes(x= CH04, y = P21, group = CH04, fill = CH04 )) +
  geom_boxplot()+
  scale_y_continuous(limits = c(0, 200000))+
  facet_grid(~ NIVEL_ED, labeller = "label_both") +
  theme(legend.position = "none")




# (2) Histograma:
# Aislamos los datos que necesitamos para el gráfico. En este caso sería simplemente aquellas observaciones P21>0 y nada más
hist_data <- dataset_individual %>%
  filter(P21>0) 

# Creamos el histograma:
ggplot(hist_data, aes(x = P21, weights = PONDIIO)) + 
  geom_histogram()
# Para mayor prolijidad, le acortamos el eje de las abcisas
ggplot(hist_data, aes(x = P21,weights = PONDIIO))+ 
  geom_histogram()+
  scale_x_continuous(limits = c(0,200000))






# Kernels o Kernel Density Estimation (KDE) 
# Aislamos los datos que necesitamos para el gráfico
kernel_data <-dataset_individual %>%
  filter(P21>0) 

# Creamos el gráfico de kernel:
ggplot(kernel_data, aes(x = P21,weights = PONDIIO))+ 
  geom_density()+
  scale_x_continuous(limits = c(0,200000))

# Kernels por genero:
# Creamos la data para el gráfico
kernel_data_2 <- kernel_data %>% 
  mutate(CH04= case_when(CH04 == 1 ~ "Hombre",
                         CH04 == 2 ~ "Mujer"))

ggplot(kernel_data_2, aes(x = P21,
                          weights = PONDIIO,
                          group = CH04,
                          fill = CH04)) +
  geom_density(alpha=0.7,adjust =2)+
  labs(x="Distribucion del ingreso", y="",
       title=" Total segun tipo de ingreso y genero", 
       caption = "Fuente: Encuesta Permanente de Hogares")+
  scale_x_continuous(limits = c(0,200000))


