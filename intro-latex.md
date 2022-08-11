---
layout: default
title: Introducción a LaTeX
permalink: /intro-latex/

---
### Menú del sitio: 
- [Homepage](./index.md)
- [Material de clases (slides, TPs)](./material.md)
- [Introducción a R](./intro-r.md)


&nbsp; 


## Introducción a LaTeX 

LaTeX es un sistema de composición de texto, es decir, sirve para crear documentos de texto estructurados donde se puedan incluir ecuaciones matemáticas, gráficos, imágenes, etc.  
Para entender su funcionamiento, hay que considerar que al escribir, el programa usa y muestra texto sin formato (plain text) a diferencia de los textos formateados en procesadores como Microsoft Word (sistemas tipo "What You See Is What You Get"). A menos que se compile el documento .tex en un .pdf, no se podrá ver lo que realmente hemos formateado a gusto.  


### Ventajas:
- Es por excelencia el sistema más utilizado en el mundo académico para armar documentos (papers, presentaciones, etc).
- Mayor flexibilidad: permite formatear a gusto absolutamente todos los detalles que se desee del documento.
- Saber escribir en LaTeX les abre puertas al Markdown, ampliamente utilizado para visualizar códigos de lenguajes de programación y hasta inclusive en websites (esta misma web se escribió en markdown).

### Opciones de uso:
1. (_Recomendado para principantes_) Se puede trabajar en un editor online que compila el PDF en su propio servidor. Es rápido y práctico.
2. Se puede descargar y disponer localmente de un editor y compilador en la computadora (solo recomendado para computadoras con buenos recursos).

#### 1) Editor Online:

Por convención, el editor online de LaTeX más famoso es Overleaf. Pueden ingresar a este en [https://www.overleaf.com/](https://www.overleaf.com/). Una vez creada una cuenta, el menú de trabajo es [https://www.overleaf.com/project/](https://www.overleaf.com/project/). Con la versión gratuita, pueden compartir sus proyectos con una persona más y trabajar colaborativamente (ambas personas pueden modificar en simultáneo el archivo).

Cabe destacar que la única desventaja de un editor online es que necesitan de una conexión estable a internet para compilar el documento .tex a un .pdf

#### 2) Editor y Compilador Local: 

Si desean trabajar localmente en sus computadoras, tengan en cuenta como prerrequisito que deben tener buenos recursos de procesamiento, ya que la compilación (de .tex a .pdf) la debe soportar enteramente la PC.
- Desventaja: si la computadora no está a la altura de una buena capacidad de procesamiento, puede que compilar un documento les lleve desde 10 segundos hasta varios minutos (esto dependerá de que tanto material deba compilar. No es lo mismo un paper con puro texto, que uno con gráficos, imágenes, etc.)
- Ventaja: si la computadora es buena, podrán trabajar igual de rápido que con un editor online, pero sin la necesidad de estar conectados a internet (offline).   

**Descarga:** se deben descargar en la computadora dos programas (nótese la similitud con R y RStudio).
- [Sistema TeX](https://www.latex-project.org/get/): corresponde a tener LaTeX con todos sus paquetes, etc. en la computadora.
- Editor y Compilador: corresponde al software con interfaz visual en el que podrán crear los archivos, editarlos, compilarlos, etc. Hay varias alternativas disponibles.

Por recomendación y experiencia personal, sugiero los siguientes:
- Sistema TeX: descarga por [TeX Live para Windows](https://tug.org/texlive/) o [MacTeX para MAC OS](https://tug.org/mactex/)
- Editor y Compilador: [TeXstudio](https://www.texstudio.org/)

### Herramientas Útiles:

La curva de aprendizaje de LaTeX es exponencial. Inicialmente cuesta un poco, pero con el transcurso de las semanas y con una práctica regular uno se vuelve capaz de inclusive crear gráficos a partir de simples códigos expresando una función y cantidad de puntos.
Sin embargo, como puede ser difícil cuando no se practica regularmente, hay herramientas que facilitan ese aprendizaje, tales como:
- **Cheatsheets y Manuales**: hay decenas de cheatsheets para LaTeX. A continuación algunos archivos útiles;
  - [Cheatsheet general](docs/material/CheatSheet - LaTeX.pdf)
  - [Manual para economistas del paquete Tikz](docs/material/Tikz-Economics.pdf)
- **Templates**: hay cientos de [templates privados en Overleaf](https://www.overleaf.com/latex/templates), pero les facilito a continuación algunos personales;
  - **Template para artículos**
  - **Template para presentaciones (Beamer)**
- [**Tutoriales de Overleaf**](https://www.overleaf.com/learn): la misma página de Overleaf ofrece decenas de manuales explicativos para paquetes, funciones, etc con ejemplos interactivos.
- **Comunidades**: para buscar la solución a un error, por excelencia el mejor foro es [TexStackExchange](https://tex.stackexchange.com/) (subforo de StackOverFlow)





