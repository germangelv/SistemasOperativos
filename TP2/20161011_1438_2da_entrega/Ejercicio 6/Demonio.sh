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



#parámetros

parametro=$1;
parametro2=$2;
declare -A ht;
declare -A ht2;
declare -A ht3;
cont="0";
bandera="0";
bandera1="0";

#fin parámetros

{ 	
   while [ true ]; do
	
	#bandera para poder sacar el PID de este proceso que se está ejecutando.
	if [ $bandera1 -eq "0" ]; then
	bandera1="1";
	pid=`ps -ef | grep "$0 $parametro" | grep -v "grep" | awk '{print $2}' | head -n1`;	
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
		if [[ ht3[$key] -eq "0" ]]; then
		ht[$key]="${ht[$key]}	("nuevo")"; else
		if [[ ht2[$key] -eq "0" ]]; then
		ht[$key]="${ht[$key]}	("nuevo")"; else
		calculo=$[$v1/ht2[$key]];		
		ht[$key]="${ht[$key]}	(+$calculo%)";fi;fi else
		if [[ "${ht["$key"]}" -lt "${ht2["$key"]}" ]]; then
		cont="0";		
		v1=$[$[ht2[$key]-ht[$key]]*100];

		if [[ ht3[$key] -eq "0" ]]; then
		ht[$key]="${ht[$key]}	("eliminado")"; else

		calculo=$[$v1/${ht2[$key]}];		
		ht[$key]="${ht[$key]}	(-$calculo%)"; fi; fi;
		fi; done;
	 fi

	dia=`date +"%d/%m/%Y"`;
	hora=`date +"%H:%M"`;

	if [[ "0" -eq $cont ]]; then
	cont="1";
	#Muestro el hash Table con su key y su contenido.	
	eRegular="./+[A-Za-z0-9]";
	if [[ -f $parametro2 || $parametro2 =~ $eRegular ]]; then
	for key in "${!ht[@]}"; do
	 echo "$pid	$dia $hora	$key	B: ${ht[$key]}" >> "$parametro2";
	 ht2[$key]=${ht3[$key]}; done;
	else	
	if [[ -d $parametro2 ]]; then
	for key in "${!ht[@]}"; do
	 echo "$pid	$dia $hora	$key	B: ${ht[$key]}" >> "$parametro2"log.txt;
	 ht2[$key]=${ht3[$key]}; done;
	else
	for key in "${!ht[@]}"; do echo "$pid	$dia $hora	$key	B: ${ht[$key]}" >> logPantalla.txt; 
	 ht2[$key]=${ht3[$key]}; done;
	fi;
	fi;
	fi;	
	sleep 30s;

done
} 
