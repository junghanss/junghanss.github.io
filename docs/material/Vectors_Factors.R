library(tidyverse) # Necesitaremos principalmente el paquete "Purrr"

# (1) Logical Vectors: 
1:10 %% 3 == 0  
# Nota: usar x1:x2 es lo mismo que codear c(x1:x2)
c(1:10) %% 3 == 0

# Sin necesidad de haber almacenado el vector en una variable, evaluemos su type:
typeof(1:10 %% 3 == 0) # Tipo de vector: logical



# (2) Numeric Vectors:

# Objetos numéricos: veamos cómo difieren los enteros de nros de doble precision
typeof(1) # double
typeof(1L) # integer

# Valores especiales de los doubles:
double_vector <- c(-1, 0, 1) / 0  # Nótese el -infinito, +infinito y el NaN
double_vector

# Para chequear estos valores especiales:
is.finite(double_vector)
is.infinite(double_vector)
is.na(double_vector)
is.nan(double_vector)

# (3) Character Vectors:

char_vector <- "Las notas del parcial fueron buenas?"
typeof(char_vector) # type character

object.size(char_vector) # Cuánto pesa un vector de strings?
object.size(double_vector)

### Métodos para vectores

# Conversion: recordar diferencias entre coercion y castear/parsear

# (A) Cast:
int_vector <- as.integer(double_vector)
int_vector # recordemos que en la clase integer solo existe el special value NA 

# (B) Coercion:
# sucede cuando la conversión se da naturalmente a partir de un input en un vector
# Por ejemplo: con logicals, TRUE es 1 y FALSE es 0

int_vector_2 <- c(10, 27, TRUE, FALSE)
int_vector_2 # Nótese cómo TRUE se convirtió en un 1 y FALSE en 0

typeof(int_vector_2)


# Test Functions para vectores:

is_atomic(int_vector)
is_character(int_vector)
is_vector(int_vector)

# Regla de Reciclaje en R y uso de escalares:
library(eph)
dataset_individual <- get_microdata(year = 2022, trimester = 1, type = 'individual') # Importamos el dataset individual directamente desde la base de INDEC

vector_edad <- dataset_individual$CH06
vector_edad
typeof(vector_edad)
is_vector(vector_edad)

vector_edad + 500 # no es novedad que sea posible hacer estas operaciones, pero es importante entender la "regla de reciclaje de vectores"


1:10 + 1:2

1:10 + 1:3 # Nótese la advertencia del recycling cuando no son multiplos de length


# Nombrar vectores:

set_names(vector_edad, c("a", "b")) # Nos arroja error de que la length de nombres debe ser igual al input

nombres <- rep(c("a", "b"),49706/2) # Creamos un vector de "nombres" con c() repetido x veces

set_names(vector_edad, nombres) # Cada elemento del vector tiene ahora un nombre

set_names(vector_edad, letters[1:49706]) # Alternativamente la funcion letters trae el abecedario
?letters

# Subsetting

# Vector de characters
x <- c("one", "two", "three", "four", "five")

# Con enteros positivos: posiciones
x[c(3, 2, 5)]

# Con enteros positivos repetidos: si repetimos una posicion, el output sería más largo.
x[c(3, 3, 3, 2, 2, 2, 5)]

# Con eneteros negativos: si usamos valores negativos, estaremos ELIMINANDO los valores de dichas posiciones.
x[c(-3, -2, -5)]

# Es un ERROR combinar positivos con negativos:
x[c(1, -1)]
# Si leen el mensaje del error, menciona que solo con 0 podemos combinar posiciones negativas:
x[0] # No retorna ningun valor

# Vector de logical
x <- c(10, 3, NA, 5, 8, 1, NA)

x[!is.na(x)] # Devuelve todos los NO na values de x

x[x %% 2 == 0 ] # Devuelve todos los números pares (o missing)


# Vector con nombres

x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]  # Podemos hacer el subset por nombre y con un vector de characteres

x[] # Recordemos que la forma mas simple de hacer subsetting es generalizando los corchetes a nada


###################### Vectores recursivos o listas:

x <- list(1, 2, 3)
x  # Fijense la lógica del print y relacionenlo con el subsetting de un vector

# También pueden ser nombradas:
x_named <- list(a=1, b=2, c=3)
x_named

x2 <- list(x, list(4, list(5,6)))
x2 # Noten la complejidad de almacenamiento de los elementos individuales

# Subsetting de listas.

# Tomemos como ejemplo una lista con múltipls clases de objetos y que los indices estén nombrados:
x3 <- list(a = 1:3, b = "string", c = pi, d = list(-1, -5))

typeof(x3) # El type es una lista

### "[" extrae una sublista. El resultado siempre será, por ende, una lista:
str(x3[1:2]) # extraemos una sublista que tiene elementos del indice 1 a 2 (o sea indices a y b)
str(x3[4])

### "[[" extrae un componente INDIVIDUAL de una lista y remueve el nivel de jerarquia de esta:
str(x3[[3]])
str(x3[[2]])

### "$" es el atajo para extraer elementos NOMBRADOS de la lista y funciona como [[
x3$a
x3[["a"]]

# Entonces, combinando reglas de subsetting:
x3[[4]] # extrae los elementos individuales en indice "d" (que era, a su vez, una lista)
# para desencapsular esa lista en el indice d:
x3[[4]][[1]] # extrae el elemento individual del indice 1 que corresponde a la lista del indice d de la lista madre
# Cómo se diferenciaría de esto?
x3[[4]][1] # extrae la sublista del indice 1 de la lista del indice d en la lista madre

# Comparemos:
typeof(x3[[4]][[1]])
typeof(x3[[4]][1])



############################## Factors

library(forcats)

# Consideremos como ejemplo de variable categorica a REGION: según el registro de la encuesta tenemos que;
# Código de región
# 01 = Gran Buenos Aires
# 40 = NOA
# 41 = NEA
# 42 = Cuyo
# 43 = Pampeana
# 44 = Patagonia


# Cuando los factors están almacenados como tibbles, no podemos ver sus niveles facilmente:
dataset_individual %>% count(REGION) # Una forma de chequearlos es con count
ggplot(dataset_individual, aes(REGION)) + geom_bar() # Otra forma es con un grafico de barras

# Creacion del factor:
region <- factor(dataset_individual$REGION, levels = c(01,40,41,42,43,44))  # Si tuvieramos valores adicionales a los levels especificados, se transformarian en NA

is.factor(region) # Se observa que sí es un factor type
is.ordered(region) # NO está ordenada

# Adicionalmente, podriamos crear un factor indicando que los levels YA ESTÁN ordenados previamente con el método unique() o fct_inorder()
region <- factor(dataset_individual$REGION, levels = unique(dataset_individual$REGION))  # Nótese que levels son: 43 1 44 40 41 42 
region

region <- dataset_individual$REGION %>% factor() %>% fct_inorder()
region # Llegamos al mismo output


# REORDENAMIENTO de niveles de factors:

region_data <- dataset_individual %>% 
  group_by(REGION) %>% 
  summarise(
    edad = mean(CH06, na.rm=TRUE),
    n = n()
  )

ggplot(region_data, aes(factor(REGION), edad)) + geom_bar(stat="identity")
ggplot(region_data, aes(fct_reorder(factor(REGION), edad), edad)) + geom_bar(stat="identity") # Los ordenamos por edad de menor a mayor

# Si queremos reordenar trayendo uno hacia delante de todos los factors:

ggplot(region_data, aes(fct_relevel(factor(REGION), "43"), edad)) + geom_bar(stat="identity") 

  

# MODIFICACION de los niveles de factors usando fct_recode().

region <- fct_recode(region,
                     "Gran Buenos Aires" = "1",
                     "NOA" = "40",
                     "NEA" = "41",
                     "Cuyo" = "42",
                     "Pampeana" = "43",
                     "Patagonia" = "44")

region # Vemos que recode sería como un "rename" pero exclusivamente para factors levels
