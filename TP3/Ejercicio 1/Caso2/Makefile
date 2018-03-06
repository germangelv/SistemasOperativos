CC := gcc
CFLAGS :=-lrt
.PHONY : all run clear clean
TAGET=../fork_caso2

all: clear $(TAGET)

../fork_caso2: ./fork_caso2.o
	$(CC) $(CFLAGS) -o ../fork_caso2 ./fork_caso2.o
./fork_caso2.o: ./fork_caso2.c
	$(CC) $(CFLAGS) -c ./fork_caso2.c


run: ../fork_caso2
	clear
	../fork_caso2 | tee log

clear:
	clear
clean:
	rm -f ./*.o $(TAGET)
