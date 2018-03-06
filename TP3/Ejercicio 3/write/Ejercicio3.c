#include "./Ejercicio3.h"

//#include <stdio.h>

int main(int argc, char *argv[])
{
	struct rusage ruEstadoInicial;
	struct rusage ruEstadoFinal;
	struct timespec tsTiempoInicial;
	struct timespec tsTiempoFinal;
	struct timespec tsTiempoTotal;
	time_t rawtimeInicial;
	time_t rawtimeFinal;

	iniciarProcesoEstado(&ruEstadoInicial);
	tsTiempoInicial = iniciarProcesoTiempo();
	time(&rawtimeInicial);

	char strMensaje[1025];
	char strArchivo[100] = "./file/test.txt";
	//cant 

	FILE *fp;

	fp = fopen(strArchivo, "w");
	int i;
	int j;
	for (i=0; i<1025; i++) {
		strMensaje[i]='.';
	}
	strMensaje[1025-1] = 0;

	for (i=0; i<150; i++) {
		for (j=0; j<1024; j++) {
			fprintf(fp, "%s", strMensaje);
			//size_t fwrite(const void *ptr, size_t size_of_elements, size_t number_of_elements, FILE *a_file);
		}
	}

	fclose(fp);

	tsTiempoFinal = finalizarProcesoTiempo();
	finalizarProcesoEstado(&ruEstadoFinal);
	tsTiempoTotal = calcularTiempoTotal(tsTiempoInicial, tsTiempoFinal);
	time(&rawtimeFinal);
	printf("\nFIN %s\n", ctime(&rawtimeFinal));
	fflush(stdout);
	{
	//	mostrarTiempoTotal("Ej3", tsTiempoInicial);
	//	mostrarTiempoTotal("Ej3", tsTiempoFinal);
		mostrarTiempoTotal("Ej3", tsTiempoTotal);
		mostrarEstadoTotal("Ej3", ruEstadoFinal);
	}

}
