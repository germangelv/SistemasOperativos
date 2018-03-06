#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/sem.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <string.h>
#include <sys/resource.h>

#define TAMBUF 1024
#define CANTMSJS 1000

/* Sale del programa emitiendo un error */
void error(char *error);

union semun {
	int val;
	struct semid_ds *buf;
	unsigned short *array;
	struct seminfo *__buf;
};


int main()
{
	union semun ctlSem;
	struct sembuf opSem;
	opSem.sem_num = 0;
	opSem.sem_flg = 0;

	int semIniA, semIniB;
	semIniB = semget(ftok(".", 'i'), 1, IPC_CREAT | 0660);
	semIniA = semget(ftok(".", 'j'), 1, IPC_CREAT | 0660);
	ctlSem.val = 0;
	semctl(semIniB, 0, SETVAL, ctlSem);
	opSem.sem_op  = 1;
	semop(semIniB, &opSem, 1);
	printf("Esperando ProcesoA...\n");
	opSem.sem_op  = -1;
	semop(semIniA, &opSem, 1);
	printf("ProcesoA detectado\n");

	int shmid = shmget(ftok(".", 'z'), TAMBUF*sizeof(char), 0660);
	if (shmid==-1) {
		error("No se pudo crear la memoria compartida");
	}
	char *mensaje = (char*)shmat(shmid,NULL,0);
	char mensajeTmp[TAMBUF];

	int sem1, sem2;
	sem1 = semget(ftok(".", 'x'), 1, 0660);
	sem2 = semget(ftok(".", 'y'), 1, 0660);
	if (sem1==-1 || sem2==-1) {
		error("No se pudo crear algun semaforo");
	}

	int i;
	for( i=0; i<CANTMSJS; i++ )
	{
		//printf("Leyendo proceso B %d\n",i);
		opSem.sem_op  = -1;
		semop(sem2, &opSem, 1);
		strcpy(mensajeTmp, mensaje);
		//printf("Leyo proceso B %d\n",i);
		if (i==0)
			//printf("%s\n",mensajeTmp);
		//sleep(3);
		//printf("Escribiendo proceso B %d\n",i);
		strcpy(mensaje, mensajeTmp);
		opSem.sem_op  = 1;
		semop(sem1, &opSem, 1);
		//printf("Escribio proceso B %d\n",i);
	}


	return 0;
}

void error(char *error)
{
	fprintf(stderr, "Error: %s (%d, %s)\n", error, errno, strerror(errno));
	exit(EXIT_FAILURE);
}

