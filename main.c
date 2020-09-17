#include <stdio.h>
#include <stdlib.h>

// Julia headers (for initialization and gc commands)
#include "uv.h"
#include "julia.h"
#include "cg.h"

JULIA_DEFINE_FAST_TLS()


size_t len = 10;

int laplace(double *y, double *x)
{
  double c = 0.01;
  y[0] = x[0] - c * x[1];
  for (int i=1; i<len-1; i++) {
    y[i] = x[i] - c * (x[i-1] + x[i+1]);
  }
  y[len-1] = x[len-1] - c * x[len-2];
  return 0;
}

int main(int argc, char *argv[])
{
  // initialization of libuv and julia
  uv_setup_args(argc, argv);
  libsupport_init();
  jl_parse_opts(&argc, &argv);
  // JULIAC_PROGRAM_LIBNAME defined on command-line for compilation
  jl_options.image_file = JULIAC_PROGRAM_LIBNAME;
  julia_init(JL_IMAGE_JULIA_HOME);

  int ret;
  double *b = (double *)malloc(len * sizeof(double));
  double *x = (double *)malloc(len * sizeof(double));

  for (int i=0; i<len; i++) {
    x[i] = 0.0;
    b[i] = 1.0;
  };

  ret = julia_cg(&laplace, x, b, len);
  if (ret) {
    goto done;
  }

  // check
  double *y = (double *)malloc(len * sizeof(double));
  laplace(y, x);

  double norm2 = 0.0;
  double d;
  for (int i=0; i<len; i++) {
    d = (b[i] - y[i]);
    norm2 += d*d;
  };

  if (norm2 < 1e-10) {
    printf("success");
  } else {
    ret |= 1;
    printf("norm: %f", sqrt(norm2));
  }

  // Cleanup and gracefully exit
 done:
  jl_atexit_hook(ret);
  return ret;
}
