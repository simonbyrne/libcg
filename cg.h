// Julia headers (for initialization and gc commands)
#include "uv.h"
#include "julia.h"


// prototype of the C entry points in our application
int julia_apply(int (*fptr)(double*,double*), double *y, double *x, size_t len);
