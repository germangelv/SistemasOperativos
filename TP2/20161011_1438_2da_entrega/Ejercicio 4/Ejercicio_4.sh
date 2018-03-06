#!/bin/bash
# *****************************************************
# Trabajo Practico Nº2
# Entrega Nº2
# Fecha 12/10/2016
#
# Ejercicio 4
# Nombre del script: Ejercicio_4.sh
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
#
# El sistema de facturación de una PyME guarda los registros de sus ventas en archivos diarios.
# El nombre de los archivos mantiene el siguiente formato: ventas-dd.mm.aaaa (por ejemplo: ventas-29.02.2016)
# Cada registro posee datos de la factura realizada y del cliente, organizados en la estructura que se muestra a continuación:
# Hora|Codigo De Factura|Codigo De Cliente|Razon Social|Importe
# (ej.: 13:00:00|543|3|Jose Perez|145,60 )
# Se requiere un script que obtenga un reporte de venta total del mes (opción -m). Este reporte puede recibir como valor, 
# una fecha en formato mm/aaaa. De no recibirlo, se realizará el reporte del mes en curso.
# Así mismo, debe poder obtenerse un reporte de venta detallada de un cliente (opción -c) para el mes actual.
# Se recibirá como valor el código del cliente y se deberá obtener un reporte que especifique cada compra realizada por el cliente, 
# mostrando todos los datos que existan de la operación (incluyendo la fecha)
#
#*****************************************************
##FUNCIONES GENERALES
Help(){				# Funcion para mostrar ayuda
	me=`basename "$0"`
	echo "Modo de uso: $me [-m fecha] [-c codigo_de_cliente]"
	echo "Debe ingresar los siguientes parametros opionales: "
	echo "--------------------------------------------------"
	echo "-m fecha: Fecha con formato mm-aaaa para indicar mes y anio del Reporte"
	echo "-c codigo_de_cliente: Codigo numerico del cliente a realizar Reporte"
	echo ""
	echo "Ejemplo: ./Ejercicio_4.sh"
	echo "Ejemplo: ./Ejercicio_4.sh -m 09-2016"
	echo "Ejemplo: ./Ejercicio_4.sh -c 1"
	echo "Ejemplo: ./Ejercicio_4.sh -m 09-2016 -c 1"
	echo ""
	echo "Nota: Los archivos ventas-dd.mm.aaaa deben situarse en el directorio del script"
	echo "Asumimos que la verificacion de archivo de ventas es sobre texto"
	echo "Todos los Ejemplos se desarrollaron con una Herramientas Generadora en Java"
	echo "Los Ejemplos tienen importe 30 todos y son 40 repeticiones de cada cliente"
	echo "con codigo del 1 al 5 asi el monto de Ventas da 6000 y el monto por cliente 1200"
	echo
	exit 1 #Fin de ejecucion del Programa
}
esFecha(){
antiguoIFS="$IFS"
IFS='-'
lines=( $fechaComprobable )
IFS="$antiguoIFS"

if [ ${lines[0]} -gt 0 ] && [ ${lines[0]} -le 12 ]; then
	mes=${lines[0]}
else
	echo "Error: El mes ingresado es invalido"
	Help
fi
if [ ${lines[1]} -ge 2016 ]; then
	anio=${lines[1]}
else
	echo "Error: El anio ingresado es invalido"
	Help
fi
}

esCliente(){
if ! [[ $cliente -gt 0 ]] ; then
	echo "Error de Codigo de Cliente"
	Help
fi
}
# Validaciones

# Cuatro Parametros
tipoDeSalida=1
if [[ $# == 4 ]] ; then
	if [ $1 == "-m" ] && [ $3 == "-c" ] ; then
		if [[ $2 =~ [0-9][0-9]-[0-9][0-9][0-9][0-9] ]]; then
			if expr "$4" : '-\?[0-9]\+$' >/dev/null ; then 
				fechaComprobable=$2
				cliente=$4
				esFecha
				esCliente
				tipoDeSalida=2
			fi
		fi
	fi
else
	# Dos Parametros
	if [[ $# == 2 ]] ; then
		flagParametros=0
		# Verificamos Parametro -m
		if [[ $1 == "-m" ]] ; then
			if [[ $2 =~ [0-9][0-9]-[0-9][0-9][0-9][0-9] ]] ; then
				fechaComprobable=$2
				esFecha;
			else
				flagParametros=1
				echo "Error: Valores -m incorrectos"
				Help
			fi
		else
			# Verificamos Parametro -c
			if [ $1 == "-c" ] ; then
				# if [[ "$2" =~ '^?[0-9]+$' ]] ; then
				if expr "$2" : '-\?[0-9]\+$' >/dev/null ; then
					cliente=$2
					esCliente
					tipoDeSalida=2
				else
					echo "Error: Valores -c incorrectos"
					Help
				fi
			fi
		fi	
	else
		# Un Parametros
		# Verificamos que sea una Help
		# if test $# = 1 && ( test $1 = "-?" || test $1 = "-help" || test $1 = "-h") ; 	then 
		if [[ $# == 1 && ( $1 == "-?" || $1 == "-help" || $1 == "-h") ]] ; then
			Help
		else
			# Verificamos sin parametros
			if [[ $# == 0 ]] ; then
					mes=`date +"%m"`
					anio=`date +"%Y"`
			else
				echo "Cantidad de Parametros incorrecta o valores incorrectos"
				Help
			fi
		fi
	fi
fi

# Busco los archivos de Ventas en el directorio del Script
archivos=($(ls ventas-*))
# Validacion de archivos de texto con Reportes diarios
for archivo in "${archivos[@]}"
	do
	cant=`(file --mime-type $archivo) | cut -d " " -f 2`   
	if [[ $cant != text/plain ]]
	then
		echo "Error en el tipo de archivo de Ventas"
		Help
	  exit 0;
	fi 
done

# Proceso
if [[ $tipoDeSalida == 1 ]]; then
	for archivo in "${archivos[@]}"
		do
		mesArchivo=`expr substr $archivo 11 2`
		anioArchivo=`expr substr $archivo 14 4`
		if  [[ $mes =~ $mesArchivo && $anio =~ $anioArchivo ]] ; then
			# proceso awk
			# 20:55:33|21|1|163|30,00
			# 	1	   2  3  4	5
			cat $archivo | tr ',' '.' | awk -v file=$archivo -v FS="|" '
			BEGIN{ ventaTotal=0
					printf"Correspondiente al dia de %s\n",file
			} 
			{ 
					ventaTotal += $5
			}
			END {
				printf"Ventas Totales = %.2f\n\n",ventaTotal
			}' >> Ventas.txt
		fi
	done
else
	for archivo in "${archivos[@]}"
		do
		mesArchivo=`expr substr $archivo 11 2`
		anioArchivo=`expr substr $archivo 14 4`
		# proceso awk
		# 20:55:33|21|1|163|30,00
		# 	1	   2  3  4	5
		cat $archivo | tr ',' '.' | awk -v cod_cliente=$cliente -v file=$archivo -v FS="|" '
		BEGIN{ ventaTotalPorCliente=0
				printf"Correspondiente al dia de %s\n\t\tHORA\t\tFACTURA\t\tCODIGO\t\tIMPORTE\n",file
		} 
		{ 
			if( $3 ==  cod_cliente){
				ventaTotalPorCliente += $5
				printf"\t%8s\t|%8s\t|%8s\t|%8s\n",$1,$2,$3,$5
			}
		}
		END {
			printf"Ventas Totales del Cliente %s = \t%.2f\n\n",cod_cliente,ventaTotalPorCliente
		}' >> Ventas_por_cliente_$cliente.txt
	done
fi