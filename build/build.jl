using PackageCompiler, Libdl

target_dir = get(ENV, "OUTDIR", "./target")

# Change Windows paths to use "/"
target_dir = replace(target_dir, "\\"=>"/")

println("Creating library in $target_dir")

PackageCompiler.create_library(".", target_dir;
                                lib_name="libcg",
                                precompile_execution_file=["build/generate_precompile.jl"],
                                precompile_statements_file=["build/additional_precompile.jl"],
                                incremental=false,
                                filter_stdlibs=true,
                                header_files = ["./cg.h"],
                            )
