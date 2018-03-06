#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>
#include <ctype.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <signal.h>
#include <time.h>
#include <fcntl.h>

#define TAMBUF 1024
#define CANTMSJS 1000

/* Busca un proceso determinado */
int buscaProceso(char *nombre);

/* Sale del programa emitiendo un error */
void error(char *error);

/* Estructura Rusage */
int getrusage(int who, struct rusage *usage);

/* Señalizador principal*/
void despertar();
int reactivar = 0;

struct timespec diferencia(struct timespec, struct timespec );

static const char alphanum[] =
	"0123456789"
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	"abcdefghijklmnopqrstuvwxyz";


void crearMensajeRandom(char *strMensaje);



int main(int argc, char *argv[])
{	/* Variables */
	struct rusage estadisticas_inicio;
	struct rusage estadisticas_fin;
	long int tiempoCPU_S, tiempoCPU_U, time;
	struct timespec tiempo_inicio;
	struct timespec tiempo_fin;
	getrusage(RUSAGE_SELF, &estadisticas_inicio);

	char mensaje[TAMBUF];
	int pid_propio = getpid(), pid_amigo, i=0;
	
	/* Tratamiento de Argumento */
	if (argc > 1) {
		pid_amigo = buscaProceso(argv[1]);
		if ( pid_amigo != 0 ) {
			/* valorEntrada = (long)strtol(argv[1], &p, 10); se pincha a veces */
			printf("\n\n\n\tIdentificador de Proceso Actual:\t%d\n", pid_propio );
			printf("\tIdentificador de Proceso %s:\t%d\n", argv[1], pid_amigo );
			/*Inicio Tratamiento de Señales */
			signal(SIGUSR1, despertar);
			/* Comienzo el envio de señales */
			kill(pid_amigo, SIGUSR1); //Envio de Señal
			while (!reactivar); //Señal para sincronizar PIDs
			reactivar = 0;
			/* Comienzo de estadisticas */
			clock_gettime(CLOCK_MONOTONIC_RAW,&tiempo_inicio);
			/* Accedo al FIFO */
			//unlink("./FIFO"); // si los fifos fueron generados pero no borrados los borros por si las moscas.
			//mkfifo("./FIFO", 0666);//El Servidor escribe al Cliente. El Cliente lee del servidor.
			int rw = open("./FIFO",O_RDWR | O_NONBLOCK );
			if ( rw == -1 ) {
				error("Alguna tuberia, no se pudo abrir.");
			}

			crearMensajeRandom(mensaje);

			/* Comienzo 1000 interaciones sincronizadas */
			while (i<CANTMSJS){
				read(rw ,mensaje ,TAMBUF); // Espera al que Cliente escriba.
				//printf("\n%s",mensaje);
				sprintf ( mensaje,"El proceso %d (Servidor), te manda saludos, Mensaje  numero: %d!",getpid() , i+1 );
				write(rw, mensaje, TAMBUF);
				i++;
				kill(pid_amigo, SIGUSR1); //Envio de Señal
				while (!reactivar); //Espero para reanudar
				reactivar = 0;
			}
			close(rw);
			unlink("./FIFO");
			
			/* Estadisticas al finalizar*/
			getrusage(RUSAGE_SELF, &estadisticas_fin);
			clock_gettime(CLOCK_MONOTONIC_RAW, &tiempo_fin);
			
			fflush(stdout);
			printf("\033[H\033[J");
			printf("\033[1;33m\n\t *** Estadisticas Caso 2: Tuberia sincronizada con signals *** \n");
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

		}
		else 
			error("Proceso no encontrado");
	}
	else
		error("Sin Parametros. Escriba ./ProcesoA nombre_de_proceso_a_ser_iterado\n Ejemplo: ./ProcesoA ProcesoB");
	return EXIT_SUCCESS;
}

void despertar()
{
	reactivar = 1;
}

int buscaProceso(char *nombre)
{
	DIR *proc;
	struct dirent *proceso;
	char procname[16];        /* Nombre del proceso */
	int pid;
	FILE *fcomm;
	char filename[20];        // proc/[PID] (5 chars)/comm : total 16 chars
	proc=opendir("/proc");
	if (proc==NULL)
		error("No puedo acceder al directorio /proc\n");
	while ((proceso=readdir(proc)) != NULL)
	{
		/* En /proc hay más cosas además de los PIDs, debemos asegurarnos de que */
		/* lo que hemos visto es un ID de proceso, lo demás no nos interesa */
		if ( (*proceso->d_name>'0') && (*proceso->d_name<='9') )
		{
			/* Convertimos el PID a número para la llamada a la función */
			pid=strtol(proceso->d_name, NULL, 10);
			sprintf(filename,"/proc/%d/comm", pid);
			fcomm=fopen(filename, "r");
			if (!fcomm)
				error("No existe el fichero");
			fscanf(fcomm, "%s", procname);
			fclose(fcomm);
			if (strncmp(nombre,procname,15)==0) {
				return pid;
			}
		}
	}
	return 0;
}

void error(char *error)
{
	fprintf(stderr, "Error: %s (%d, %s)\n", error, errno, strerror(errno));
	exit(EXIT_FAILURE);
}

struct timespec diferencia(struct timespec inicio, struct timespec fin)
{
	struct timespec x;
	if ( (fin.tv_nsec - inicio.tv_nsec) < 0 ) {
		x.tv_sec = fin.tv_sec - inicio.tv_sec - 1;
		x.tv_nsec = 1000000000 + fin.tv_nsec - inicio.tv_nsec;
	}
	else {
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
