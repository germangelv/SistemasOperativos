#!/bin/bash

# *****************************************************
# Trabajo Practico Nº2
# Entrega Nº1
# Fecha 26/09/2016
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

# Funciones.

#Ayuda
function ayuda {
echo " "
echo "AYUDA"
echo "#####################################################################################################################"
echo "##														   ##"
echo "## El script debe ser ejecutado de la siguiente manera:								   ##"
echo "## ./Ejercicio6.sh "/directorio/de/Entrada/" "/directorio/de/salida/"&						   ##"
echo "## el caracter '&' al final indica que el proceso se va a quedar ejecutando en segundo plano			   ##"
echo "## ejemplo:  ./Ej6Corregido.sh "/home/rodrigo/Escritorio/tp2ejercicio6/" "/home/rodrigo/Escritorio/tp2ejercicio6/"&    ##"
echo "## si no se ingresa un directorio de salida para guardar el log, los resultados se mostrarán por pantalla	   ##"
echo "##														   ##"
echo "#####################################################################################################################"
exit 1;
}

# voy a verificar que no haya otro proceso demonio ejecutándose en el directorio especificado.
function sanityCheck {
    q=`ps -ef | grep "$0 $parametro" | grep -v grep | awk '{print $2}' | wc -l`;
    if [ "$q" -gt "2" ]; then
        echo "Otra instancia del proceso demonio está corriendo sobre este directorio";
       exit 1
   fi
}
#Cuando de por linea de comandos escriba: 'kill -SIGUSR1 pid_del_proceso' el trap ejecutara esta funcion.
function signal_SIGUSR1 {
 
    echo "Se recibio la señal USR1, proceso finalizado";
    kill -9 "$pid";
} 

# Fin Funciones.

parametro=$1;
parametro2=$2;
declare -A ht;
declare -A ht2;
declare -A ht3;
cont="0";
bandera="0";
bandera1="0";

#Verifico si el primer parámetro es '-?'
if [ $parametro == "-?" ]; then
	ayuda;
fi 

#Verifico si el directorio de entrada que indiqué existe. y llamo a la funcion que verifica si hay otro demonio sobre el mismo directorio.
if [ -d $parametro ]; then
	sanityCheck;
else 
	echo "el directorio no existe, intente con otro directorio o corrija el que ingresó";
	exit 1;
fi

#Verifico si el directorio de salida que indiqué existe.
if [ ! -d $parametro2 ]; then
	echo "el directorio de salida no existe, intente con otro directorio o corrija el que ingresó";
	exit 1;
fi



{ 	
   while [ true ]; do
	
	#bandera para poder sacar el PID de este proceso que se está ejecutando y poder informarlo para acabar con el proceso.
	if [ $bandera1 -eq "0" ]; then
	bandera1="1";
	pid=`ps -ef | grep "$0 $parametro" | grep -v "grep" | awk '{print $2}' | head -n1`;
	
	#Esta es la espera de la de la señal SIGUSR1, cuando llegue se ejecuta la funcion 'signal_SIGUSR1'
	trap signal_SIGUSR1 SIGUSR1;
	
	echo "cuando desee eliminar el proceso demonio de este directorio debe escribir: kill -SIGUSR1 $pid";	
	
	fi

	#en cada posición del vector voy a guardar una extension.
	miVector=("${miVector[@]}" $(find $parametro -type f -exec sh -c 'basename $0 | sed "s/.*\.//"' {} \; | sort | uniq))

	#por cada extension que esté en el vector voy a buscar en el directorio cada una del mismo tipo y sumarlas, para guardarlas en un hash table.
	for ((i=0;i<${#miVector[@]};i++)){ 

	suma="$(find $parametro -iname "*.${miVector[i]}" -exec stat -c %s {} \; | awk '{ sum += $1 } END { printf "%d \n", sum }')";
	ht[${miVector[i]}]=$suma;

	};
	#este if es el encargado de poner los porcentajes que se pondrán cuando se modifique alguno de los tamaños de archivo.
	 if [[ $bandera -eq "0" ]]; then
		bandera="1";
		for key in "${!ht[@]}"; do ht2[$key]=${ht[$key]}; ht3[$key]=${ht[$key]}; done
		else 
		for key in "${!ht[@]}"; do	 
		ht3[$key]=${ht[$key]};
		if [[ "${ht["$key"]}" -gt "${ht2["$key"]}" ]]; then
		cont="0";
		v1=$[$[ht[$key]-ht2[$key]]*100];
		if [[ ht2[$key] -eq "0" ]]; then
		ht[$key]="${ht[$key]}	("nuevo")"; else
		calculo=$[$v1/ht2[$key]];		
		ht[$key]="${ht[$key]}	(+$calculo%)";fi else
		if [[ "${ht["$key"]}" -lt "${ht2["$key"]}" ]]; then
		cont="0";		
		v1=$[$[ht2[$key]-ht[$key]]*100];

		if [[ ht[$key] -eq "0" ]]; then
		ht[$key]="${ht[$key]}	("eliminado")"; else

		calculo=$[$v1/${ht2[$key]}];		
		ht[$key]="${ht[$key]}	(-$calculo%)"; fi; fi;
		fi; done;
	 fi

	dia=`date +"%d/%m/%Y"`;
	hora=`date +"%H:%M"`;

	if [[ "0" -eq $cont ]]; then
	cont="1";
	#Muestro el hash Table con su key y su contenido, en el archivo o por pantalla.
	if [[ -d $parametro2 ]]; then
	for key in "${!ht[@]}"; do
	 echo "$pid	$dia $hora	$key	KB: ${ht[$key]}" >> "$parametro2"log.txt;
	 ht2[$key]=${ht3[$key]}; done;
	else
	for key in "${!ht[@]}"; do echo "$pid	$dia $hora	$key	KB: ${ht[$key]}"; ht2[$key]=${ht3[$key]}; done;
	fi;
	fi	
	sleep 30s;

done
} 
