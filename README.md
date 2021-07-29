# libcg: Conjugate gradient for C in Julia

[![CI](https://github.com/simonbyrne/libcg/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/simonbyrne/libcg/actions/workflows/ci.yml)

This serves as a proof-of-concept for writing dynamic libraries for C or other languages in Julia.

It creates a library for performing solving a matrix-free linear system via the conjugate gradient method. It wraps the [`cg!`](https://julialinearalgebra.github.io/IterativeSolvers.jl/stable/linear_systems/cg/#CG-1) function from IterativeSolvers.jl and exposes it as a C-callable interface using [PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl).

Examples are provided for calling this from [C](https://github.com/simonbyrne/libcg/tree/master/main-c) and [Rust](https://github.com/simonbyrne/libcg/tree/master/main-rs).
