library(tidyverse)
library(stringr)

# Creacion de strings:

string1 <- "Esto es un string"
string2 <- 'Si queremos usar "doble comillas" dentro de un string, hay que usar comillas simples'

# Intuición del "escape character": para usar comillas también es posible por medio de \ 
comilla_doble <- " \" "
comilla_simple <- " \' "
barra_invertida <- "\\"

comilla_doble # Lo raro es que el print incluye la barra invertida \" literalmente, cómo podemos ver solo las comillas que queriamos?
writeLines(comilla_doble) # El método writeLines es de base R y sirve para ver el contenido BRUTO (raw) de los strings

# Otros comandos especiales son:
nueva_linea <- 'Esto es una oración\n que tiene una nueva linea'
nueva_linea # Nuevamente notese que el \n se printea literalmente, usando writeLines vemos el contenido correcto
writeLines(nueva_linea) 

mu <- "\u00b5" # Con ese caracter reservado podemos crear la letra griega Mu
mu

?'"'  # Podemos buscar ayuda sobre caracteres especiales


# Algunas funciones de stringr:
str_length( c("a", "Esto es un vector de strings", NA) )  # La funcion devuelve la longitud de cada string individual dentro del vector

# Combinación:
str_c("String1", " + ", "String2") # Combinación de 3 strings
str_c("Juan", "Pedro", "Florencia", "Hernan", "Fernando", sep = ", ") # Combinación de strings separandolos por un caracter

# Separación: se hace con la funcion str_sub(strings, start, end)

library(eph)
dataset_individual <- get_microdata(year = 2022, trimester = 1, type = 'individual') # Importamos el dataset individual directamente desde la base de INDEC

# Por ejemplo: nos solicitan extraer los primeros 5 caracteres del nomenclador CODUSU de la EPH:
codusu <- dataset_individual$CODUSU
codusu_modificado <- str_sub(codusu, 1, 5)

# Podemos tambien hacer modificaciones especificas con ese método: por ejemplo, hacer que la primera letra sea minuscula
str_sub(codusu, 1, 1) <- str_to_lower(str_sub(codusu, 1, 1))
codusu # Notese que la letra inicial ahora es minuscula



#############################

# RegEx:
# Match de patrones basicos:

str_view(codusu, "DEI")  # Podemos ver que matchea exactamente todos los "DEI" en cada string

str_view(codusu, ".DEI.")  # Agregando un punto, podemos ver que matchea cualquier caracter que tenga dicho string en el espacio del punto


# Match de caracteres especiales:
# Problema 1) Si "." matchea cualquier caracter, cómo podemos matchear literalmente un punto "." ? 
# Al igual que los strings, las regex usan \ para saltearle el comportamiento. Pero, recordemos que las regex están basadas en strings y los strings tambien usan \
# Conclusión: para crear la REGEX \. vamos a necesitar un STRING "\\."

punto <- "\\." # Creamos la expresión regular
writeLines(punto) # Notese que la regex solo contiene un \.
str_view(c("abc", "a.c", "qwerty", "x.y"), punto) # así se le pide a R como buscar el "." explicitamente con regex

# Problema 2) Si "\" se usa como escape character, como matcheamos literalmente un "\"?
# La Regex necesita escaparlo usando \\, pero el string tambien necesita escaparlo con \, en sintesis necesitamos \\\\

barra_invertida <- "\\\\"
writeLines(barra_invertida) # Notese que la regex contiene \\
str_view(c("a\\bc", "\\ac", "qwerty", "x.y"), barra_invertida)

# Anclas:
# (1) con ^ se matchea solo caracteres al inicio
x <- c("apple", "banana", "pear")
str_view(x, "^a")

# (2) con $ se matchea solo caracteres al final
str_view(x, "a$")

# Si quisieramos que matchee una palabra completa en oraciones, podemos usar AMBAS ANCLAS ^...$:
x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple")
str_view(x, "^apple$")  # Notese como matchea solo cuando es apple independientemente

# Otros caracteres especiales:
# \d matchea CUALQUIER digito (numero)
str_view(codusu, "\\d") # Nos matchea el cualquier (primer) digito que aparece
str_view(codusu, "\\d$") # Asi nos matchea cualquier digito que aparezca a lo ultimo $
str_view(codusu, "\\d+") # Así nos matchea cualquier digito O MÁS que tengamos


# [abc] matchearía a, b o c. Por otro lado, [^abc] matchearía  EXCEPTO a, b o c.
str_view(codusu, "[^tQR]") # Vemos que matchea lo primero que tenga sacando tQR

# Y si quieramos alternar usamos | como operador logico
str_view(c("grey", "gray"), "gr(e|a)y")


# Repetición:
# Si queremos controlar cuántas veces matchee el patron, podemos usar los caracteres ?, + o *
str_view(codusu, "7") # match una vez
str_view(codusu, "7+") # match una o más veces
str_view(codusu, "7*") # match 0 o más veces ()
str_view(codusu, "K{1,3}") # match entre 1 y 3 veces

# Grupos y referencias inversas:

str_view(codusu, "(.)\\1", match = TRUE) # caracteres individuales que se repitan 1 vez
str_view(codusu, "(..)\\1", match = TRUE) # dos caracteres (un par) que se repitan 1 vez
str_view(codusu, "(...)\\1", match = TRUE) # tres caracteres que se repitan 1 vez


# Detección de matches:

str_detect(codusu, "TQR") # Nos indica qué Codigos tienen TQR en su cadena de string. La respuesta es logica (true/false)
# Podemos aprovechar esta funcion y hacer un count de los true:
sum(str_detect(codusu, "TQR")) # Vemos que 48549 codusu tienen TQR 

# Una pregunta más intuitiva podría ser cuántas personas de la eph nacieron en determinado año?
fecha_nacimiento_eph <- dataset_individual$CH05
sum(str_detect(fecha_nacimiento_eph, "1998")) # Vemos que 645 personas de la EPH nacieron en 1998 

# Otra forma de responder esa pregunta es con str_count()
sum(str_count(fecha_nacimiento_eph, "1998"))

# Extracción de los match:
str_extract(fecha_nacimiento_eph, "1998") # Si queremos extraer los match, podemos usar extract, pero nótese que nos devuelve el vector original con NAs y matchs
# Para obtener un vector con ÚNICAMENTE los match deberiamos primero hacer un subset y segundo un extract

años_1998 <- str_subset(fecha_nacimiento_eph, "1998") # Nuestro nuevo vector contiene solo aquellos datos que incluyen 1998
str_extract(años_1998, "1998") # Este último vector contiene los match AISLADOS a partir de la extracción


# Reemplazo de los match:
# Supongamos que por algun motivo nos solicitan cambiar los strings que contengan "01/01/1900" en la variable edad por un año base 1940

fecha_nacimiento_eph <- str_replace_all(fecha_nacimiento_eph, "01/01/1900", "01/01/1940")
View(fecha_nacimiento_eph)




