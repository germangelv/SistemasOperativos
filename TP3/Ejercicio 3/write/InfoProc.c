#include "InfoProc.h"

void iniciarProcesoEstado(struct rusage *ruEstadoInicial)
{
	bzero(ruEstadoInicial, sizeof(struct rusage));
	getrusage(RUSAGE_SELF, ruEstadoInicial);
}

void finalizarProcesoEstado(struct rusage *ruEstadoFinal)
{
	bzero(ruEstadoFinal, sizeof(struct rusage));
	getrusage(RUSAGE_SELF, ruEstadoFinal);
}

struct timespec iniciarProcesoTiempo()
{
	struct timespec tsTiempoInicial;
	clock_gettime(CLOCK_MONOTONIC_RAW, &tsTiempoInicial);
	return tsTiempoInicial;
}

struct timespec finalizarProcesoTiempo()
{
	struct timespec tsTiempoFinal;
	clock_gettime(CLOCK_MONOTONIC_RAW, &tsTiempoFinal);
	return tsTiempoFinal;
}

//struct rusage calcularEstadoTotal(struct rusage ruEstadoInicial, struct rusage ruEstadoFinal)
//{
//	struct rusage ruEstadoTotal;
//	return ruEstadoTotal;
//}

struct timespec calcularTiempoTotal(struct timespec tiempoInicial, struct timespec tiempoFinal)
{
	struct timespec tiempoTotal;
//	time_t   tv_sec;        /* seconds */
//	long     tv_nsec;       /* nanoseconds */
	if ((tiempoFinal.tv_nsec - tiempoInicial.tv_nsec) < 0) {
		tiempoTotal.tv_sec = tiempoFinal.tv_sec - tiempoInicial.tv_sec - 1;
		tiempoTotal.tv_nsec = tiempoFinal.tv_nsec - tiempoInicial.tv_nsec + 1000000000;
	} else {
		tiempoTotal.tv_sec = tiempoFinal.tv_sec - tiempoInicial.tv_sec;
		tiempoTotal.tv_nsec = tiempoFinal.tv_nsec - tiempoInicial.tv_nsec;
	}
//	tiempoTotal.tv_sec = tiempoFinal.tv_sec - tiempoInicial.tv_sec;
//	tiempoTotal.tv_nsec = tiempoFinal.tv_nsec - tiempoInicial.tv_nsec;
	return tiempoTotal;
}

void mostrarEstadoTotal(char* id, struct rusage ruEstadoTotal)
{
/*
struct timeval ru_utime; user CPU time used 
struct timeval ru_stime; system CPU time used 
long   ru_maxrss;        maximum resident set size 
long   ru_ixrss;         integral shared memory size 
long   ru_idrss;         integral unshared data size 
long   ru_isrss;         integral unshared stack size 
long   ru_minflt;        page reclaims (soft page faults) 
long   ru_majflt;        page faults (hard page faults) 
long   ru_nswap;         swaps 
long   ru_inblock;       block input operations 
long   ru_oublock;       block output operations 
long   ru_msgsnd;        IPC messages sent 
long   ru_msgrcv;        IPC messages received 
long   ru_nsignals;      signals received 
long   ru_nvcsw;         voluntary context switches 
long   ru_nivcsw;        involuntary context switches 
ru_utime
This is the total amount of time spent executing in user mode, expressed in a timeval structure (seconds plus microseconds).
ru_stime
This is the total amount of time spent executing in kernel mode, expressed in a timeval structure (seconds plus microseconds).
ru_minflt
The number of page faults serviced without any I/O activity; here I/O activity is avoided by "reclaiming" a page frame from the list of pages awaiting reallocation.
ru_majflt
The number of page faults serviced that required I/O activity.
ru_nswap (unmaintained)
This field is currently unused on Linux.
ru_inblock (since Linux 2.6.22)
The number of times the file system had to perform input.
ru_oublock (since Linux 2.6.22)
The number of times the file system had to perform output.
ru_msgsnd (unmaintained)
This field is currently unused on Linux.
ru_msgrcv (unmaintained)
This field is currently unused on Linux.
ru_nsignals (unmaintained)
This field is currently unused on Linux.
ru_nvcsw (since Linux 2.6)
The number of times a context switch resulted due to a process voluntarily giving up the processor before its time slice was completed (usually to await availability of a resource).
ru_nivcsw (since Linux 2.6)
The number of times a context switch resulted due to a higher priority process becoming runnable or because the current process exceeded its time slice.
*/
/*
Tiempo reloj
Tiempo CPU sistema total
Tiempo CPU usuario total
Cantidad de Soft Page Faults
Cantidad de Hard Page Faults
Operaciones de Entrada (en bloques)
Operaciones de Salida (en bloques)
Mensajes IPC enviados
Mensajes IPC recibidos
*/
	printf("%s- Tiempo CPU sistema total: %2.9f\n", id, getFloatTiempoVal(ruEstadoTotal.ru_stime));
	printf("%s- Tiempo CPU usuario total: %2.9f\n", id, getFloatTiempoVal(ruEstadoTotal.ru_utime));
	//printf("%s- Tiempo CPU sistema total: %lld.%lld\n", id, (long long)ruEstadoTotal.ru_stime.tv_sec, (long long)ruEstadoTotal.ru_stime.tv_usec);
	//printf("%s- Tiempo CPU usuario total: %lld.%lld\n", id, (long long)ruEstadoTotal.ru_utime.tv_sec, (long long)ruEstadoTotal.ru_utime.tv_usec);
	printf("%s- Cantidad de Soft Page Faults total: %lld\n", id, (long long)ruEstadoTotal.ru_minflt);
	printf("%s- Cantidad de Hard Page Faults total: %lld\n", id, (long long)ruEstadoTotal.ru_majflt);
	printf("%s- Operaciones de Entrada total: %lld\n", id, (long long)ruEstadoTotal.ru_inblock);
	printf("%s- Operaciones de Salida total: %lld\n", id, (long long)ruEstadoTotal.ru_oublock);
	printf("%s- Mensajes IPC enviados total: %lld\n", id, (long long)ruEstadoTotal.ru_msgsnd);
	printf("%s- Mensajes IPC recibidos total: %lld\n", id, (long long)ruEstadoTotal.ru_msgrcv);
	return;
}

void mostrarTiempoTotal(char* id, struct timespec tiempoTotal)
{
	printf("%s- Tiempo: %2.9f\n", id, getFloatTiempoSpec(tiempoTotal));
	//printf("%s- Tiempo: %lld.%lld\n", id, (long long)tiempoTotal.tv_sec, (long long)tiempoTotal.tv_nsec);
	return;
}

float getFloatTiempoSpec(struct timespec tiempo)
{
	float f;
	char strTmp[25];
	sprintf(strTmp, "%lld.%09lld", (long long)tiempo.tv_sec, (long long)tiempo.tv_nsec);
	sscanf(strTmp, "%f", &f);
	//printf("TiempoSpec1: %2.9f\n", f);
	//printf("TiempoSpec2: %lld.%09lld\n", (long long)tiempo.tv_sec, (long long)tiempo.tv_nsec);
	return f;
}

float getFloatTiempoVal(struct timeval tiempo)
{
	float f;
	char strTmp[25];
	sprintf(strTmp, "%lld.%06lld", (long long)tiempo.tv_sec, (long long)tiempo.tv_usec);
	sscanf(strTmp, "%f", &f);
	//printf("TiempoVal1: %2.9f\n", f);
	//printf("TiempoVal2: %lld.%06lld\n", (long long)tiempo.tv_sec, (long long)tiempo.tv_usec);
	return f;
}
