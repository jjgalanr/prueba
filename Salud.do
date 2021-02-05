import excel "C:\Users\Jose Jorge\Documents\UAB\STATA\Tutorial_Stata\Salud.xlsx", sheet("Salud") firstrow clear

*Definición de las propiedades de las variables
label variable Id "Identificador"
label variable SexFe "Sexo"
label define dSexo 0 "Masculino" 1 "Femenino"
label values SexFe dSexo
label variable Peso "Peso (kg)"
label variable Talla "Talla (cm)"
label variable FN "Fecha de nacimiento"
format %tdDD/NN/CCYY FN
label variable FR "Fecha de respuesta"
format %tdDD/NN/CCYY FR
label variable CP "Código postal"
label variable PAS "Presión arterial sistólica (mmHg)"
label variable PAD "Presión arterial diastólica (mmHg)"
label variable Fuma "¿Fuma o ha fumado?"
label define dFuma 0 "No fumador" 1 "Ex fumador" 2 "Fumador"
label values Fuma dFuma
label variable EdadF "Edad en la que empezó a fumar (años)"
label variable Tab "Consumo de tabaco (c/d)"
label define dHp 0 "Nunca" 1 "Ocasional" 2 "Habitual"
label define dHn 1 "Bajo" 2 "Medio" 3 "Alto"
label variable H1 "Práctica deportiva"
label values H1 dHp
label variable H2 "Dieta equilibrada"
label values H2 dHp
label variable H3 "Descanso regular"
label values H3 dHp
label variable H4 "Consumo de alcohol"
label values H4 dHn
label variable H5 "Consumo de cafeína"
label values H5 dHn

*Guardar el fichero con los datos de las variables originales
save "C:\Users\Jose Jorge\Documents\UAB\STATA\Tutorial_Stata\Salud0.dta", replace
 
*Creación del IMC
generate IMC = Peso /( Talla / 100)^2
label variable IMC "Índice de masa corporal (kg/m2)"
format %4.1f IMC

*Creación del Código provincial
generate CProv = int( CP /1000)
label variable CProv "Código provincial"

*Creación de la Edad
generate Edad = ( FR - FN  )/365.25
label variable Edad "Edad (años)"
format %6.2f Edad

*Pasar la talla de cm. a metros
recast double Talla
replace Talla = Talla/100
label variable Talla "Talla (m)"

*Fumar antes de los 15 años
generate F15 = EdadF < 15 if EdadF < .
label variable F15 "Fumar antes de los 15 años"
label define dSiNo 0 "No" 1 "Si"
label values F15 dSiNo

*Hábito de fumar
generate HabitFum = Tab > 0 if Tab < .
label variable HabitFum "Hábito de fumar"
label define dHabitFum 0 "No fuma" 1 "Fuma"
label values HabitFum dHabitFum

*Sobrepeso
generate Obs = IMC >= 25 if IMC < .
label variable Obs "Sobrepeso"
label values Obs dSiNo

*Consumo de tabaco
recode Tab (0/5 = 1) (6/15 = 2) (16/max = 3) (else = .), generate(H6)
label variable H6 "Consumo de tabaco"
label values H6 dHn

*Nivel de obesidad según la OMS
recode IMC (30/max = 4 "Obesidad") (25/30 = 3 "Sobrepeso") (18.5/25 = 2 "Normopeso") (min/18.5 = 1 "Infrapeso"), generate(NivObs)
label variable NivObs "Nivel de obesidad según la OMS"

*Peso categorizado por cuartiles
egen float PesoCat = cut(Peso), group(4) icodes label

*Desviación del Peso respecto a la media del grupo de sexo
by SexFe, sort : egen float mPeso = mean(Peso)
generate cPeso = Peso - mPeso
drop mPeso

*Hábitos positivos practicados
egen byte nHp = anycount(H1 H2 H3), values(1 2)
label variable nHp "Número de hábitos positivos practicados"

*Items sin respuesta
egen float ItemMis = rowmiss(H1 H2 H3 H4 H5 H6)

*Recodificar hábitos negativos
recode H4 H5 H6 (1 = 2) (2 = 1) (3 = 0), generate(H4r H5r H6r)

*Puntuación total
egen float PT = rowtotal(H1 H2 H3 H4r H5r H6r)
replace PT = . if ItemMis > 1
label variable PT "Puntuación de salud"
drop ItemMis

*Guardar el fichero con los datos
save "C:\Users\Jose Jorge\Documents\UAB\STATA\Tutorial_Stata\Salud.dta"