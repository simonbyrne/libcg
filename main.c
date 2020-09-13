// Standard headers
#include <string.h>
#include <stdint.h>

// Julia headers (for initialization and gc commands)
#include "uv.h"
#include "julia.h"

JULIA_DEFINE_FAST_TLS()

// Forward declare C prototype of the C entry point in our application
int julia_main();

int main(int argc, char *argv[])
{
    uv_setup_args(argc, argv);

    // initialization
    libsupport_init();

    // JULIAC_PROGRAM_LIBNAME defined on command-line for compilation
    jl_options.image_file = JULIAC_PROGRAM_LIBNAME;
    julia_init(JL_IMAGE_JULIA_HOME);

    // call the work function, and get back a value
    int ret = julia_main();

    // Cleanup and gracefully exit
    jl_atexit_hook(ret);
    return ret;
}
