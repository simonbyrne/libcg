using PackageCompiler, Libdl

PackageCompiler.create_sysimage(Symbol[:IterativeSolvers];
                                precompile_statements_file="precompile.jl",
                                sysimage_path="cg.$(Libdl.dlext)",
                                script="cg.jl")
