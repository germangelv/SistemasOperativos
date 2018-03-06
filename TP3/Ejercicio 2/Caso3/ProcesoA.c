#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/sem.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/resource.h>


#define TAMBUF 1024
#define CANTMSJS 1000

/* compilar con -lrt  -lpthread */

/* Sale del programa emitiendo un error */
void error(char *error);

/* Estructura Rusage */
int getrusage(int who, struct rusage *usage);

struct timespec diferencia(struct timespec, struct timespec);
union semun {
	int val;
	struct semid_ds *buf;
	unsigned short *array;
	struct seminfo *__buf;
};


static const char alphanum[] =
	"0123456789"
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	"abcdefghijklmnopqrstuvwxyz";


void crearMensajeRandom(char *strMensaje);



int main()
{
	struct rusage estadisticas_inicio;
	struct rusage estadisticas_fin;
	long int tiempoCPU_S, tiempoCPU_U, time;
	struct timespec tiempo_inicio;
	struct timespec tiempo_fin;
	getrusage(RUSAGE_SELF, &estadisticas_inicio );

	union semun ctlSem;
	struct sembuf opSem;
	opSem.sem_num = 0;
	opSem.sem_flg = 0;

	int semIniA, semIniB;
	semIniB = semget(ftok(".", 'i'), 1, IPC_CREAT | 0660);
	semIniA = semget(ftok(".", 'j'), 1, IPC_CREAT | 0660);
	ctlSem.val = 0;
	semctl(semIniA, 0, SETVAL, ctlSem);
	printf("Esperando ProcesoB...\n");
	opSem.sem_op  = -1;
	semop(semIniB, &opSem, 1);
	printf("ProcesoB detectado\n");


	clock_gettime(CLOCK_MONOTONIC_RAW, &tiempo_inicio);

	int shmid = shmget(ftok(".", 'z'), TAMBUF*sizeof(char), IPC_CREAT | 0660);
	if (shmid==-1) {
		error("No se pudo crear la memoria compartida");
	}
	char *mensaje = (char*)shmat(shmid,NULL,0);
	char mensajeTmp[TAMBUF];

	int sem1, sem2;
	sem1 = semget(ftok(".", 'x'), 1, IPC_CREAT | 0660);
	sem2 = semget(ftok(".", 'y'), 1, IPC_CREAT | 0660);
	if (sem1==-1 || sem2==-1) {
		error("No se pudo crear algun semaforo");
	}
	ctlSem.val = 1;
	semctl(sem1, 0, SETVAL, ctlSem);
	ctlSem.val = 0;
	semctl(sem2, 0, SETVAL, ctlSem);

	opSem.sem_op  = 1;
	semop(semIniA, &opSem, 1);
	printf("ProcesoB iniciando...\n");
	//printf("\n%d\n", shmid);

	int i;

	crearMensajeRandom(mensajeTmp);
	for( i=0; i<CANTMSJS; i++ )
	{
		//printf("Escribiendo proceso A %d\n",i);
		opSem.sem_op  = -1;
		semop(sem1, &opSem, 1);
		strcpy(mensaje, mensajeTmp);
		//printf("Escribio proceso A %d\n",i);
		//sleep(3);
		opSem.sem_op  = 1;
		semop(sem2, &opSem, 1);
		//printf("Leyendo proceso A %d\n",i);
		opSem.sem_op  = -1;
		semop(sem1, &opSem, 1);
		strcpy(mensajeTmp, mensaje);
		//printf("Leyo proceso A %d\n",i);
		opSem.sem_op  = 1;
		semop(sem1, &opSem, 1);
	}

	semctl(semIniA, 0, IPC_RMID);
	semctl(semIniB, 0, IPC_RMID);
	semctl(sem1, 0, IPC_RMID);
	semctl(sem2, 0, IPC_RMID);
	shmdt(mensaje);
	shmctl(shmid, IPC_RMID, 0);

	getrusage(RUSAGE_SELF, &estadisticas_fin );
	clock_gettime(CLOCK_MONOTONIC_RAW, &tiempo_fin);

	fflush(stdout);
	printf("\033[H\033[J");
	printf("\033[1;33m\n\t *** Estadisticas Caso 3: Memoria Compartida *** \n");
	printf("\033[1;37m\n\tTiempo Reloj: %ld.%06ld segundos", diferencia(tiempo_inicio,tiempo_fin).tv_sec, diferencia(tiempo_inicio,tiempo_fin).tv_nsec );
	printf("\033[1;34m\n\tTiempo CPU Sistema Total: %ld.%06ld segundos",estadisticas_fin.ru_stime.tv_sec - estadisticas_inicio.ru_stime.tv_sec,estadisticas_fin.ru_stime.tv_usec - estadisticas_inicio.ru_stime.tv_usec );
	printf("\033[1;34m\n\tTiempo CPU Usuario Total: %ld.%06ld segundos",estadisticas_fin.ru_utime.tv_sec - estadisticas_inicio.ru_utime.tv_sec, estadisticas_fin.ru_utime.tv_usec - estadisticas_inicio.ru_utime.tv_usec );
	/* Hago la resta de peticiones de pagina de finales menos las iniciales al pedir las paginas para la estadisticas */
	printf("\033[1;32m\n\tCantidad de Soft Page Faults): %ld",estadisticas_fin.ru_minflt - estadisticas_inicio.ru_minflt);
	/* Cantidas de fallo de pagina dentro de codigo ( fin - inicio) */
	printf("\033[1;32m\n\tCantidad de Hard Page Faults): %ld",estadisticas_fin.ru_majflt - estadisticas_inicio.ru_majflt);
	printf("\033[1;36m\n\tOperaciones de Entrada (en bloques): %ld",estadisticas_fin.ru_inblock - estadisticas_inicio.ru_inblock);
	printf("\033[1;36m\n\tOperaciones de Salida (en bloques): %ld",estadisticas_fin.ru_oublock - estadisticas_inicio.ru_oublock);
	printf("\033[1;31m\n\tMensajes IPC enviados: %ld",estadisticas_fin.ru_msgsnd - estadisticas_inicio.ru_msgsnd );
	printf("\033[1;31m\n\tMensajes IPC recibido: %ld\n\n",estadisticas_fin.ru_msgrcv - estadisticas_inicio.ru_msgrcv );

/*
	printf("\n\n\n *** Estadisticas Caso 3: Memoria Compartida *** \n");
	time= (tiempo_fin.tv_sec - tiempo_inicio.tv_sec)*1000000000 + (tiempo_fin.tv_nsec - tiempo_inicio.tv_nsec);
	printf("\nTiempo Reloj: %ld",time);
	tiempoCPU_S = ( estadisticas_fin.ru_stime.tv_sec - estadisticas_inicio.ru_stime.tv_sec)*1000000 +  ( estadisticas_fin.ru_stime.tv_usec - estadisticas_inicio.ru_stime.tv_usec );
	printf("\nTiempo CPU Sistema Total: %ld microsegundos",tiempoCPU_S);
	tiempoCPU_U = ( estadisticas_fin.ru_utime.tv_sec - estadisticas_inicio.ru_utime.tv_sec)*1000000 + ( estadisticas_fin.ru_utime.tv_usec - estadisticas_inicio.ru_utime.tv_usec );
	printf("\nTiempo CPU Usuario Total: %ld microsegundos",tiempoCPU_U);
	// hago la resta de peticiones de pagina de finales menos las iniciales al pedir las paginas para la estadisticas.
	printf("\nCantidad de Soft Page Faults): %ld",estadisticas_fin.ru_minflt - estadisticas_inicio.ru_minflt);
	// Cantidas de fallo de pagina dentro de codigo ( fin - inicio)
	printf("\nCantidad de Hard Page Faults): %ld",estadisticas_fin.ru_majflt - estadisticas_inicio.ru_majflt);
	printf("\nOperaciones de Entrada (en bloques): %ld",estadisticas_fin.ru_inblock - estadisticas_inicio.ru_inblock);
	printf("\nOperaciones de Salida (en bloques): %ld",estadisticas_fin.ru_oublock - estadisticas_inicio.ru_oublock);
	printf("\nMensajes IPC enviados: %ld",estadisticas_fin.ru_msgsnd - estadisticas_inicio.ru_msgsnd );
	printf("\nMensajes IPC recibido: %ld\n",estadisticas_fin.ru_msgrcv - estadisticas_inicio.ru_msgrcv );
*/
	return 0;
}

void error(char *error)
{
	fprintf(stderr, "Error: %s (%d, %s)\n", error, errno, strerror(errno));
	exit(EXIT_FAILURE);
}

struct timespec diferencia (struct timespec inicio, struct timespec fin){
	struct timespec x;
	if( (fin.tv_nsec - inicio.tv_nsec) < 0 ){
		x.tv_sec = fin.tv_sec - inicio.tv_sec - 1;
		x.tv_nsec = 1000000000 + fin.tv_nsec - inicio.tv_nsec;
	}
	else{
		x.tv_sec = fin.tv_sec - inicio.tv_sec;
		x.tv_nsec = fin.tv_nsec - inicio.tv_nsec;
	}
	return x;
}

void crearMensajeRandom(char *strMensaje)
{
	srand(time(NULL));
	srand(rand());
	int i;
	for (i = 0; i < TAMBUF; ++i) {
		strMensaje[i] = alphanum[rand() % (sizeof(alphanum) - 1)];
	}
	strMensaje[TAMBUF-1] = 0;
	return;
}
