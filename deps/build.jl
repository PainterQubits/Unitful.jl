if isfile(joinpath(dirname(@__FILE__), "userdefaults.jl"))
    warn("`Pkg.build(\"Unitful.jl\")` was run, but $(joinpath(dirname(@__FILE__),
        "userdefaults.jl")) already exists. No action has been taken. ",
        "If you encounter problems, you might consider backing up ",
        "then deleting the existing file at $(joinpath(dirname(@__FILE__),
        "userdefaults.jl")), then running `Pkg.build(\"Unitful\")` again.")
else
    info("Default units, dimensions, and logic are set in ",
        "$(escape_string(joinpath(dirname(@__FILE__), "userdefaults.jl")))")
    open(joinpath(dirname(@__FILE__), "userdefaults.jl"), "w") do f
        print(f, """
        # Specify preferred unit for promotion.
        # This is separate from the @refunit macro for flexibility; consider that
        # the SI unit of mass is not g but instead kg, and yet some people use cgs units.
        # This macro should only be used with units having "pure" dimensions like 𝐋, 𝐓, 𝐈, etc.
        @preferunit m
        @preferunit s
        @preferunit A
        @preferunit K
        @preferunit cd
        @preferunit kg
        @preferunit mol

        # By default, pick the units specified by the @preferunit macro.
        # Our use of promote_rule here is only via promote_type;
        # We will never be promoting unit objects themselves.
        function promote_rule{S<:Units,T<:Units}(::Type{S}, ::Type{T})
            dS = dimension(S())
            dT = dimension(T())
            dS != dT && error("Dimensions are unequal in call to `promote_rule`.")
            typeof(upreferred(dS))
        end

        # You could also add rules like the following, which will not interfere with
        # the generic behavior for other dimensions:
        promote_rule{S<:EnergyUnit, T<:EnergyUnit}(::Type{S}, ::Type{T}) = typeof(J)
        promote_rule{S<:ForceUnit, T<:ForceUnit}(::Type{S}, ::Type{T}) = typeof(N)
        promote_rule{S<:PowerUnit, T<:PowerUnit}(::Type{S}, ::Type{T}) = typeof(W)
        promote_rule{S<:PressureUnit, T<:PressureUnit}(::Type{S}, ::Type{T}) = typeof(Pa)
        promote_rule{S<:ChargeUnit, T<:ChargeUnit}(::Type{S}, ::Type{T}) = typeof(C)
        promote_rule{S<:VoltageUnit, T<:VoltageUnit}(::Type{S}, ::Type{T}) = typeof(V)
        promote_rule{S<:ResistanceUnit, T<:ResistanceUnit}(::Type{S}, ::Type{T}) = typeof(Ω)
        promote_rule{S<:CapacitanceUnit, T<:CapacitanceUnit}(::Type{S}, ::Type{T}) = typeof(F)
        promote_rule{S<:InductanceUnit, T<:InductanceUnit}(::Type{S}, ::Type{T}) = typeof(H)
        promote_rule{S<:MagneticFluxUnit, T<:MagneticFluxUnit}(::Type{S}, ::Type{T}) = typeof(Wb)
        promote_rule{S<:BFieldUnit, T<:BFieldUnit}(::Type{S}, ::Type{T}) = typeof(T)
        """)
    end
end
