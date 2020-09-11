using PackageCompiler, Libdl

PackageCompiler.create_sysimage(Symbol[];
                                sysimage_path="cg.$(Libdl.dlext)",
                                script="cg.jl")
