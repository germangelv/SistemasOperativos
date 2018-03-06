CC := gcc
CFLAGS :=
.PHONY : all run clear clean
TAGET=./ProcesoA ./ProcesoB

all: clear $(TAGET)

./ProcesoA: ./ProcesoA.o
	$(CC) $(CFLAGS) -o ./ProcesoA ./ProcesoA.o
./ProcesoA.o: ./ProcesoA.c
	$(CC) $(CFLAGS) -c ./ProcesoA.c

./ProcesoB: ./ProcesoB.o
	$(CC) $(CFLAGS) -o ./ProcesoB ./ProcesoB.o
./ProcesoB.o: ./ProcesoB.c
	$(CC) $(CFLAGS) -c ./ProcesoB.c

clear:
	clear
clean:
	rm -f $(TAGET) ./*.o
