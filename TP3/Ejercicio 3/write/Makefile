CC := gcc
CFLAGS :=
.PHONY : all run clear clean install
TAGET=./bin/Debug/Ejercicio3

all: clear $(TAGET)

./bin/Debug/Ejercicio3: ./obj/Debug/Ejercicio3.o ./obj/Debug/InfoProc.o
	$(CC) $(CFLAGS) -o ./bin/Debug/Ejercicio3 ./obj/Debug/Ejercicio3.o ./obj/Debug/InfoProc.o
./obj/Debug/Ejercicio3.o: ./Ejercicio3.c
	$(CC) $(CFLAGS) -o ./obj/Debug/Ejercicio3.o -c ./Ejercicio3.c
./obj/Debug/InfoProc.o: ./InfoProc.c
	$(CC) $(CFLAGS) -o ./obj/Debug/InfoProc.o -c ./InfoProc.c



run: ./bin/Debug/Ejercicio3
	clear
	./bin/Debug/Ejercicio3 | tee log

clear:
	clear
clean:
	rm -f ./obj/Debug/*.o $(TAGET)
