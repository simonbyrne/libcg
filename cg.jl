module CG

Base.@ccallable function julia_main()::Cint
    try
        println("hello world")
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

end # module
