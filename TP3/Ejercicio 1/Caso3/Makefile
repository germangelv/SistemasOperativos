CC := gcc
CFLAGS :=-lrt -lpthread -pthread
.PHONY : all run clear clean
TAGET=../thread_caso3

all: clear $(TAGET)

../thread_caso3: ./thread_caso3.o
	$(CC) $(CFLAGS) -o ../thread_caso3 ./thread_caso3.o
./thread_caso3.o: ./thread_caso3.c
	$(CC) $(CFLAGS) -c ./thread_caso3.c


run: ../thread_caso3
	clear
	../thread_caso3 | tee log

clear:
	clear
clean:
	rm -f ./*.o $(TAGET)
