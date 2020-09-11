using PackageCompiler, Libdl

PackageCompiler.create_sysimage(Symbol[];
                                sysimage_path="cg.dylib",
                                script="cg.jl")
