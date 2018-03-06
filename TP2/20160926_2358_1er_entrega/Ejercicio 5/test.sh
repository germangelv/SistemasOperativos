#!/bin/bash

clear
./Ejercicio_5.sh ./test/test.conf clave0 valor0
echo "Continuar..."
read
clear
./Ejercicio_5.sh -y ./test/test.conf clave0 valor1
echo "Continuar..."
read
clear
./Ejercicio_5.sh -c "Cambio de nuevo" ./test/test.conf clave0 valor2
echo "Continuar..."
read

clear
./Ejercicio_5.sh -c "Agrego clave, reconoce los comentarios" -y ./test/test.conf clave1 valor0
echo "Continuar..."
read
clear
./Ejercicio_5.sh -y ./test/test.conf clave1 valor1
echo "Continuar..."
read

clear
./Ejercicio_5.sh -c "Cambio clave" ./test/test.conf clave2 valor1
echo "Continuar..."
read
clear
./Ejercicio_5.sh -y -c "Cambio clave otra vez" ./test/test.conf clave2 valor2
echo "Continuar..."
read


clear
echo "FIN"
echo "Continuar..."
read
clear
