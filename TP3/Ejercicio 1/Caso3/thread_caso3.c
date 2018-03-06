#define _GNU_SOURCE
#include <pthread.h> //hilos
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/resource.h> //getrusage
#include <time.h>	//clock_time
#include <string.h> //
#include <errno.h>   // for errno
#include <limits.h>  // for INT_MAX
#include <stdlib.h>  // for strtol
#include <wait.h>
#define _GNU_SOURCE

#define NUM_PROCESS     	1000
#define VECTOR_DEFAULT		25000
#define SECOND_MICRSECONDS	1000000.0
#define SECOND_NANOSECONDS	1000000000.0
#define MICRSECONDS_SECOND	1e-6
#define NANOSECONDS_SECOND	1e-9

struct argumentos {
	struct rusage usage1;
	struct rusage usage2;
	long posiciones_vector;
};

/* Estructura Time */
struct timespec diferencia_timespec(struct timespec, struct timespec );

struct rusage diferencia_rusage(struct rusage, struct rusage );

void *lectura(void * );
long* array_enteros;
struct argumentos data_hilo;

/* Sale del programa emitiendo un error */
void error(char *error);

int main (int argc, char *argv[])
{
	/* Variables */
	int pos, posi, posj;
	pid_t pid_hijo;
	struct rusage stats_hilos;
	struct rusage stats_padre_ini;
	struct rusage stats_padre_fin;
	struct timespec stats_global_padre_ini;
	struct timespec stats_global_padre_fin;
	struct timespec stats_global_hilo_ini;
	struct timespec stats_global_hilo_fin;
	float sumador_tiempo_hilos_sistema = 0;
	float sumador_tiempo_hilos_usuario = 0;
	float sumador_tiempo_hilos_global = 0;

	data_hilo.posiciones_vector = VECTOR_DEFAULT;
	if( argc >1 )
		data_hilo.posiciones_vector = strtol(argv[1], NULL, 10);
	array_enteros = (long*) malloc(data_hilo.posiciones_vector*sizeof(long) );

	if ( array_enteros == NULL )
		error("Error: Asignar memoria con malloc.");
	/* Random */
	srand ( time(NULL) );

	/* Carga vector */
	for( pos=0; pos < data_hilo.posiciones_vector; pos++ )
		array_enteros[pos] = rand() % data_hilo.posiciones_vector;

	/* Estadisticas iniciales del proceso */
	if (getrusage(RUSAGE_CHILDREN, &stats_padre_ini) == -1)
		error("Error: Funcion getrusage.");

	/* Capturo tiempo de inicio del padre*/
	if (clock_gettime(CLOCK_MONOTONIC_RAW, &stats_global_padre_ini) == -1)
		error("Error: Funcion clock_gettime.");

	/* 1000 Hilos */
	pthread_t threads[NUM_PROCESS];



	for(posi=0; posi < NUM_PROCESS; posi++){
		if ( clock_gettime(CLOCK_MONOTONIC_RAW,&stats_global_hilo_ini) == -1 )//tomo el tiempo reloj inicial para calcular el promedio
			error("Error: Funcion clock_gettime.");
		if ( pthread_create(&threads[posi], NULL, lectura, (void *)&data_hilo) )//creamos el thread
			error("Error: Funcion pthread_create.");
		wait(NULL);//esperamos al thread
		pthread_join(threads[posi], NULL);	//Liberamos los recursos del Thread joineable	
		if ( clock_gettime(CLOCK_MONOTONIC_RAW,&stats_global_hilo_fin) == -1 )//tomo el tiempo reljo final para calcular el promedio
			error("Error: Funcion clock_gettime.");
		/* Acumuladores de tiempos de Uso de Hilos */
		/* Tiempos para Promedios */
		sumador_tiempo_hilos_usuario += (float) ( 1.0 * ( 1.0 * data_hilo.usage2.ru_utime.tv_sec + ( 1.0 * data_hilo.usage2.ru_utime.tv_usec ) / SECOND_MICRSECONDS ) -
														( 1.0 * data_hilo.usage1.ru_utime.tv_sec + ( 1.0 * data_hilo.usage1.ru_utime.tv_usec ) / SECOND_MICRSECONDS ) );
	
		sumador_tiempo_hilos_sistema += (float) ( 1.0 * ( 1.0 * data_hilo.usage2.ru_stime.tv_sec + ( 1.0 * data_hilo.usage2.ru_stime.tv_usec ) / SECOND_MICRSECONDS ) -
														( 1.0 * data_hilo.usage1.ru_stime.tv_sec + ( 1.0 * data_hilo.usage1.ru_stime.tv_usec ) / SECOND_MICRSECONDS ) );
		
		sumador_tiempo_hilos_global +=  (float) ( 1.0 * ( 1.0 * stats_global_hilo_fin.tv_sec + ( 1.0 * stats_global_hilo_fin.tv_nsec) / SECOND_NANOSECONDS ) - 
														( 1.0 * stats_global_hilo_ini.tv_sec + ( 1.0 * stats_global_hilo_ini.tv_nsec) / SECOND_NANOSECONDS ) );
		//sumador_tiempo_hilos_global += sumador_tiempo_hilos_usuario + sumador_tiempo_hilos_sistema;
	}

	/* Captura fin Padre*/
	if (getrusage(RUSAGE_SELF, &stats_padre_fin) == -1) 
		error("Error: Funcion getrusage.");
	if (getrusage(RUSAGE_THREAD, &stats_hilos) == -1)
		error("Error: Funcion getrusage.");
	/* Captura fin de proceso*/
	if (clock_gettime(CLOCK_MONOTONIC_RAW, &stats_global_padre_fin) == -1)
		error("Error: Funcion clock_gettime.");

	/* Mediciones */
	printf("\033[H\033[J\033[1;33m\n\n\tEl parametro enviado es: %ld.\n",data_hilo.posiciones_vector);
	printf("\033[1;34m\tTiempo Reloj: %ld.%06ld segundos\n", diferencia_timespec(stats_global_padre_ini,stats_global_padre_fin).tv_sec, 
															 diferencia_timespec(stats_global_padre_ini,stats_global_padre_fin).tv_nsec );
	printf("\033[1;34m\tTiempo Reloj promedio: %.06f segundos\n", ( sumador_tiempo_hilos_global ) / NUM_PROCESS ); //sumador_tiempo_hilos_sistema + sumador_tiempo_hilos_usuario
	//printf("\033[1;34m\tTiempo CPU sistema total: %ld.%06ld segundos\n",diferencia_rusage(stats_padre_ini, stats_padre_fin).ru_stime.tv_sec, 
	//																   diferencia_rusage(stats_padre_ini, stats_padre_fin).ru_stime.tv_usec );
	printf("\033[1;34m\tTiempo CPU sistema total: %ld.%06ld segundos\n",stats_padre_fin.ru_stime.tv_sec, stats_padre_fin.ru_stime.tv_usec );        
	//printf("\033[1;34m\tTiempo CPU usuario total: %ld.%06ld segundos\n",diferencia_rusage(stats_padre_ini, stats_padre_fin).ru_utime.tv_sec, 
	//																   diferencia_rusage(stats_padre_ini, stats_padre_fin).ru_utime.tv_usec );
	printf("\033[1;34m\tTiempo CPU usuario total: %ld.%06ld segundos\n",stats_padre_fin.ru_utime.tv_sec, stats_padre_fin.ru_utime.tv_usec );
	//printf("\033[1;32m\tTiempo CPU sistema promedio: %.06f segundos\n",sumador_tiempo_sistema_hijos / NUM_PROCESS );
	printf("\033[1;32m\tTiempo CPU sistema promedio: %.06f segundos\n", sumador_tiempo_hilos_sistema / NUM_PROCESS );
	//printf("\033[1;32m\tTiempo CPU usuario promedio: %.06f segundos\n",sumador_tiempo_usuario_hijos / NUM_PROCESS );
	printf("\033[1;32m\tTiempo CPU usuario promedio: %.06f segundos\n", sumador_tiempo_hilos_usuario/ NUM_PROCESS );
	printf("\033[1;32m\tCantidad de Soft Page Faults: %ld\n",stats_padre_fin.ru_minflt - 
															 stats_padre_ini.ru_minflt );
	printf("\033[1;36m\tCantidad de Hard page faults: %ld\n",stats_padre_fin.ru_majflt - 
															 stats_padre_ini.ru_majflt );
	printf("\033[1;36m\tCantidad de senales recibidas: %ld\n",stats_padre_fin.ru_nsignals - 
															  stats_padre_ini.ru_nsignals );
	printf("\033[1;31m\tCantidad de contexto voluntario realizado: %ld\n",stats_padre_fin.ru_nvcsw - 
																		   stats_padre_ini.ru_nvcsw );
	printf("\033[1;31m\tCantidad de contexto involuntario realizado: %ld\n\n\n",stats_padre_fin.ru_nivcsw - 
																				 stats_padre_ini.ru_nivcsw );

	/*	
	El parametro enviado es: 5000000.
	Tiempo Reloj: 19.636018428 segundos					( CLOCK FINAL PROCESO - CLOCK INICIAL PROCESO)
	Tiempo Reloj promedio: 17.520000 segundos			( CLOCK FINAL HILOS + CLOCK INICIAL HILOS ) / NUM_PROCESS
	Tiempo CPU sistema total: 0.136000 segundos			( RUSAGE_CHILDREN_SYSTEM + RUSAGE_SELF_SYSTEM )
	Tiempo CPU usuario total: 17.632000 segundos		( RUSAGE_CHILDREN_USER + RUSAGE_SELF_USER )
	Tiempo CPU sistema promedio: 0.000000 segundos		( RUSAGE_CHILDREN_SYSTEM / NUM_PROCESS )
	Tiempo CPU usuario promedio: 17.520000 segundos		( RUSAGE_CHILDREN_USER / NUM_PROCESS)
	Cantidad de Soft Page Faults: 22645					( RUSAGE_CHILDREN + RUSAGE_SELF )
	Cantidad de Hard page faults: 0 					( RUSAGE_CHILDREN + RUSAGE_SELF )
	Cantidad de senales recibidas: 0 					( RUSAGE_CHILDREN + RUSAGE_SELF )
	Cantidad de contexto voluntario:  realizado 1997	( RUSAGE_CHILDREN + RUSAGE_SELF )
	Cantidad de contexto involuntario:  realizado 127	( RUSAGE_CHILDREN + RUSAGE_SELF )

	*/
	free (array_enteros);
	exit ( EXIT_SUCCESS );
}

struct timespec diferencia_timespec(struct timespec inicio, struct timespec fin){
	struct timespec x;
	if( (fin.tv_nsec - inicio.tv_nsec) < 0 ){
		x.tv_sec = fin.tv_sec - inicio.tv_sec - 1;
		x.tv_nsec = (long) ( SECOND_NANOSECONDS + fin.tv_nsec - inicio.tv_nsec );
	}
	else{
		x.tv_sec = fin.tv_sec - inicio.tv_sec;
		x.tv_nsec = fin.tv_nsec - inicio.tv_nsec;
	}
	return x;
}

struct rusage diferencia_rusage(struct rusage inicio, struct rusage fin){
	struct rusage x;
	if( (fin.ru_stime.tv_usec - inicio.ru_stime.tv_usec) < 0 ){
		
		x.ru_stime.tv_sec = fin.ru_stime.tv_sec - inicio.ru_stime.tv_sec - 1;
		x.ru_stime.tv_usec = (long) ( SECOND_MICRSECONDS + fin.ru_stime.tv_usec - inicio.ru_stime.tv_usec ); //SECOND_MICRSECONDS es float
	}
	else{
		x.ru_stime.tv_sec = fin.ru_stime.tv_sec - inicio.ru_stime.tv_sec;
		x.ru_stime.tv_usec = fin.ru_stime.tv_usec - inicio.ru_stime.tv_usec;
	}
	if( (fin.ru_utime.tv_usec - inicio.ru_utime.tv_usec) < 0 ){
		x.ru_utime.tv_sec = fin.ru_utime.tv_sec - inicio.ru_utime.tv_sec - 1;
		x.ru_utime.tv_usec = (long) ( SECOND_MICRSECONDS + fin.ru_utime.tv_usec - inicio.ru_utime.tv_usec ); //SECOND_MICRSECONDS es float
	}
	else{
		x.ru_utime.tv_sec = fin.ru_utime.tv_sec - inicio.ru_utime.tv_sec;
		x.ru_utime.tv_usec = fin.ru_utime.tv_usec - inicio.ru_utime.tv_usec;
	}
	return x;
}

void error(char *error)
{
	fprintf(stderr, "Error: %s (%d, %s)\n", error, errno, strerror(errno));
	exit( EXIT_FAILURE );
}

void *lectura(void *data)
{
	struct argumentos *args = (struct argumentos *)data;
	int x,total=0;
	if (getrusage ( RUSAGE_SELF, &(args->usage1) ) == -1)
		error("Error: Funcion getrusage.");
	for( x=0; x < args->posiciones_vector; x++){
		total += array_enteros[x];
	}
	if (getrusage ( RUSAGE_SELF, &(args->usage2) ) == -1)
		error("Error: Funcion getrusage.");
	pthread_exit(NULL);
}
