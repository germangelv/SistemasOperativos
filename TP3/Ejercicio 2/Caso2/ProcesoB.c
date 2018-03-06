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

/* Señalizador principal*/
void despertar();
int reactivar = 0;



int main(int argc, char *argv[])
{	/* Variables */
	char mensaje[TAMBUF];
	int pid_propio = getpid(), pid_amigo, i=0;
	/* Tratamiento de Argumento */
	if (argc > 1 )
	{	
		/* valorEntrada = (long)strtol(argv[1], &p, 10); se pincha a veces */
		/*Inicio Tratamiento de Señales */
		signal(SIGUSR1,despertar);
		while (!reactivar); //Espero para reanudar cuando ProcesoA obtenga mi PID asi me nvia una señal inicial y yo obtengo su PID

		reactivar = 0;
		pid_amigo = buscaProceso(argv[1]);
		if ( buscaProceso(argv[1]) != 0 )
		{
			//printf("\tIdentificador de Proceso Actual:\t%d\n", pid_propio );
			//printf("\tIdentificador de Proceso %s:\t%d\n", argv[1], pid_amigo );
			/* Accedo al Archivo */
			/* Accedo al FIFO */
			unlink("./FIFO"); // si los fifos fueron generados pero no borrados los borros por si las moscas.
			mkfifo("./FIFO", 0666);//El Servidor escribe al Cliente. El Cliente lee del servidor.
			int rw = open("./FIFO",O_RDWR | O_NONBLOCK );
			if ( rw == -1 ) {
				error("Alguna tuberia, no se pudo crear.");
			}
			while (i<CANTMSJS)
			{
				sprintf(mensaje,"El proceso %d (Cliente), te manda saludos, Mensaje  numero: %d!",getpid() , i+1 );
				write(rw, mensaje, TAMBUF);
				kill(pid_amigo, SIGUSR1);
				while (!reactivar); //Espero para reanudar	

				reactivar = 0;
				read(rw, mensaje, TAMBUF); // Espero al que Servidor escriba.
				//printf("\n%s",mensaje);
				i++;
			}
			kill(pid_amigo, SIGUSR1);
			close(rw);
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
		error("No puedo acceder al directorio /proc");
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
			if (strncmp(nombre,procname,15)==0){
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
