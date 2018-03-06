#!/bin/bash

# *****************************************************
# Trabajo Practico Nº2
# Entrega Nº2
# Fecha 12/10/2016
#
# Ejercicio 6
# Nombre del script: Ejercicio6.sh
#
#*****************************************************
#
# Integrantes:	
#
# Apellido y nombre            		DNI
#-----------------------------------------------------
# D'Amico, Rodrigo                  DNI 36.817.422
# Ibarra, Gerardo                   DNI 33.530.202
# Lorenz Vieta, German              DNI 32.022.001
# Matticoli, Martin                 DNI 37.121.122
# Silva, Ezequiel                   DNI 36.404.597         
#
#*****************************************************

parametro=$1;
parametro2=$2;
declare -A ht;
declare -A ht2;
declare -A ht3;
cont="0";
bandera="0";
bandera1="0";

#Ayuda
function ayuda {
echo " "
echo "AYUDA"
echo "##################################################################################################################################"
echo "## 																##"
echo "## El script posee dos parámetros de etrada, el directorio que se desea evaluar y el drectorio de salida con su archivo		##"
echo "## Debe ser ejecutado de la siguiente manera:											##"
echo "## ./Ejercicio6.sh "/directorio/de/Entrada/" "/directorio/de/salida/"								##"
echo "## O especificando un archivo existente en dicho directorio:									##"
echo "## ./Ejercicio6.sh "/directorio/de/Entrada/" "/directorio/de/salida/archivoLog"							##"
echo "## ejemplos:  ./Ejercicio6.sh "/home/rodrigo/Escritorio/tp2ejercicio6/" "/home/rodrigo/Escritorio/tp2ejercicio6/"			##"
echo "##		./Ejercicio6.sh "/home/rodrigo/Escritorio/tp2ejercicio6/" "/home/rodrigo/Escritorio/tp2ejercicio6/archivoLog"	##"
echo "## si no se ingresa un directorio de salida para guardar el log, los resultados se mostrarán por pantalla			##"
echo "##																##"
echo "##################################################################################################################################"
exit 1;
}


#Verifico si se pasó como minimo el primer parámetro
if [ ! $parametro ]; then
	echo "Debe ingresar por lo menos el directorio de entrada que desea evaluar";	
	exit 1;
fi 

#Verifico si el primer parámetro es '-?'
if [ $parametro == "-?" ]; then
	ayuda;
fi 

# voy a verificar que no haya otro proceso demonio ejecutándose en el directorio especificado.
function sanityCheck {
    q=`ps -ef | grep "Demonio.sh $parametro" | grep -v grep | awk '{print $2}' | wc -l`;
    if [ "$q" -gt 0 ]; then
        echo "Otra instancia del proceso demonio está corriendo sobre este directorio";
       exit 1;
   fi
}

#Verifico si el directorio de entrada que indiqué existe. y llamo a la funcion que verifica si hay otro demonio sobre el mismo directorio.
if [ ! -d $parametro ]; then

	echo "El directorio de entrada no existe, intente con otro directorio o corrija el que ingresó";
	exit 1;
else 
	sanityCheck;
fi

#Verifico si el directorio o archivo de salida que indiqué existe.
eRegular="./+[A-Za-z0-9]";
if [[ ! -f $parametro2 ]]; then
if [[ ! $eRegular=~$parametro2 || $parametro2=~"$eRegular/" ]]; then
if [[ ! $parametro2 == "" ]]; then
if [[ ! -d $parametro2 ]]; then
	echo "El directorio de salida o archivo no existe, intente con otro directorio o archivo, sino corrija lo que ingresó";
	exit 1;
fi;
fi;
fi;
fi;

chmod 777 Demonio.sh
nohup ./Demonio.sh $parametro $parametro2 >/dev/null 2>&1 &
pid=$!;

echo "Cuando desee eliminar el proceso demonio de este directorio debe escribir: kill -SIGUSR1 $pid";
