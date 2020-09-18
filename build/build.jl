using PackageCompiler, Libdl

PackageCompiler.create_sysimage(Symbol[:CG];
                                project=".",
                                precompile_execution_file="generate_precompile.jl",
                                sysimage_path="libcg.$(Libdl.dlext)",
                                incremental=false,
                                filter_stdlibs=true)
