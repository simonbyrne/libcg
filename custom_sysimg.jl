Base.init_depot_path()
Base.init_load_path()

@eval Module() begin
    Base.include(@__MODULE__, "cg.jl")
    for (pkgid, mod) in Base.loaded_modules
        if !(pkgid.name in ("Main", "Core", "Base"))
            eval(@__MODULE__, :(const $(Symbol(mod)) = $mod))
        end
    end
    for statement in readlines("precompile.jl")
        try
            Base.include_string(@__MODULE__, statement)
        catch
            # See julia issue #28808
            Core.println("failed to compile statement: ", statement)
        end
    end
end # module

empty!(LOAD_PATH)
empty!(DEPOT_PATH)
