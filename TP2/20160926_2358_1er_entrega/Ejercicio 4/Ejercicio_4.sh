#!/bin/bash

# *****************************************************
# Trabajo Practico Nº2
# Entrega Nº1
# Fecha 26/09/2016
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
	echo ""
	echo "Debe ingresar los siguientes parametros opionales: "
	echo "--------------------------------------------------"
	echo "-d fecha:Nombre de archivo de venta diario a analizar"
	echo "-m fecha: Fecha con formato mm-aaaa para indicar mes y año del Reporte"
	echo "-c codigo_de_cliente: Codigo numerico del cliente a realizar Reporte"
	echo "Nota: Los archivos ventas-dd.mm.aaaa deben situarse en el directorio del script"
	echo "Asumimos que la verificacion de archivo de ventas es sobre texto"
	echo "Todos los Ejemplos se desarrollaron con una Herramientas Generadora en Java"
	echo "Los Ejemplos tienen importe 30 todos y son 5 de cada cliente con codigo del 1 al 5"
	exit 1 #Fin de ejecucion del Programa
}

esArchivo(){		# Verificamos que sea un archivo regular				OJOJOJOJOJOJJOJ
	
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

# Validaciones

# Verificamos que si no tiene parametros se pone el mes actual
if test $# = 0;	then
	mes=`date +"%m"`
	anio=`date +"%Y"`
fi

# Verificamos que sea una Help
if test $# = 1;	then
	if test $1 = "-?" || test $1 = "-help" || test $1 = "-h"; 	then 
  		Help
	fi
fi
# Verificamos que sea una fecha valida
	antiguoIFS="$IFS"
	IFS='-'
	lines=( $1 )
	IFS="$antiguoIFS"
	contador1=0
	for line in "${lines[@]}"
		do
			echo $line
			if [[ $contador1 == 0 && ($line -gt 0 && $line -le 12) ]]; then
				echo "Error: El mes ingresado es invalido"
				Help
			else
			# Cargo Dia
				mes=$linea
			fi
			if [[ $contador1 == 1 && ($line -ge 2016) ]]; then
				echo "Error: El anio ingresado es invalido"
				Help
			else
			# Cargo Ano
				anio=$linea
			fi
			contador1=$((var+1))
			echo $contador1 
	done
# Verificamos Si tiene otro parametro y si es numero el Numero de Cliente
if [[ $# == 3 ]];	then
	echo "hola"
  	es_numero='^[0-9]+$'
	if ! [[ $3 == $es_numero ]] ; then
	   echo "ERROR: No es un numero"
	   exit 1
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

if test $# = 2;	then
	# mes y anio
#############################################################################################
	for archivo in "${archivos[@]}"
		do
		mesarchivo=`expr substr $archivo 11 2`
		anioarchivo=`expr substr $archivo 14 4`
		if  [[ $mes =~ $mesarchivo && $anio =~ $anioarchivo ]] ; then
			# proceso awk
			# 20:55:33|21|1|163|30,00
			# 	1	   2  3  4	5
			cat $archivo | awk -v FS="|" '
			BEGIN{ float ventatotalporcliente=0; } 
			{ 
				if( $3 ==  cod_cliente)
					ventatotalporcliente+=$5;
			}
			END {
				printf"Ventas totales = \t%.2f",$ventatotalporcliente
			}' >> temp.txt
		fi
	done
fi
#############################################################################################

if test $# = 3;	then
	# codigo de cliente $2
	# mes y anio
	# codigo cliente

#############################################################################################
	for archivo in "${archivos[@]}"
		do
		mesarchivo=`expr substr $archivo 11 2`
		anioarchivo=`expr substr $archivo 14 4`
		if  [[ $mes =~ $mesarchivo && $anio =~ $anioarchivo ]] ; then
			# proceso awk
			# 20:55:33|21|1|163|30,00
			# 	1	   2  3  4	5
			cat $archivo | awk -v cod_cliente=$2 -v FS="|" '
			BEGIN{ float ventatotalporcliente=0; } 
			{ 
				if( $3 ==  cod_cliente){
					ventatotalporcliente+=$5;
					printf"\t%s\t%s\t%s\t%s\n",$1,$2,$3,$5
				}
			}
			END {
				printf"Ventas totales = \t%.2f",$ventatotalporcliente
			}' >> temp.txt
		fi
	done
fi
#############################################################################################d