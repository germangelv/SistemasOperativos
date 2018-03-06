#!/bin/bash

# *****************************************************
# Trabajo Practico Nº2
# Entrega Nº1
# Fecha 26/09/2016
#
# Ejercicio 5
# Nombre del script: Ejercicio_5.sh
#
#*****************************************************
#
# Integrantes:	
#
# Apellido y nombre            		DNI
#----------------------------------------------
# D'Amico, Rodrigo                  DNI 36.817.422
# Ibarra, Gerardo                   DNI 33.530.202
# Lorenz Vieta, German              DNI 32.022.001
# Matticoli, Martin                 DNI 37.121.122
# Silva, Ezequiel                   DNI 36.404.597         
#
#*****************************************************
# Realizar un script para administrar archivos de configuración de un 
# sistema operativo de la familia Unix.
# El script debe recibir como mínimo tres parámetros: el archivo de 
# configuración a modificar, la clave y por último el nuevo valor.
# Ejemplo de uso:
#      Configurar.sh /etc/archivo.conf INIT “Nuevo Valor”
# Si no existe la clave en el archivo de configuración se la deberá agregar 
# al final del mismo, caso contrario se deberá mostrar el valor actual y 
# solicitar la confirmación del cambio. Esta confirmación no será requerida 
# en caso de que se haya recibido el parámetro -y
# Todos los cambios deberán ser documentados en el mismo archivo de 
# configuración, es decir que cuando se dé de alta el parámetro se deberá 
# documentar el usuario y la fecha y hora en la que se agregó, en cambio si 
# se realiza la modificación se deberá documentar, además de lo anterior, el 
# valor previo al cambio. Los comentarios con esta documentación se deberán 
# encontrar inmediatamente antes de la clave con el valor.
# Si se le envía el parámetro -c, deberá permitir al usuario incluir un 
# comentario adicional, que será agregado junto a la documentación del 
# agregado/cambio de la clave.
# Ejemplo de uso:
#      Configurar.sh /etc/archivo.conf INIT “Nuevo Valor” -c "Comentario mas largo"
# Importante: Tenga en cuenta que no se podrá trabajar en forma directa sobre 
# los archivos de configuración del sistema (ya que no tiene los permisos 
# necesarios), por lo que para realizar la prueba deberá copiarse los 
# archivos que se quiera modificar a su home directory.
#*****************************************************
##FUNCIONES GENERALES
Help(){
	me=`basename "$0"`
	echo "Modo de uso: $me [-y] archivo \"clave\" \"valor\" [-c \"Comentario\"]"
	echo ""
	echo "Debe ingresar los siguientes parametros: "
	echo "---------------------------------------"
	echo "archivo: Ruta del archivo de configuracion (Obligatorio) (los archivos tienen que tener el formato \"Clave=Valor\" para ser reconocidos por la aplicacion"
	echo "clave: Clave a modificar (Obligatorio)"
	echo "valor: Valor de la clave (Obligatorio)"
	echo "-y: No se pedira confirmacion en caso de sobreescribir una clave existente (Opcional)"
	echo "-c comentario: Se puede agregar un comentario extra (Opcional)"
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
REGISTRARCAMBIO(){
	#Calculo el viejo valor
	OldVal=$(grep "^$2" $1 | sed "s/^\($2\)\( *$strConfDelimitadorClave *\)\(.\+\)/\3/")
	if [[ "$OldVal" == "$3" ]] ; then
		if [[ $7 -eq 1 ]] ; then
			echo "CLAVE $2$strConfDelimitadorClave$3 NO MODIFICADA, LA CLAVE YA TIENE DICHO VALOR"
		fi
	else
		#Pregunto si autorizo cambio
		blCambiar=0
		if [[ $4 -eq 1 ]] ; then
			blCambiar=1
		else
			echo "Desea cambiar el valor de la clave $2 a $3 (sobreescribiendo el antiguo valor $OldVal)? (S/N): "
			read respuesta
			if [[ "$respuesta" == "Y" ]] ||  [[ "$respuesta" == "y" ]] ||  [[ "$respuesta" == "S" ]] ||  [[ "$respuesta" == "s" ]] ; then
				blCambiar=1
			fi
		fi
		if [[ blCambiar -eq 0 ]] ; then
			echo "CLAVE $2$strConfDelimitadorClave$3 NO MODIFICADA, CANCELADA POR EL USUARIO CONSERVA $2$strConfDelimitadorClave$OldVal"
		else
			#Actualizo el valor
			sed -i "s/^\($2\)\( *$strConfDelimitadorClave *\)\(.*\+\)/$strConfComentario\1\2\3\n\1\2$3/" $1
			#Documento la modificacion
			DOCUMENTAR "$1" "$2" "$3" 1 $OldVal $5 "$6" $7
			if [[ $7 -eq 1 ]] ; then
				echo "CLAVE $2$strConfDelimitadorClave$3 MODIFICADA (antes $2$strConfDelimitadorClave$OldVal)"
			fi
		fi
	fi
}

REGISTRARNUEVACLAVE(){
	#Agrego la clave al final
	echo "$2$strConfDelimitadorClave$3">>$1
	#Documento la modificacion
	DOCUMENTAR "$1" "$2" "$3" 0 "" $5 "$6" $7
	if [[ $7 -eq 1 ]] ; then
		echo "CLAVE $2$strConfDelimitadorClave$3 AGREGADA"
	fi
}

DOCUMENTAR(){
	TEXTSCRIPT="[AutoConfig]"
	TEXTSUSER="[Usuario]"
	USER=$(whoami)
	FECHA=$(date +"%Y-%m-%d %T")
	strModificacion=""
	if [[ $4 -eq 1 ]] ; then
		#Agrego antes datos de lo anteriormente modificado
		sed -i "s/^\($strConfComentario$2 *$strConfDelimitadorClave *$5\)/$strConfComentario$TEXTSCRIPT - Fecha: $FECHA - Usuario: $USER - Modificacion: CLAVE MODIFICADA, VALOR ANTIGUO (COMENTADO) \n\1/" $1
	fi
	if [[ $4 -eq 1 ]] ; then
		strModificacion="CLAVE MODIFICADA, VALOR NUEVO"
	else
		strModificacion="CLAVE AGREGADA"
	fi
	strComentarioAdicional=""
	if [[ $6 -eq 1 ]] ; then
		strComentarioAdicional="\n$strConfComentario$TEXTSUSER - $7"
	fi
	#Agrego antes datos de lo anteriormente modificado
	sed -i "s/^\($2 *$strConfDelimitadorClave *$3\)/$strConfComentario$TEXTSCRIPT - Fecha: $FECHA - Usuario: $USER - Modificacion: $strModificacion$strComentarioAdicional\n\1/" $1
}

################################################################################
#Limpio pantalla
#clear

#Variables Globales
blDebug=0
strConfDelimitadorClave="="
strConfComentario="#"
#Chequeo parametros de linea de comandos
if [[ "$1" == "--help" ]] ; then
	echo AYUDA
	Help
fi
if [[ "$1" == "-?" ]] ; then
	Help
fi
if [[ $# -eq 0 ]] ; then
	Help
fi

blNoConfirmar=0
blComentario=0
strComentario=""
strArchivo=""
strClave=""
strValor=""
intParametro=0
strParametroSiguiente=""
for var in "$@" ; do
	if [[ "$strParametroSiguiente" == "" ]] ; then
		#Flags
		if [[ "$var" == "-y" ]] ; then
			blNoConfirmar=1
			strParametroSiguiente=""
		elif [[ "$var" == "-c" ]] ; then
			blComentario=1
			strParametroSiguiente="Comentario"
		#Parametros
		elif [[ $intParametro == 0 ]] ; then
			strArchivo=$var
			intParametro=$(($intParametro+1))
			strParametroSiguiente=""
		elif [[ $intParametro -eq 1 ]] ; then
			strClave=$var
			intParametro=$(($intParametro+1))
			strParametroSiguiente=""
		elif [[ $intParametro == 2 ]] ; then
			strValor=$var
			intParametro=$(($intParametro+1))
			strParametroSiguiente=""
		else
			echo "Error: cantidad de parametros incorrecta."
			Help
		fi
	else
		#Parametro posterior a Flag
		if [[ "$strParametroSiguiente" == "Comentario" ]] ; then
			strComentario=$var
		else
			echo "Error: valor flag."
		fi
		strParametroSiguiente=""
	fi
done

if [[ $intParametro != 3 ]] ; then
	echo "Error: cantidad de parametros incorrecta."
	Help
fi

if [[ $strArchivo == "" ]] || [[ $strClave == "" ]] || [[ $strValor == "" ]] ; then
	echo "Error: cantidad de parametros incorrecta."
	Help
fi

if [[ $blComentario -eq 1 ]] && [[ $strComentario == "" ]] ; then
	echo "Error: valor flag comentario."
	Help
fi

if [[ $blDebug -eq 1 ]] ;then
	echo "Parametros ejecucion:"
	echo "  Archivo: "$strArchivo
	echo "  Clave: "$strClave
	echo "  Valor: "$strValor
	echo "  NoConfirmar: "$blNoConfirmar
	echo "  HayComentario: "$blComentario
	if [[ $blComentario -eq 1 ]] ; then
		echo "    Comentario: "$strComentario
	fi
	echo ""
fi

#Chequea que el archivo sea valido
esArchivo $strArchivo 0

#Guardo el nombre del archivo (sin la ruta)
strArchivoNombre=$(basename $strArchivo)
#Genero la ruta de un nuevo archivo temporal para no modificar el archivo original
strNewArchivo=/tmp/$strArchivoNombre


#Chequea que el archivo sea valido para escribir
if [[ ! -r $strArchivo ]] ; then
	echo "Error: No se tienen permisos de lectura sobre el archivo $strArchivo."
	exit 1
	#Help
fi
if [[ ! -w $strArchivo ]] ; then
	echo "Error: No se tienen permisos de escritura sobre el archivo $strArchivo."
	exit 1
	#Help
fi

#Chequeo el archivo temporal
if [[ -f $strNewArchivo ]] ; then
	rm $strNewArchivo
fi

#Copio el archivo en el archivo temporal
cp $strArchivo $strNewArchivo

blClaveEncontrada=0
#Busca que exista la clave
blClaveEncontrada=$(grep "^$strClave *$strConfDelimitadorClave" $strNewArchivo | wc -l)
blDebug=1
if [[ $blClaveEncontrada -gt 0 ]] ; then
	#Si existe la clave la cambia
	REGISTRARCAMBIO "$strNewArchivo" "$strClave" "$strValor" $blNoConfirmar $blComentario "$strComentario" $blDebug
else
	#Si no existe la clave la crea al final
	REGISTRARNUEVACLAVE "$strNewArchivo" "$strClave" "$strValor" 0 $blComentario "$strComentario" $blDebug
fi

#Intenta sobreescribir el archivo
cp $strNewArchivo $strArchivo &> /dev/null
if [ $? -ne 0 ]; then
	echo "Warning: No se pudo reemplazar el archivo $strArchivo, compruebe que tiene permisos de escritura"
fi
rm $strNewArchivo
