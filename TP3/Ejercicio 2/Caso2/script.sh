#!/bin/bash
echo ////////////////////////////
echo / Compilando Procesos...     
echo ////////////////////////////
make
#gcc -o ProcesoA ProcesoA.c -lrt
#gcc -o ProcesoB ProcesoB.c -lrt
echo ////////////////////////////
echo / Procesos Corriendo...     
echo ////////////////////////////
./ProcesoB ProcesoA &
sleep 1
./ProcesoA ProcesoB
