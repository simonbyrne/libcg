using PackageCompiler, Libdl

PackageCompiler.create_sysimage(Symbol[:IterativeSolvers];
                                precompile_statements_file="precompile.jl",
                                sysimage_path="libcg.$(Libdl.dlext)",
                                script="cg.jl")
