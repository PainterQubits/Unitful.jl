"""
    offsettemp(::Unit)
For temperature units, this function is used to set the scale offset.
"""
offsettemp(::Unit) = 0

"""
    uconvert{T,D,U}(a::Units, x::Quantity{T,typeof(𝚯),<:TemperatureUnits})
In this method, we are special-casing temperature conversion to respect scale
offsets, if they do not appear in combination with other dimensions.
"""
@generated function uconvert(a::Units,
        x::Quantity{T,typeof(abs𝚯),<:AbsTemperatureUnits}) where {T}
    # TODO: test, may be able to get bad things to happen here when T<:LogScaled
    if a == typeof(unit(x))
        :(Quantity(x.val, a))
    else
        xunits = x.parameters[3]
        aData = a()
        xData = xunits()
        conv = convfact(aData, xData)

        xtup = xunits.parameters[1]
        atup = a.parameters[1]
        t0 = offsettemp(xtup[1])
        t1 = offsettemp(atup[1])
        quote
            v = ((x.val + $t0) * $conv) - $t1
            Quantity(v, a)
        end
    end
end

for t in [:°C, :°F, :K]
    @eval relative_unit(::typeof($(Symbol(:abs, t)))) = $t
end


for op in [:+, :*, :/]
    # Disallow binary arithmetic on absolute temperatures
    @eval ($op)(x::Quantity{S,typeof(abs𝚯),U1},
        y::Quantity{T,typeof(abs𝚯),U2}) where {S,T,U1,U2} =
        throw(DimensionError(x, y))   # TODO: custom error?
end

for op in [:+, :-]
    # absolute +/- relative = absolute
    @eval ($op)(x::Quantity{S,typeof(abs𝚯),U1},
                y::Quantity{T,typeof(𝚯),U2}) where {S,T,D,U1,U2} =
        Quantity($op(ustrip(x),ustrip(uconvert(relative_unit(unit(x)), y))), unit(x))
end

(-)(x::Quantity{S,typeof(abs𝚯),U1},
    y::Quantity{T,typeof(abs𝚯),U2}) where {S,T,D,U1,U2} =
    Quantity(ustrip(x) - ustrip(uconvert(unit(x), y)), relative_unit(unit(x)))


Base.promote_rule(::Type{Quantity{S1,typeof(abs𝚯),U1}},
                  ::Type{Quantity{S2,typeof(abs𝚯),U2}}) where {S1,U1,S2,U2} =
    # Not sure when this will be called, but it's safer to disallow
    # promotion between absolute temperatures.
    throw(DimensionError(U1(), U2()))  
