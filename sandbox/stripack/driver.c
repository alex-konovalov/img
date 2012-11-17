#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include <math.h>

void trmesh_ (int *n, double *x, double *y, double *z,
	     int *list, int *lptr, int *lend, int *lnew,
	     int *__near, int *__next, double *__dist, int *ier);

void crlist_ (unsigned *n, unsigned *ncol, double *x, double *y, double *z,
	      int *list, unsigned *lptr, unsigned *lend, unsigned *lnew,
	      unsigned *__ltri, unsigned *__listc, unsigned *nb,
	      double *xc, double *yc, double *zc, double *rc, int *ier);

void trfind_ (int *nst, double *p, unsigned *n, double *x, double *y, double *z, int *list, unsigned *lptr, unsigned *lend, double *b1, double *b2, double *b3, int *i1, int *i2, int *i3);

static jmp_buf env;
static int activate_trap;

static void trap(void) {
  if (activate_trap)
    longjmp (env, 1);
}

int main(int argc, char *argv[]) {
  int i;
#if 0
  int n = 9;
  double x[9] = { 0.8, 0.0, -0.8, 0.6, 0.8, 0.0, 0.0, -1.0, 0.0 };
  double y[9] = { 0.6, 0.8, -0.6, 0.8, 0.0, 0.6, -1.0, 0.0, 0.0 };
  double z[9] = { 0.0, 0.6, 0.0, 0.0, 0.6, 0.8, 0.0, 0.0, -1.0 };
#elif 0
  int n = 3; /* 6 */
  double x[7] = { 1.0, 0.0, 0.0, -1.0, 0.0, 0.0 };
  double y[7] = { 0.0, 1.0, 0.0, 0.0, -1.0, 0.0 };
  double z[7] = { 0.0, 0.0, 1.0, 0.0, 0.0, -1.0 };
#elif 0
  int n = 3;
  double x[7] = { 1.0, 0.0, 0.0, 0.0 };
  double y[7] = { 0.0, 1.0, 0.0, -1.0 };
  double z[7] = { 0.0, 0.0, 1.0, 0.5 };
#else
  int n = 5;
  double x[5] = { -0.516749769175181 };
  double y[5] = { -0.839510890144121 };
  double z[5] = { -0.167902178028824 };
  for (i = 1; i < 5; i++) {
    x[i] = sin(M_PI*i/n);
    y[i] = 0.0;
    z[i] = cos(M_PI*i/n);
  }
#endif

  int list[100], lptr[100], lend[100], lnew, __near[100], __next[100], ier;
  double __dist[100];
  
  atexit (trap);
  activate_trap = 1;
  if (setjmp(env)) {
    atexit (trap);
    printf("trapped...");
  }

  trmesh_ ( &n, x, y, z, list, lptr, lend, &lnew, __near, __next, __dist, &ier);

  printf("lnew = %d, error %d\n", lnew, ier);
  for (i = 0; i < n; i++) {
    int e = lend[i]-1, j = e;
    do {
      j = lptr[j]-1;
      printf("edge %d: %d::%d\n", j, i+1, list[j]);
    } while (j!=e);
  }

  int nst = 1, ind[3];
  double p[3], b[3];
  for (i = 0; i < 3; i++)
    sscanf(argv[i+1], "%lg", p+i);

  trfind_ (&nst, p, &n, x, y, z, list, lptr, lend, b, b+1, b+2, ind, ind+1, ind+2);

  printf("indices (%d,%d,%d), coords (%lg,%lg,%lg)\n", ind[0], ind[1], ind[2], b[0], b[1], b[2]);

#if 1
  int ncol = 10;
  int ltri[1000], listc[1000], nb;
  double xc[1000], yc[1000], zc[1000], rc[1000];

  crlist_ ( &n, &ncol, x, y, z, list, lend, lptr, &lnew, ltri, listc, &nb, xc, yc, zc, rc, &ier);

  for (i = 0; i < 2*n-4; i++) {
    printf("center %d: (%lg,%lg,%lg), radius=%lg\n", i, xc[i], yc[i], zc[i], rc[i]);
  }
#endif

  activate_trap = 0;
  return 0;
}