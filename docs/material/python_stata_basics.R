# install.packages("reticulate") # Reticulate es la libreria que nos permitirá trabajar con Python en R
library(reticulate)

# Debemos especificar de dónde correrá Python.
# (1) Si ya lo tenemos instalado en la computadora, especificamos el path 
use_python("C:\\ProgramData\\Anaconda3")

# (2) Si NO lo tenemos instalado, reticulate nos ofrece instalar Miniconda para correr python.
# Para instalar Miniconda hay que responder "Y" en la consola cuando pregunta si deseamos hacerlo.

py_run_string("import numpy as np")
py_run_string("my_python_array = np.array([2,4,6,8])")


# Sourcing Python scripts
source_python('0 - Material Clases\\Clase 12 - 25-10-22\\clase_12.py')
computo_tasa_informalidad(5, 10)


source("G:\\My Drive\\Universidad\\2.2 - UCEMA\\Economía Laboral\\2022 Practica\\0 - Material Clases\\Clase 12 - 25-10-22\\codigo_base_datos.R")

computo_tasa_informalidad(informalidad$informales, informalidad$poblacion)


repl_python() # Para trabajar escribiendo en Python interactivamente en este archivo.



##########################
# Stata:

install.packages('RStata')
library(RStata)

options("RStata.StataPath" = "G:\\My Drive\\Universidad\\1 - Data Science\\Stata Download\\Stata-MP-16.0\\Stata-MP-16.0")
options("RStata.StataVersion" = 16)

stata('di "Hello World"')
stata('di 2+2')
stata('clear all')

command <- "sysuse auto, clear
  sum mpg, d"
stata(command)


