#!/bin/bash
echo ////////////////////////////
echo Compilando Programas...
echo ////////////////////////////
cd Caso1
make
cd ..
cd Caso2
make
cd ..
cd Caso3
make
cd ..
cd Caso4
make
cd ..
#gcc -o fork_caso1 Caso1/fork_caso1.c -lrt
#gcc -o fork_caso2 Caso2/fork_caso2.c -lrt
#gcc -o thread_caso3 Caso3/thread_caso3.c -lrt -lpthread
#gcc -o thread_caso4 Caso4/thread_caso4.c -lrt -lpthread
clear
echo ////////////////////////////
echo Corriendo casos...
echo ////////////////////////////
echo "Pesado Lectura 25000"

./fork_caso1 25000
wait
echo ""
echo "Pesado Lectura 50000"

./fork_caso1 50000
wait
echo ""
echo "Pesado Lectura 75000"

./fork_caso1 75000
wait
echo ""
echo "Pesado Escritura 25000"

./fork_caso2 25000
wait
echo ""
echo "Pesado Escritura 50000"

./fork_caso2 50000
wait
echo ""
echo "Pesado Escritura 75000"

./fork_caso2 75000
wait
echo ""
echo "Liviano Lectura 25000"

./thread_caso3 25000
wait
echo ""
echo "Liviano Lectura 50000"

./thread_caso3 50000
wait
echo ""
echo "Liviano Lectura 75000"

./thread_caso3 75000
wait
echo ""
echo "Liviano Escritura 25000"

./thread_caso4 25000
wait
echo ""
echo "Liviano Escritura 50000"

./thread_caso4 50000
wait
echo ""
echo "Liviano Escritura 75000"

./thread_caso4 75000
wait
clear
echo ////////////////////////////
echo Script finalizado
echo ////////////////////////////
