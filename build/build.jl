using PackageCompiler, Libdl

PackageCompiler.create_sysimage(Symbol[:CG];
                                project=".",
                                precompile_execution_file=["build/generate_precompile.jl"],
                                precompile_statements_file=["build/additional_precompile.jl"],
                                sysimage_path="libcg.$(Libdl.dlext)",
                                incremental=false,
                                filter_stdlibs=true)
