#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <netdb.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <errno.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include <linux/stat.h> 
#include <fcntl.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define TAMBUF 1024
#define CANTMSJS 1000
#define PUERTO 5000
#define MAX 5


/* Sale del programa emitiendo un error */  
void error(char *error);

/* Estructura Rusage */
int getrusage(int who, struct rusage *usage);

struct timespec diferencia (struct timespec, struct timespec );

int main()
{
	///VARIABLES PARA LA ESTADISTICAS////
	struct rusage estadisticas_inicio;
	struct rusage estadisticas_fin;
	long int tiempoCPU_S ;
	long int tiempoCPU_U ;
	struct timespec tiempo_inicio;
	struct timespec tiempo_fin;
	long int time;
	getrusage(RUSAGE_SELF, &estadisticas_inicio );


	///VARIABLES PARA SOCKETS///
	struct sockaddr_in servidor_info;
	socklen_t cl=sizeof(struct sockaddr_in);
	struct sockaddr_in ca;
	int server_socket;
	int client_socket;
	int i;
	char mensaje[TAMBUF];

	if( (server_socket=socket(AF_INET,SOCK_STREAM,0)) ==-1 ) //Creo SOCKET y verifico.
			return 1;

	bzero( (char *) &servidor_info, sizeof(struct sockaddr_in));

	servidor_info.sin_family 		=   AF_INET;                 //Dominio
	servidor_info.sin_port 		    =   htons(PUERTO);            // Convertir para que sea compatible el puerto. (i836 != tcp/ip)
	servidor_info.sin_addr.s_addr   =   INADDR_ANY;             // servidor estará escuchando en todas las
																// interfaces de red que tenga nuestro sistema.

	bind(server_socket,(struct sockaddr *)&servidor_info,sizeof(struct sockaddr_in)); //Asociar una dirección de internet al socket

	listen(server_socket,MAX);                  // Habilitar el socket para recibir conexiones.


	printf("Esperando cliente...\n");
	//  Con accept quedará bloqueada esperando a que lleguen las conexiones desde internet:
	// si llega una peticion, crea un hilo para atender y  sigue esperando...
	client_socket = accept(server_socket, (struct sockaddr *) &ca, &cl );

	clock_gettime(CLOCK_MONOTONIC_RAW,&tiempo_inicio);

	for(i=0;i<CANTMSJS;i++)
	{
		//sprintf ( mensaje,"El proceso %d (Servidor), te manda saludos, Mensaje  numero: %d!",getpid() , i+1 );
		send(client_socket,mensaje,TAMBUF,0);
		bzero(mensaje,TAMBUF);
		recv(client_socket,mensaje,TAMBUF,0);   //Bloqueante, osea que espera al que el Cliente le envie algo.
		//printf("\n%s",mensaje);
	}

	printf("\n");
	//Cierro los SOCKETS (comunicacion y escucha):
	close(client_socket);
	close(server_socket);

	///ESTADISTICAS///

	getrusage( RUSAGE_SELF , &estadisticas_fin );
	clock_gettime(CLOCK_MONOTONIC_RAW,&tiempo_fin);
	/*
	printf("\n\n\n *** Estadisticas Caso 5: Sockets *** \n");
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
	printf("\033[H\033[J");
	printf("\033[1;33m\n\t *** Estadisticas Caso 4,5,6: Sockets *** \n");
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


	return 0;
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

void error(char *error)
{
	fprintf(stderr, "Error: %s (%d, %s)\n", error, errno, strerror(errno));
	exit(EXIT_FAILURE);
}

