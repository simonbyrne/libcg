# libcg: Conjugate gradient for C in Julia

This serves as a proof-of-concept for writing dynamic libraries for C or other languages in Julia.

It creates a library for performing solving a matrix-free linear system via the conjugate gradient method. It wraps the [`cg!`](https://juliamath.github.io/IterativeSolvers.jl/stable/linear_systems/cg/#CG-1) function from IterativeSolvers.jl and exposes it as a C-callable interface using [PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl).

For an example using this, see [`main.c`](https://github.com/simonbyrne/cg/blob/master/main.c).
