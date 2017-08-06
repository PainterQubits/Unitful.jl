"""
    uconvert{T,D,U}(a::Units, x::Quantity{T,typeof(𝚯),<:TemperatureUnits})
In this method, we are special-casing temperature conversion to respect scale
offsets, if they do not appear in combination with other dimensions.
"""
@generated function uconvert(a::Units,
        x::Quantity{T,typeof(𝚯),<:TemperatureUnits}) where {T}
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
