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

#define TAMBUF 1024
#define CANTMSJS 1000
#define ESTRUCTURA_FILE "FILE"
#define MODO_SINC "w+"

/* Busca un proceso determinado */
int buscaProceso(char *nombre);

/* Sale del programa emitiendo un error */
void error(char *error);

/* Señalizador principal*/
void despertar();
int reactivar = 0;



int main(int argc, char *argv[])
{	/* Variables */
	FILE *fp;
	char mensaje[TAMBUF];
	int pid_propio = getpid(), pid_amigo, i=0;
	/* Tratamiento de Argumento */
	if (argc > 1 )
	{	
		/* valorEntrada = (long)strtol(argv[1], &p, 10); se pincha a veces */
		/*Inicio Tratamiento de Señales */
		signal(SIGUSR1,despertar);
		while (!reactivar); //Espero para reanudar cuando ProcesoA obtenga mi PID asi me envia una señal inicial y yo obtengo su PID

		reactivar = 0;
		pid_amigo = buscaProceso(argv[1]);
		if ( pid_amigo != 0 )
		{
			//printf("\tIdentificador de Proceso Actual:\t%d\n", pid_propio );
			//printf("\tIdentificador de Proceso %s:\t%d\n", argv[1], pid_amigo );
			/* Accedo al Archivo */
			fp = fopen(ESTRUCTURA_FILE, MODO_SINC);
			while (i<CANTMSJS)
			{
				kill(pid_amigo, SIGUSR1);
				while (!reactivar); //Espero para reanudar	

				reactivar = 0;
				//rewind(fp);
				fseek(fp, 0, SEEK_SET);
				//fgets(mensaje, TAMBUF, fp); //Leo lo que dejo el otro proceso
				fread(mensaje, sizeof(char), TAMBUF, fp);
				fflush(fp); //Fuerzo volcado de archivo
				//rewind(fp);
				fseek(fp, 0, SEEK_SET);

				//fputs(mensaje,fp);  // Escribo archivo creado por el otro proceso
				fwrite(mensaje, sizeof(char), TAMBUF, fp);
				fflush(fp); //Fuerzo volcado de archivo
				//printf("\tInteraccion %d\n",i+1);
				i++;
			}
			kill (pid_amigo, SIGUSR1);
			fclose(fp);
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