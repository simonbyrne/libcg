#module CG

Base.@ccallable function julia_apply(fptr::Ptr{Cvoid}, cY::Ptr{Cdouble}, cX::Ptr{Cdouble}, len::Csize_t)::Cint
    try
        i = ccall(fptr, Cint, (Ptr{Cdouble}, Ptr{Cdouble}), cY, cX)
        i == 0 || throw("Oh no")
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

#end # module
