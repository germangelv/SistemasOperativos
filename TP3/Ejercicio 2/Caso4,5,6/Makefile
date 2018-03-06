CC := gcc
CFLAGS :=-lrt
.PHONY : all run clear clean
TAGET=./Cliente ./Servidor

all: clear $(TAGET)

./Cliente: ./Cliente.o
	$(CC) $(CFLAGS) -o ./Cliente ./Cliente.o
./Cliente.o: ./Cliente.c
	$(CC) $(CFLAGS) -c ./Cliente.c

./Servidor: ./Servidor.o
	$(CC) $(CFLAGS) -o ./Servidor ./Servidor.o
./Servidor.o: ./Servidor.c
	$(CC) $(CFLAGS) -c ./Servidor.c

clear:
	clear
clean:
	rm -f $(TAGET) ./*.o
