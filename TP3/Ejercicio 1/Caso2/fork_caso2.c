#include <pthread.h> //hilos
#include <stdio.h>
#include <unistd.h> //exit
#include <sys/types.h> //pid_t pthread_t
#include <sys/resource.h> //getrusage
#include <time.h>	//clock_time getrusage
#include <string.h> //atoi
#include <errno.h>   // for errno
#include <limits.h>  // for INT_MAX
#include <stdlib.h>  // for strtol
#include <wait.h>

#define NUM_PROCESS     	1000
#define VECTOR_DEFAULT		25000
#define SECOND_MICRSECONDS	1000000.0 
#define SECOND_NANOSECONDS	1000000000.0
#define MICRSECONDS_SECOND	1e-6
#define NANOSECONDS_SECOND	1e-9


/* Estructura Time */
struct timespec diferencia_timespec(struct timespec, struct timespec );

struct rusage diferencia_rusage(struct rusage, struct rusage );

/* Sale del programa emitiendo un error */
void error(char *error);

int main (int argc, char *argv[])
{
	/* Variables */
	int pos, posi, posj;
	long posiciones_vector = VECTOR_DEFAULT;
	pid_t pid_hijo;
	struct rusage stats_padre_ini;
	struct rusage stats_padre_fin;
	struct rusage stats_hijos;
	struct timespec stats_global_padre_ini;
	struct timespec stats_global_padre_fin;
	struct timespec stats_global_hijo_ini;
	struct timespec stats_global_hijo_fin;
	//float sumador_tiempo_global_hijos = 0;
	//float sumador_tiempo_sistema_hijos = 0;
	//float sumador_tiempo_usuario_hijos = 0;
	if( argc >1 )
		posiciones_vector = strtol(argv[1], NULL, 10);
	long* array_enteros = (long*) malloc(posiciones_vector*sizeof(long) );

	if ( array_enteros == NULL )
		error("Error: Asignar memoria con malloc.");
	/* Random */
	srand ( time(NULL) );

	/* Carga vector */
	for( pos=0; pos < posiciones_vector; pos++ )
		array_enteros[pos] = rand() % posiciones_vector;

	/* Estadisticas iniciales del proceso */
	if (getrusage(RUSAGE_SELF, &stats_padre_ini) == -1)
		error("Error: Funcion getrusage.");

	/* Capturo tiempo de inicio del padre*/
	if (clock_gettime(CLOCK_MONOTONIC_RAW, &stats_global_padre_ini) == -1)
		error("Error: Funcion clock_gettime.");

	/* 1000 hijos */
	for ( posi=0; posi < NUM_PROCESS; posi++ ){
		if (clock_gettime(CLOCK_MONOTONIC_RAW, &stats_global_hijo_ini) == -1 )
			error("Error: Funcion clock_gettime.");
		if( ( pid_hijo = fork() ) < 0 )
			error("Error: Funcion fork.");

		/* Operaciones del Hijo */
		if ( !pid_hijo ){ 
			int total = 0;
			for (posj=0; posj < posiciones_vector; posj++)
				array_enteros[pos] = array_enteros[pos]* ( ( rand() % 5000) + 2 );
			return EXIT_SUCCESS;		
		}
		/* Operaciones del Padre */
		else{
			wait4(pid_hijo,NULL,0,&stats_hijos); //Espera al Hijo
			/* Captura fin del Hijo*/
			if (clock_gettime(CLOCK_MONOTONIC_RAW, &stats_global_hijo_fin) == -1)
				error("Error: Funcion clock_gettime. \n");
			/* Acumuladores de tiempos de Uso de Hijos */
			//sumador_tiempo_global_hijos += (float) (1.0 * ( 1.0 * stats_global_hijo_fin.tv_sec + ( 1.0 * stats_global_hijo_fin.tv_nsec) / SECOND_NANOSECONDS ) - 
			//											  ( 1.0 * stats_global_hijo_ini.tv_sec + ( 1.0 * stats_global_hijo_ini.tv_nsec) / SECOND_NANOSECONDS ) );
			/* Tiempos para Promedios */
			//sumador_tiempo_usuario_hijos += (float) ( 1.0 * stats_hijos.ru_utime.tv_sec + ( 1.0 * stats_hijos.ru_utime.tv_usec) / SECOND_MICRSECONDS );
			//sumador_tiempo_sistema_hijos += (float) ( 1.0 * stats_hijos.ru_stime.tv_sec + ( 1.0 * stats_hijos.ru_stime.tv_usec) / SECOND_MICRSECONDS );

		}

	}
	/* Estadisticas finales */
	if ( pid_hijo ){
		/* Captura fin Padre*/
		if (getrusage(RUSAGE_SELF, &stats_padre_fin) == -1) 
			error("Error: Funcion getrusage.");
		/* Como stats_hijos ya la utilice piso sus datos con los CHILDREN que obtuvo el PADRE */
		if (getrusage(RUSAGE_CHILDREN, &stats_hijos) == -1) 
			error("Error: Funcion getrusage.");

		/* Captura fin de proceso*/
		if (clock_gettime(CLOCK_MONOTONIC_RAW, &stats_global_padre_fin) == -1)
			error("Error: Funcion clock_gettime.");

		/* Mediciones */

		printf("\033[H\033[J\033[1;33m\n\n\tEl parametro enviado es: %ld.\n",posiciones_vector);
		printf("\033[1;34m\tTiempo Reloj: %ld.%06ld segundos\n", diferencia_timespec(stats_global_padre_ini,stats_global_padre_fin).tv_sec, 
																 diferencia_timespec(stats_global_padre_ini,stats_global_padre_fin).tv_nsec );
		printf("\033[1;34m\tTiempo Reloj promedio: %.06f segundos\n", ( 1.0* stats_hijos.ru_stime.tv_sec + 
																		1.0 * stats_hijos.ru_stime.tv_usec * MICRSECONDS_SECOND + 
																		1.0* stats_hijos.ru_utime.tv_sec + 
																		1.0 * stats_hijos.ru_utime.tv_usec * MICRSECONDS_SECOND ) / NUM_PROCESS );
		//printf("\033[1;34m\tTiempo CPU sistema total: %ld.%06ld segundos\n",diferencia_rusage(stats_padre_ini, stats_padre_fin).ru_stime.tv_sec, 
		//																   diferencia_rusage(stats_padre_ini, stats_padre_fin).ru_stime.tv_usec );
		printf("\033[1;34m\tTiempo CPU sistema total: %.06f segundos\n",1.0* stats_padre_fin.ru_stime.tv_sec + 
																		1.0* stats_hijos.ru_stime.tv_sec - 
																		1.0* stats_padre_ini.ru_stime.tv_sec +
																		1.0* stats_padre_fin.ru_stime.tv_usec * MICRSECONDS_SECOND + 
																		1.0* stats_hijos.ru_stime.tv_usec * MICRSECONDS_SECOND - 
																		1.0* stats_padre_ini.ru_stime.tv_usec * MICRSECONDS_SECOND  );        
		//printf("\033[1;34m\tTiempo CPU usuario total: %ld.%06ld segundos\n",diferencia_rusage(stats_padre_ini, stats_padre_fin).ru_utime.tv_sec, 
		//																   diferencia_rusage(stats_padre_ini, stats_padre_fin).ru_utime.tv_usec );
		printf("\033[1;34m\tTiempo CPU usuario total: %.06f segundos\n",1.0* stats_padre_fin.ru_utime.tv_sec + 
																		1.0* stats_hijos.ru_utime.tv_sec - 
																		1.0* stats_padre_ini.ru_utime.tv_sec + 
																		1.0* stats_padre_fin.ru_utime.tv_usec * MICRSECONDS_SECOND + 
																		1.0 * stats_hijos.ru_utime.tv_usec  * MICRSECONDS_SECOND - 
																		1.0* stats_padre_ini.ru_utime.tv_usec * MICRSECONDS_SECOND );  
		//printf("\033[1;32m\tTiempo CPU sistema promedio: %.06f segundos\n",sumador_tiempo_sistema_hijos / NUM_PROCESS );
		printf("\033[1;32m\tTiempo CPU sistema promedio: %.06f segundos\n", ( 1.0* stats_hijos.ru_stime.tv_sec + 
																			  1.0 * stats_hijos.ru_stime.tv_usec * MICRSECONDS_SECOND ) / NUM_PROCESS );
		//printf("\033[1;32m\tTiempo CPU usuario promedio: %.06f segundos\n",sumador_tiempo_usuario_hijos / NUM_PROCESS );
		printf("\033[1;32m\tTiempo CPU usuario promedio: %.06f segundos\n",( 1.0* stats_hijos.ru_utime.tv_sec + 
																			 1.0 * stats_hijos.ru_utime.tv_usec * MICRSECONDS_SECOND ) / NUM_PROCESS );
		printf("\033[1;32m\tCantidad de Soft Page Faults: %ld\n",stats_padre_fin.ru_minflt - 
																 stats_padre_ini.ru_minflt + 
																 stats_hijos.ru_minflt );
		printf("\033[1;36m\tCantidad de Hard page faults: %ld\n",stats_padre_fin.ru_majflt - 
																 stats_padre_ini.ru_majflt + 
																 stats_hijos.ru_majflt );
		printf("\033[1;36m\tCantidad de senales recibidas: %ld\n",stats_padre_fin.ru_nsignals - 
																  stats_padre_ini.ru_nsignals + 
																  stats_hijos.ru_nsignals );
		printf("\033[1;31m\tCantidad de contexto voluntario realizado: %ld\n",stats_padre_fin.ru_nvcsw - 
																			   stats_padre_ini.ru_nvcsw + 
																			   stats_hijos.ru_nvcsw );
		printf("\033[1;31m\tCantidad de contexto involuntario realizado: %ld\n\n\n",stats_padre_fin.ru_nivcsw - 
																					 stats_padre_ini.ru_nivcsw + 
																					 stats_hijos.ru_nivcsw );

		/*	
		El parametro enviado es: 5000000.
		Tiempo Reloj: 19.636018428 segundos					( CLOCK FINAL - CLOCK INICIAL )
		Tiempo Reloj promedio: 17.520000 segundos			( RUSAGE_CHILDREN_USER + RUSAGE_CHILDREN_SYSTEM ) / NUM_PROCESS
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
	}
	free (array_enteros);
	return ( EXIT_SUCCESS );
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
