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
echo "Pesado Lectura 25000" > Estadisticas.txt

./fork_caso1 25000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Lectura 50000" >> Estadisticas.txt
./fork_caso1 50000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Lectura 75000" >> Estadisticas.txt
./fork_caso1 75000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Escritura 25000" >> Estadisticas.txt

./fork_caso2 25000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Escritura 50000" >> Estadisticas.txt
./fork_caso2 50000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Pesado Escritura 75000" >> Estadisticas.txt
./fork_caso2 75000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Lectura 25000" >> Estadisticas.txt
./thread_caso3 25000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Lectura 50000" >> Estadisticas.txt
./thread_caso3 50000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Lectura 75000" >> Estadisticas.txt
./thread_caso3 75000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Escritura 25000" >> Estadisticas.txt
./thread_caso4 25000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Escritura 50000" >> Estadisticas.txt
./thread_caso4 50000 >> Estadisticas.txt
echo "" >> Estadisticas.txt
wait
echo "Liviano Escritura 75000" >> Estadisticas.txt
./thread_caso4 75000 >> Estadisticas.txt
wait
clear
echo ////////////////////////////
echo Estadisticas.txt finalizadas
echo ////////////////////////////
