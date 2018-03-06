CC := gcc
CFLAGS :=-lrt
.PHONY : all run clear clean
TAGET=../fork_caso1

all: clear $(TAGET)

../fork_caso1: ./fork_caso1.o
	$(CC) $(CFLAGS) -o ../fork_caso1 ./fork_caso1.o
./fork_caso1.o: ./fork_caso1.c
	$(CC) $(CFLAGS) -c ./fork_caso1.c


run: ../fork_caso1
	clear
	../fork_caso1 | tee log

clear:
	clear
clean:
	rm -f ./*.o $(TAGET)
