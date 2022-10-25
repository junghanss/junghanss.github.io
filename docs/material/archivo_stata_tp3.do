clear all
import excel "C:\Users\JUAN\Documents\Universidad\UCEMA\Economia Laboral\Datasets\Clase 1\usu_individual_T120.xlsx", sheet("usu_pers_T12020") firstrow

/* (A/B) Calcular correlación entre la condición OCUPADO y:

(1) Años de educación de las personas: */

gen _DESOCUPADO = 0 	// Variable de desocupado
replace _DESOCUPADO = 1 if ESTADO==2
gen _OCUPADO = 0
replace _OCUPADO = 1 if ESTADO==1
gen _PEA = 0 	// Generamos la PEA para no correlacionar ocupados con el resto de la poblacion.
replace _PEA = 1 if _DESOCUPADO==1 | _OCUPADO==1
gen _EDUC=0
replace _EDUC=5 if NIVEL_ED==1
replace _EDUC=7 if NIVEL_ED==2
replace _EDUC=10 if NIVEL_ED==3
replace _EDUC=12 if NIVEL_ED==4
replace _EDUC=13 if NIVEL_ED==5
replace _EDUC=17 if NIVEL_ED==6
*Por las dudas incorporamos los resultado NIVEL_ED=9 para luego eliminarlos de manera facil. Verificamos:
replace _EDUC=. if NIVEL_ED==9 // Vemos que nos genera cero cambios

pwcorr _PEA _EDUC, sig
*plot  _EDUC _PEA

pwcorr _DESOCUPADO _EDUC if _PEA==1, sig

*(2) Estado civil:

gen _CASADO = 0
replace _CASADO=1 if CH07==2
gen _UNIDO = 0
replace _UNIDO=1 if CH07==1
gen _ESTADOCIVIL = _CASADO + _UNIDO
gen _ESTADOCIVIL2 = 0
replace _ESTADOCIVIL2=1 if CH07>2

pwcorr _PEA _ESTADOCIVIL, sig
pwcorr _PEA _ESTADOCIVIL2, sig
corr _PEA _ESTADOCIVIL _ESTADOCIVIL2

pwcorr _DESOCUPADO _ESTADOCIVIL if _PEA==1, sig
pwcorr _DESOCUPADO _ESTADOCIVIL2 if _PEA==1, sig
corr _DESOCUPADO _ESTADOCIVIL _ESTADOCIVIL2

*(3) Presencia de niños menores de 18 años en el hogar:

egen _HOGAR = concat(CODUSU NRO_HOGAR)
gen _HIJOS=1 if CH03==3 & CH06<18 // Generamos la variable hijo SI es un hijo (CH03=3) y si es menor a 18 años (CH06<18). Ahora le asignamos un 1 al hogar si vemos que tenga al menos hijos==1 por un pibe solo menor de edad
bysort _HOGAR:egen _HIJOSH=max(_HIJOS) /*max busca el valor maximo --> hijos es =1 o =. ; asi que es pedirle generar hijosh si hijos==1
Como debemos hacer una correlacion, no podemos dejar el valor . en la variable: */
replace _HIJOSH=0 if _HIJOSH==.

bro _DESOCUPADO _HIJOS _HIJOSH _HOGAR

pwcorr _PEA _HIJOSH, sig
pwcorr _DESOCUPADO _HIJOSH if _PEA==1, sig 

*(4) La participacion laboral del jefe/a de hogar y su conyuge

gen _BOSS_ACTIVO = 0
replace _BOSS_ACTIVO = 1 if _PEA==1 & CH03==1 // Declaramos que sea jefe si participa laboralmente y tiene la condicion de jefe en el hogar
gen _CONYUGE_ACTIVO = 0
replace _CONYUGE_ACTIVO = 1 if _PEA==1 & CH03==2 // Declaramos que sea conyugue si participa laboralmente y tiene la condicion de conyugue en el hogar

bysort _HOGAR:egen _HAY_BOSS_ACTIVO=max(_BOSS_ACTIVO) // El hogar tendra un 1 si hay un jefe/a activo
bysort _HOGAR:egen _HAY_CONYUGE_ACTIVO=max(_CONYUGE_ACTIVO) // El hogar tendra un 1 si hay un conyugue activo

generate _PAREJA_ACTIVA = 0 
replace _PAREJA_ACTIVA = 1 if _HAY_BOSS_ACTIVO==1 & _HAY_CONYUGE_ACTIVO==1 // El hogar tendra pareja = 1 si hay ambos, jefe/a activo y conyugue activo

*bro _PEA _PAREJA_ACTIVA _HOGAR 
pwcorr _PEA _PAREJA_ACTIVA, sig

*------------------------------------------

gen _BOSS_ACTIVO_DES = 0
replace _BOSS_ACTIVO_DES = 1 if _PEA==1 & ESTADO==2 & CH03==1
gen _CONYUGE_ACTIVO_DES = 0
replace _CONYUGE_ACTIVO_DES = 1 if _PEA==1 & ESTADO==2 & CH03==2

bysort _HOGAR:egen _HAY_BOSS_ACTIVO_DES=max(_BOSS_ACTIVO_DES)
bysort _HOGAR:egen _HAY_CONYUGE_ACTIVO_DES=max(_CONYUGE_ACTIVO_DES)

generate _PAREJA_ACTIVA_DESOCUPADA = 0 
replace _PAREJA_ACTIVA_DESOCUPADA = 1 if _HAY_BOSS_ACTIVO_DES==1 & _HAY_CONYUGE_ACTIVO_DES==1

pwcorr _DESOCUPADO _PAREJA_ACTIVA_DESOCUPADA if _PEA==1, sig
corr _DESOCUPADO _BOSS_ACTIVO_DES _CONYUGE_ACTIVO_DES


*(C) Rehacer los items (A.1 – A.3) y (B.1 – B.3), pero separando entre hombres y mujeres:

*(1) Años de educación de las personas:

gen _DESOCUPADO_MUJER = 0 	// Variable de desocupado para sexo femenino
replace _DESOCUPADO_MUJER = 1 if ESTADO==2 & CH04==2
gen _DESOCUPADO_HOMBRE = 0 	// Variable de desocupado para sexo masculino
replace _DESOCUPADO_HOMBRE = 1 if ESTADO==2 & CH04==1
gen _OCUPADO_MUJER = 0		// Variable de ocupado para sexo femenino
replace _OCUPADO_MUJER = 1 if ESTADO==1 & CH04==2
gen _OCUPADO_HOMBRE = 0		// Variable de ocupado para sexo masculino
replace _OCUPADO_HOMBRE = 1 if ESTADO==1 & CH04==1
gen _PEA_MUJER = 0 	// Generamos la PEA para no correlacionar ocupados con el resto de la poblacion.
replace _PEA_MUJER = 1 if _DESOCUPADO_MUJER==1 | _OCUPADO_MUJER==1
gen _PEA_HOMBRE = 0
replace _PEA_HOMBRE = 1 if _DESOCUPADO_HOMBRE==1 | _OCUPADO_HOMBRE==1

pwcorr _PEA_MUJER _EDUC, sig
pwcorr _PEA_HOMBRE _EDUC, sig
*plot  _EDUC _PEA

pwcorr _DESOCUPADO_HOMBRE _EDUC if _PEA_HOMBRE==1, sig
pwcorr _DESOCUPADO_MUJER _EDUC if _PEA_MUJER==1, sig

*(2) Estado civil:

gen _CASADO_MUJER = 0
replace _CASADO_MUJER=1 if CH07==2 & CH04==2
gen _CASADO_HOMBRE = 0
replace _CASADO_HOMBRE=1 if CH07==2 & CH04==1
gen _UNIDO_MUJER = 0
replace _UNIDO_MUJER=1 if CH07==1 & CH04==2
gen _UNIDO_HOMBRE = 0
replace _UNIDO_HOMBRE=1 if CH07==1 & CH04==1

gen _ESTADOCIVIL_MUJER = _CASADO_MUJER + _UNIDO_MUJER
gen _ESTADOCIVIL_HOMBRE = _CASADO_HOMBRE + _UNIDO_HOMBRE

gen _ESTADOCIVIL2_MUJER = 0
replace _ESTADOCIVIL2_MUJER=1 if CH07>2 & CH04==2
gen _ESTADOCIVIL2_HOMBRE = 0
replace _ESTADOCIVIL2_HOMBRE=1 if CH07>2 & CH04==1

pwcorr _PEA_MUJER _ESTADOCIVIL_MUJER, sig
pwcorr _PEA_MUJER _ESTADOCIVIL2_MUJER, sig
pwcorr _PEA_HOMBRE _ESTADOCIVIL_HOMBRE, sig
pwcorr _PEA_HOMBRE _ESTADOCIVIL2_HOMBRE, sig

corr _PEA_MUJER _ESTADOCIVIL_MUJER _ESTADOCIVIL2_MUJER
corr _PEA_HOMBRE _ESTADOCIVIL_HOMBRE _ESTADOCIVIL2_HOMBRE

pwcorr _DESOCUPADO_MUJER _ESTADOCIVIL_MUJER, sig
pwcorr _DESOCUPADO_MUJER _ESTADOCIVIL2_MUJER, sig
pwcorr _DESOCUPADO_HOMBRE _ESTADOCIVIL_HOMBRE, sig
pwcorr _DESOCUPADO_HOMBRE _ESTADOCIVIL2_HOMBRE, sig

*(3) Presencia de niños menores de 18 años en el hogar:

pwcorr _PEA_MUJER _HIJOSH, sig
pwcorr _PEA_HOMBRE _HIJOSH, sig

pwcorr _DESOCUPADO_MUJER _HIJOSH if _PEA_MUJER==1, sig 
pwcorr _DESOCUPADO_HOMBRE _HIJOSH if _PEA_HOMBRE==1, sig 



*------------------------------------
*(E)

tab CAT_OCUP PP07H [fw=PONDERA]

gen INFORMAL = 0 
replace INFORMAL = 1 if PP07H==2
replace INFORMAL =. if PP07H==.

br CAT_OCUP PP07H ESTADO INFORMAL

tab CAT_OCUP INFORMAL [fw=PONDERA]
tab REGION INFORMAL if CAT_OCUP==3 [fw=PONDERA]

tab REGION INFORMAL if CAT_OCUP==3 [fw=PONDERA], nofreq row // Para armar las ponderaciones
tab REGION INFORMAL if CAT_OCUP==3 [fw=PONDERA], nofreq col // Pedimos proporciones por columna
tab REGION INFORMAL if CAT_OCUP==3 [fw=PONDERA], nofreq cell // Pedimos proporciones por celda

/*
clear all
use "C:\Users\JUAN\Documents\Universidad\UCEMA\Economia Laboral\Datasets\TP1\t204_dta\Individual_t204.dta"
gen INFORMAL = 0 
replace INFORMAL = 1 if pp07h==2
replace INFORMAL =. if pp07h==.
tab cat_ocup INFORMAL [fw=pondera]
tab region INFORMAL if cat_ocup==3 [fw=pondera]
