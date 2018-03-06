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
echo "Pesado Lectura 250000" > Estadisticas.txt

./fork_caso1 250000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Lectura 500000" >> Estadisticas.txt
./fork_caso1 500000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Lectura 750000" >> Estadisticas.txt
./fork_caso1 750000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Escritura 250000" >> Estadisticas.txt

./fork_caso2 250000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Escritura 500000" >> Estadisticas.txt
./fork_caso2 500000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Escritura 750000" >> Estadisticas.txt
./fork_caso2 750000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Lectura 250000" >> Estadisticas.txt
./thread_caso3 250000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Lectura 500000" >> Estadisticas.txt
./thread_caso3 500000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Lectura 750000" >> Estadisticas.txt
./thread_caso3 750000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Escritura 250000" >> Estadisticas.txt
./thread_caso4 250000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Escritura 500000" >> Estadisticas.txt
./thread_caso4 500000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Escritura 750000" >> Estadisticas.txt
./thread_caso4 750000 >> Estadisticas.txt
wait
clear
echo ////////////////////////////
echo Estadisticas.txt finalizadas
echo ////////////////////////////
