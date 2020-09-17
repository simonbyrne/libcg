using PackageCompiler, Libdl

PackageCompiler.create_sysimage(Symbol[:IterativeSolvers];
                                project="lib",
                                precompile_statements_file="lib/precompile.jl",
                                sysimage_path="libcg.$(Libdl.dlext)",
                                script="lib/cg.jl",
                                incremental=false,
                                filter_stdlibs=true)
