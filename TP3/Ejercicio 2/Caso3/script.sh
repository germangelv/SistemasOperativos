#!/bin/bash
echo ////////////////////////////
echo / Compilando Procesos...     
echo ////////////////////////////
make
#gcc -o ProcesoA ProcesoA.c -lrt -lpthread -lm
#gcc -o ProcesoB ProcesoB.c -lrt -lpthread -lm
echo ////////////////////////////
echo / Procesos Corriendo...     
echo ////////////////////////////
./ProcesoB &
sleep 1
./ProcesoA


#ipcs -s
#ipcrm -s [key]
#ipcrm -s [id]

#ipcs -m
#ipcrm -M [key]
#ipcrm -m [id]
