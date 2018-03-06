#!/bin/bash



# Funciones:
ofrecerAyuda(){
echo "para ejecutar correctamente, debe ingresar con el siguiente formato"
echo "./Ej2.sh [-u] o  [-a] o  [-c]
Script para el control de la conexion de los usuarios.
Parametros permitidos:
-u usuario: muestra las conexiones activas de un usuario en particular, si no se indica el usuario se toma al usuario que ejecuto el script.
-a: muestra los usuarios con conexiones activas y la ultima conexion de los usuarios sin conexiones activas.
-c: muestra los usuarios y la cantidad de conexiones que tuvo cada uno. 
Si no se indican parametros trabaja como si se hubiese indicado -a.
Ejemplo 
./Ej2.sh -u pepito
./Ej2.sh -a
./Ej2.sh -c 
"
}
# Fin Funciones;


# Verificacion de paramtros:
parametro="mal";
if(( $# == 0 ))
then 
	parametro="-a";
else
	#veo si el parametro es para pedir ayuda:
	if [ "$1" = "-help" -o "$1" = "-?" -o "$1" = "-h" ]
		then
			ofrecerAyuda
			exit
		fi
	#Veo si el parametro es -u o -a
	if [ "$1" = '-u' -o "$1" = '-a' -o "$1" = '-c' ]
		then
			parametro=$1;		
		fi
	#Si el parametro no es valido no se modifico(sigue "mal") termino el script.
	if [ "$parametro" = "mal" ]
		then
			echo "Parametro incorrecto, obtenga ayuda con -help, -h, o -?"
			exit;
		fi
	#veo si el usuario existe (pendiente)
	if [ $# -ge 2 ]
		then	
			if [ "$1" = "-u" -a $# == 2 ]
			then
				cat /etc/passwd | grep "$2" 1> /dev/null 2>/dev/null && exist=0 || exist=1 #redirecciono salidas comando grep para que no aparezcan en pantalla 
				if [ "$exist" -eq 0 ]
				then
						echo "El usuario existe: $2"
				else
						echo "El usuario "$2" no existe"
						exit;
				fi
			else
				echo "Parametros de sobra, obtenga ayuda con -help, -h, o -?"
				exit;
			fi
		fi
fi

# Fin verificacion de parametros;

if [ "$parametro" = "-a" ]
	then
		escape1="Usuario"
		escape2="Ult. Conexión"
		escape3="Tiempo de Conexión"

		echo $escape1'         '$escape2'             '$escape3
		divider================
		ldivider=========================
		divider=$divider' '$ldivider' '$divider
		echo $divider
		who | awk -F" " '{printf"%-15s Activo en %-15s---\n",$1,$2}'
		last -F | awk  -F " " -f reporte.awk | sed 's/[(,)]//g'

	fi
if [ "$parametro" = "-u"  ]
	then	
		if [ $# == 1 ]
		then 
			user=$(whoami)
		else
			user=$2
		fi

		echo $useruniq
		escape1="Usuario"
		escape2="Ult. Conexión"
		escape3="Tiempo de Conexión"

		echo $escape1'         '$escape2'             '$escape3
		divider================
		ldivider=========================
		divider=$divider' '$ldivider' '$divider
		echo $divider
		
		who | awk -F" "  '/'$user'/ {printf "%-15s    Activo en %-15s---\n", $1,$2}'		
	fi

if [ "$parametro" = "-c" ]
	then
		escape1="Usuario"
		escape2="Cantidad de Conexiones"
		echo $escape1'         '$escape2
		divider================
		ldivider=======================
		divider=$divider' '$ldivider
		echo $divider
	
		last -F |awk -F " " '$1~/^[^(reboot)(wtmp)( )]/ {print $1}' |sort | uniq -c | awk -F" " '{printf "%-15s %-22s\n",$2,$1} '
	
		
	fi

echo "fin"
