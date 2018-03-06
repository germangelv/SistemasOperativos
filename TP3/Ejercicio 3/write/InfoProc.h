#ifndef INFOPROC_H_
#define INFOPROC_H_
#include <sys/resource.h>
#include <sys/time.h>
#include <time.h>
#include <stdio.h>
#include <string.h>

void iniciarProcesoEstado(struct rusage *ruEstadoInicial);
void finalizarProcesoEstado(struct rusage *ruEstadoFinal);
struct timespec iniciarProcesoTiempo();
struct timespec finalizarProcesoTiempo();
//struct rusage calcularEstadoTotal(struct rusage ruEstadoInicial, struct rusage ruEstadoFinal);
struct timespec calcularTiempoTotal(struct timespec ruTiempoInicial, struct timespec ruTiempoFinal);
void mostrarEstadoTotal(char* id, struct rusage ruEstadoTotal);
void mostrarTiempoTotal(char* id, struct timespec ruTiempoTotal);
float getFloatTiempoSpec(struct timespec tiempo);
float getFloatTiempoVal(struct timeval tiempo);

#endif
