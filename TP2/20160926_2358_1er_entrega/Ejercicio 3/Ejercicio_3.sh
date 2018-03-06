#!/bin/bash

# *****************************************************
# Trabajo Practico Nº2
# Entrega Nº1
# Fecha 26/09/2016
#
# Ejercicio 3
# Nombre del script: Ejercicio_3.sh
#
#*****************************************************
#
# Integrantes:  
#
# Apellido y nombre               DNI
#----------------------------------------------
# D'Amico, Rodrigo                  DNI 36.817.422
# Ibarra, Gerardo                   DNI 33.530.202
# Lorenz Vieta, German              DNI 32.022.001
# Matticoli, Martin                 DNI 37.121.122
# Silva, Ezequiel                   DNI 36.404.597         
#
#*****************************************************
# Realizar un script que genere un reporte de la cantidad de archivos 
# ejecutables de un directorio para el usuario conectado (no se debe actuar 
# sobre los links).
# Podrá recibir 4 parámetros, no obligatorios:
#    -d directorio: es el directorio a analizar, en caso de no enviarlo 
#                   utilizará la variable PATH.
#    -s archivo: es el archivo de salida de la información, con el siguiente 
#                formato: ruta/archivo (Tenga en cuenta que la ruta puede ser 
#                absoluta o relativa).
#    -y: deberá informar por cada directorio, los subtotales de cantidad de 
#        ejecutables por año.
#    -r: debe analizar también los subdirectorios, si existieran. En caso de 
#        no recibirlo solo analizara el directorio especificado sin subdirectorios.
# Ejemplos de salida:
#     Salida para la variable PATH:
#       Usuario: cagarcia – Directorios analizados de PATH.
#       Cantidad total de comandos disponibles: 1500
#       Detalle de comandos disponibles por directorio:
#           /home/cagarcia/bin: 3
#           /usr/bin: 1403
#           /bin: 94
#     Salida para la variable PATH (con parámetro -y):
#       Usuario: cagarcia – Directorios analizados de PATH.
#       Cantidad total de comandos disponibles: 1500
#       Detalle de comandos disponibles por directorio:
#           /home/cagarcia/bin: 2014: 3
#           /usr/bin: 2013: 900
#                     2014: 183
#                     2015: 320
#           /bin: 2012: 54
#                 2015: 40
#     Salida para directorio /HOME/…./usuario:
#       Usuario: cagarcia – Directorio analizado: /HOME/…./usuario.
#       Cantidad total de comandos disponibles: 150
#     Salida para directorio /HOME/…./usuario (con parámetro -r):
#       Usuario: cagarcia – Directorio analizado: /HOME/…./usuario.
#       Cantidad total de comandos disponibles: 150
#       Detalle de comandos disponibles por directorio:
#         … /desktop: 5
#         … /dowload: 95
#         …/documents: 50
#
#*****************************************************
##FUNCIONES GENERALES
Help(){
	me=`basename "$0"`
	echo "Modo de uso: $me [-d directorio] [-s arhivoSalida] [-y] [-r]"
	echo ""
	echo "Debe ingresar los siguientes parametros: "
	echo "---------------------------------------"
	echo "-d directrio: Ruta del directorio a anlizar (Opcional o PATH)"
	echo "s archivoSalida: Ruta del archivo de salida del reporte (Opcional o por Pantalla)"
	echo "-y: Se hará el reporte desagregando por anio (Opcional)"
	echo "-r: Se hará el reporte analizando el directorio de manera recursiva (Opcional)"
	exit 1 #Fin de ejecucion del Programa
}

esArchivo(){
	#Verificamos que sea un archivo regular
	if [[ ! -f $1 ]] ; then
	echo "Error: No se encontro el archivo $1."
		if [[ $2 -eq 1 ]] ; then
			Help
		else
			exit 1
		fi
	fi

	return 0
}
esDirectorio(){
	#Verificamos que sea un directorio
	if [[ ! -d $1 ]] ; then
		echo "Error: No se encontro el directorio $1."
		if [[ $2 -eq 1 ]] ; then
			Help
		else
			exit 1
		fi
	fi

	return 0
}

########################
BUSCAREXECUTABLES(){
	strTmpFlagRecursiveFind=""
	
	if [[ $2 -eq 1 ]] ; then
		if [[ $blDebug -eq 1 ]] ; then
			echo "-$1"
		fi
		OLDIFS=$IFS
		IFS=$'\n'
		for subdir in `find "$1" -type d` ; do
			if [[ $blDebug -eq 1 ]] ; then
				echo "+$subdir"
			fi
			BUSCAREXECUTABLESDIR "$subdir"
		done
		IFS=$OLDIFS
	else
		if [[ $blDebug -eq 1 ]] ; then
			echo "-$1"
		fi
		BUSCAREXECUTABLESDIR "$1"
	fi
}

BUSCAREXECUTABLESDIR(){
	if [[ $blReporteYear -eq 0 ]] ; then
		numlines=$(find "$1" -maxdepth 1 -executable -type f | wc -l)
		intCantTotal=$(($numlines + $intCantTotal))
		hshDirReporte["$1"]=$numlines
		arrDirReporteOrder+=("$1")
	else
		OLDIFS=$IFS
		IFS=$'\n'
		for file in `find "$1" -maxdepth 1 -executable -type f -ls` ; do
			IFS=$' '
			read -r -a arrFileFields <<< "$file"
			IFS=$'\n'
			if [[ $blDebug -eq 1 ]] ; then
				#echo " ->$file"
				echo " ->${arrFileFields[9]} - ${arrFileFields[10]}"
			fi
			strAnio=$strAnioActual
			if [[ ${arrFileFields[9]} != *":"* ]] ; then
				strAnio=${arrFileFields[9]}
			fi
			intCantTotal=$(($intCantTotal + 1))
			if [[ -z ${hshDirReporte["${1}?${strAnio}"]} ]] ; then 
				arrDirReporteOrder+=("${1}?${strAnio}")
			fi
			hshDirReporte["${1}?${strAnio}"]=$((${hshDirReporte["${1}?${strAnio}"]} + 1))
		done
		IFS=$' '
	fi
}

################################################################################
#Limpio pantalla
clear

#Variables Globales
blDebug=0
#Chequeo parametros de linea de comandos
if [[ "$1" == "--help" ]] ; then
	echo AYUDA
	Help
fi
if [[ "$1" == "-?" ]] ; then
	Help
fi

strDirectorio=""
strArchivoSalida=""
blDirectorio=0
blArchivoSalida=0
blReporteYear=0
blReporteRecursivo=0
intParametro=0
strParametroSiguiente=""
strAnioActual=$(date +'%Y')
for var in "$@" ; do
	if [[ "$strParametroSiguiente" == "" ]] ; then
		#Flags
		if [[ "$var" == "-d" ]] ; then
			blDirectorio=1
			strParametroSiguiente="Directorio"
		elif [[ "$var" == "-s" ]] ; then
			blArchivoSalida=1
			strParametroSiguiente="ArchivoSalida"
		elif [[ "$var" == "-y" ]] ; then
			blReporteYear=1
			strParametroSiguiente=""
		elif [[ "$var" == "-r" ]] ; then
			blReporteRecursivo=1
			strParametroSiguiente=""
		#Parametros
		# elif [[ $intParametro == 0 ]] ; then
		# 	str=$var
		# 	intParametro=$(($intParametro+1))
		# 	strParametroSiguiente=""
		 else
		 	echo "Error: cantidad de parametros incorrecta."
		 	Help
		fi
	else
		#Parametro posterior a Flag
		if [[ "$strParametroSiguiente" == "Directorio" ]] ; then
			strDirectorio=$var
		elif [[ "$strParametroSiguiente" == "ArchivoSalida" ]] ; then
			strArchivoSalida=$var
		else
			echo "Error: valor flag."
		fi
		strParametroSiguiente=""
	fi
done

if [[ $intParametro != 0 ]] ; then
	echo "Error: cantidad de parametros incorrecta."
	Help
fi

if [[ $blDirectorio -eq 1 ]] && [[ $strDirectorio == "" ]] ; then
	echo "Error: valor flag directorio."
	Help
fi

if [[ $blArchivoSalida -eq 1 ]] && [[ $strArchivoSalida == "" ]] ; then
	echo "Error: valor flag archivosalida."
	Help
fi

if [[ $blDebug -eq 1 ]] ; then
	echo "Parametros ejecucion:"
	echo "  ConDirectorio: "$blDirectorio
	if [[ $blDirectorio -eq 1 ]] ; then
		echo "    Directorio: "$strDirectorio
	else
		echo "    PATH: "$PATH
	fi
	echo "  ConSalida: "$blArchivoSalida
	if [[ $blArchivoSalida -eq 1 ]] ; then
		echo "    ArchivoSalida: "$strArchivoSalida
	fi
	echo "  ConYear: "$blReporteYear
	echo "  ConRecursividad: "$blReporteRecursivo
	echo ""
fi

if [[ ! -z "$strDirectorio" ]] ; then
	esDirectorio "$strDirectorio" 1
fi

if [[ ! -z "$strArchivoSalida" ]] ; then
	if [[ -d "$strArchivoSalida" ]] ; then
		echo "Error: el archivo de salida es un directorio"
		exit
	elif [[ -f "$strArchivoSalida" ]] ; then
		rm "$strArchivoSalida" &> /dev/null
		if [ $? -ne 0 ]; then
			echo "Error: No se pudo eliminar el archivo $strArchivoSalida, compruebe que tiene permisos de escritura"
			exit
		fi
	fi
	touch "$strArchivoSalida" &> /dev/null
	if [ $? -ne 0 ]; then
		echo "Error: No se pudo crear el archivo $strArchivoSalida, compruebe que tiene permisos de escritura"
		exit
	fi
fi

#if [[ ! -z "$strArchivoSalida" ]] ; then
#	esArchivo "$strArchivoSalida" 1
#fi

##################################################
currentUser=$(whoami);  # usuario actual
intCantTotal=0
declare -A hshDirReporte
declare -A arrDirReporteOrden=()
if [[ ! -z "$strDirectorio" ]] ; then
	dir=( "$(readlink -f "$strDirectorio")" )
else
	dir=( $(echo $PATH | sed s/:/\\n/g) )
fi

for k in "${!dir[@]}" ; do
	if [[ -d "${dir[$k]}" ]] ; then
		BUSCAREXECUTABLES "${dir[$k]}" $blReporteRecursivo
	fi
done

##################################################
# Imprimiendo informe
strOut=/dev/stdout
if [[ ! -z "$strArchivoSalida" ]] ; then # comprobacion de cadena vacia
	strOut="$(readlink -f "$strArchivoSalida")"
fi
echo "******** INFORME ********">>$strOut
echo "">>$strOut
echo "Usuario: $currentUser">>$strOut
strDirectorioFinal=""
if [[ ! -z "$strDirectorio" ]] ; then
	strDirectorioFinal="$strDirectorio"
else
	strDirectorioFinal="{\$PATH}"
fi
echo "Cantidad de comandos disponibles en $strDirectorioFinal: $intCantTotal">>$strOut
echo "">>$strOut
if [[ blReporteRecursivo -eq 1 ]] || [[ $blReporteYear -eq 1 ]] ; then
	echo "Detalle de comandos disponibles:">>$strOut
	strTmpDir=""
	strTmpYear=""
	strTmpKey=""
	IFS=$' '
	for k in "${arrDirReporteOrder[@]}" ; do
		if [[ $blReporteYear -eq 0 ]] ; then
			echo -e "\t$k: ${hshDirReporte[$k]}">>$strOut
		else
			strTmpKey="$k"
			IFS=$'?'
			read -r -a arrTmpKeyYear <<< "$strTmpKey"
			IFS=$' '
			if [[ $strTmpDir != "${arrTmpKeyYear[0]}" ]] ; then
				strTmpDir="${arrTmpKeyYear[0]}"
				echo -e "\t$strTmpDir:">>$strOut
			fi
			strTmpYear="${arrTmpKeyYear[1]}"
			echo -e "\t\t$strTmpYear: ${hshDirReporte[$k]}">>$strOut
		fi
	done
fi
echo "">>$strOut
