module CG

using IterativeSolvers, LinearAlgebra

# define interface to call a function pointer as a matrix-free operator
struct COp
    fptr::Ptr{Cvoid}
    n::Int
end

Base.eltype(A::COp) = Float64
Base.size(A::COp, d) = d <= 2 ? A.n : 1

function LinearAlgebra.mul!(y::StridedVector{Float64}, A::COp, x::StridedVector{Float64})
    @assert stride(x,1) == 1
    @assert stride(y,1) == 1
    i = ccall(A.fptr, Cint, (Ptr{Cdouble}, Ptr{Cdouble}), y, x)
    i == 0 || throw("Oh no")
    return y
end
function Base.:*(A::COp, x::AbstractVector{Float64})
    LinearAlgebra.mul!(similar(x), A, x)
end



Base.@ccallable function julia_cg(fptr::Ptr{Cvoid}, cx::Ptr{Cdouble}, cb::Ptr{Cdouble}, len::Csize_t)::Cint
    try
        x = unsafe_wrap(Array, cx, (len,))
        b = unsafe_wrap(Array, cb, (len,))
        A = COp(fptr,len)
        cg!(x, A, b)
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

end # module
