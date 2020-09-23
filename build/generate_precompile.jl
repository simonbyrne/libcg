using CG

const len = 10

function laplace(py::Ptr{Float64}, px::Ptr{Float64})::Cint
    x = unsafe_wrap(Array, px, len)
    y = unsafe_wrap(Array, py, len)
    c = 0.01
    y[1] = x[1] - c*x[2]
    for i = 2:len-1
        y[i] = x[i] - c*(x[i-1] + x[i+1])
    end
    y[len] = x[len] - c*x[len-1]
    return Cint(0)
end

b = ones(len)
x = zeros(len)

CG.julia_cg(@cfunction(laplace,Cint,(Ptr{Float64}, Ptr{Float64})), pointer(x), pointer(b), Csize_t(len))
