// Julia headers (for initialization and gc commands)
#include "uv.h"
#include "julia.h"


// prototype of the C entry points in our application
int julia_cg(int (*fptr)(double*,double*), double *x, double *b, size_t len);
