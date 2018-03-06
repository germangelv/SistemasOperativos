#!/bin/bash
echo ////////////////////////////
echo / Compilando Procesos...     
echo ////////////////////////////
make
#gcc -o Cliente Cliente.c -lrt -lpthread -lm
#gcc -o Servidor Servidor.c -lrt -lpthread -lm
#echo ////////////////////////////
#echo / Procesos Corriendo...     
#echo ////////////////////////////
#./Servidor &
#./Cliente 127.0.0.1
echo "Caso 4"
echo "     ejecute en una consola './Servidor'"
echo "     ejecute en la misma pc, en otra consola './Cliente 127.0.0.1'"
echo "     visualice las estadiscitas en la consola del servidor"
echo "Caso 5"
echo "     ejecute en una consola './Servidor'"
echo "     ejecute en la misma pc, en otra consola './Cliente [IP local]'"
echo "     visualice las estadiscitas en la consola del servidor"
echo "Caso 6"
echo "     ejecute en una consola './Servidor'"
echo "     ejecute en la otra pc, en otra consola './Cliente [IP server]'"
echo "     visualice las estadiscitas en la consola del servidor"

#fuser -k -n tcp 5000
#netstat - n | grep 5000
