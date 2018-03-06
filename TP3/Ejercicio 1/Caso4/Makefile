CC := gcc
CFLAGS :=-lrt -lpthread -pthread
.PHONY : all run clear clean
TAGET=../thread_caso4

all: clear $(TAGET)

../thread_caso4: ./thread_caso4.o
	$(CC) $(CFLAGS) -o ../thread_caso4 ./thread_caso4.o
./thread_caso4.o: ./thread_caso4.c
	$(CC) $(CFLAGS) -c ./thread_caso4.c


run: ../thread_caso4
	clear
	../thread_caso4 | tee log

clear:
	clear
clean:
	rm -f ./*.o $(TAGET)
