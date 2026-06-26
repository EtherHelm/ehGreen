/* Benchmark: call ehGreen Green function via shared library (libehgreen.so) */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

/* Interface to kernel_piz exported from libehgreen.so
   p: pulsating source
   i: infinite water depth
   z: zero speed
   Fortran bind(C) passes scalars by reference (pointer) */
extern void kernel_piz(const double *r, const double *z, double res[4]);

#define NR 10000
#define NZ 1000

int main(void)
{
    double r[NR], z[NZ];
    double res[4], hh;
    int i, j, epoch;
    double start, finish;

    for (i = 0; i < NR; i++)
        r[i] = (double)i / NR;
    for (i = 0; i < NZ; i++)
        z[i] = (double)i / NZ;

    for (i = 0; i < NR; i++)
        r[i] *= 38.0;
    for (i = 0; i < NZ; i++)
        z[i] *= 15.0;

    printf("[INFO] Calling kernel_piz from libehgreen.so\n");

    /* Performance test (single thread) */
    for (epoch = 1; epoch <= 3; epoch++) {
        printf("--- Run %d (single thread, 10M calls) ---\n", epoch);
        start = omp_get_wtime();
        for (i = 0; i < NR; i++) {
            hh = r[i];
            for (j = 0; j < NZ; j++)
                kernel_piz(&hh, &z[j], res);
        }
        finish = omp_get_wtime();
        printf("    Elapsed: %8.3f s\n\n", finish - start);
    }

    /* Performance test (OpenMP multi-thread) */
    for (epoch = 1; epoch <= 3; epoch++) {
        printf("--- Run %d (OpenMP multi-thread, 10M calls) ---\n", epoch);
        start = omp_get_wtime();
#pragma omp parallel for private(j, hh, res)
        for (i = 0; i < NR; i++) {
            hh = r[i];
            for (j = 0; j < NZ; j++)
                kernel_piz(&hh, &z[j], res);
        }
        finish = omp_get_wtime();
        printf("    Elapsed: %8.3f s\n\n", finish - start);
    }

    return 0;
}
