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

    // Initialize Core.ARGS with the full argv.
    jl_set_ARGS(argc, argv);

    // Set PROGRAM_FILE to argv[0].
    jl_set_global(jl_base_module,
        jl_symbol("PROGRAM_FILE"), (jl_value_t*)jl_cstr_to_string(argv[0]));

    // Set Base.ARGS to `String[ unsafe_string(argv[i]) for i = 1:argc ]`
    jl_array_t *ARGS = (jl_array_t*)jl_get_global(jl_base_module, jl_symbol("ARGS"));
    jl_array_grow_end(ARGS, argc - 1);
    for (int i = 1; i < argc; i++) {
        jl_value_t *s = (jl_value_t*)jl_cstr_to_string(argv[i]);
        jl_arrayset(ARGS, s, i - 1);
    }

    // call the work function, and get back a value
    int ret = julia_main();

    // Cleanup and gracefully exit
    jl_atexit_hook(ret);
    return ret;
}
