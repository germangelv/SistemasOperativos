#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>

#define TAMBUF 1024
#define CANTMSJS 1000
#define PUERTO 5000
#define MAX 5

/* Sale del programa emitiendo un error */
void error(char *error);

int main(int argc, char *argv[])
{
	if (argc > 1) {
		char IP[20]="";
		strcpy(IP,argv[1]); //va a ser localhost, ip local, y por ip publica
		int socket_cliente,i;
		char mensaje[TAMBUF];
		struct sockaddr_in server_socket;
		// creamos el SOCKET del cliente:
		if((socket_cliente=socket(AF_INET,SOCK_STREAM,0))==-1)
			return 1;

		bzero(&(server_socket.sin_zero),8);

		server_socket.sin_family= AF_INET; // seteo el dominio.
		server_socket.sin_port=	htons(PUERTO); //seteo el puerto.
		server_socket.sin_addr.s_addr= inet_addr(IP); //seteo la ip del servidor.



		if(connect(socket_cliente, (struct sockaddr *) &server_socket ,sizeof(server_socket))==-1)
		{
			error("No se pudo establecer conexion\n");
		}

		for(i=0;i<CANTMSJS;i++)
	 	{
			bzero(mensaje,TAMBUF);
			recv(socket_cliente,mensaje,TAMBUF,0); //bloqueante.
			//printf("\n%s" ,mensaje);
			//sprintf ( mensaje,"El proceso %d (Cliente), te manda saludos, Mensaje  numero: %d!",getpid() , i+1 );
			send(socket_cliente,mensaje,TAMBUF,0); // le envio l mensaje al Servidor.

		}
		//Cierro el SOCKET (comunicacion):
		printf("\n");
		close(socket_cliente);
	}
	else 
		error("Debe colocar una ip para conectarse.");


	return 0;
}

void error(char *error)
{
	fprintf(stderr, "Error: %s (%d, %s)\n", error, errno, strerror(errno));
	exit(EXIT_FAILURE);
}
