"""
Convert a unitful quantity to different units.

Is a generated function to allow for special casing, e.g. temperature conversion
"""
@generated function convert{T,U}(a::Units,
        x::Quantity{T,Dimensions{(Dimension{:Temperature}(1),)},U})
    xunits = x.parameters[3]
    aData = a()
    xData = xunits()
    conv = convert(aData, xData)

    xtup = xunits.parameters[1]
    atup = a.parameters[1]
    t0 = offsettemp(xtup[1])
    t1 = offsettemp(atup[1])
    quote
        v = ((x.val + $t0) * $conv) - $t1
        Quantity(v, a)
    end
end

@generated function convert{T,D,U}(a::Units, x::Quantity{T,D,U})
    xunits = x.parameters[3]
    aData = a()
    xData = xunits()
    conv = convert(aData, xData)

    quote
        v = x.val * $conv
        Quantity(v, a)
    end
end

"""
Find the conversion factor from unit `t` to unit `s`, e.g.
`convert(m,cm) = 0.01`.
"""
@generated function convert(s::Units, t::Units)
    sunits = s.parameters[1]
    tunits = t.parameters[1]

    # Check if conversion is possible in principle
    sdim = dimension(s())
    tdim = dimension(t())
    sdim != tdim && error("Dimensional mismatch.")

    # first convert to base SI units.
    # fact1 is what would need to be multiplied to get to base SI units
    # fact2 is what would be multiplied to get from the result to base SI units

    inex1, ex1 = basefactor(t())
    inex2, ex2 = basefactor(s())

    a = inex1 / inex2
    ex = ex1 // ex2     # do overflow checking?

    tens1 = mapreduce(+,tunits) do x
        tensfactor(x)
    end
    tens2 = mapreduce(+,sunits) do x
        tensfactor(x)
    end
    pow = tens1-tens2

    fpow = 10.0^pow
    if fpow > typemax(Int) || 1/(fpow) > typemax(Int)
        a *= fpow
    else
        comp = (pow > 0 ? fpow * num(ex) : 1/fpow * den(ex))
        if comp > typemax(Int)
            a *= fpow
        else
            ex *= (10//1)^pow
        end
    end

    a ≈ 1.0 ? (inex = 1) : (inex = a)
    y = inex * ex
    :($y)
end

convert{S}(s::Units{S}, t::Units{S}) = 1

convert{S,T,U,V,W}(::Type{Quantity{S,U,V}}, y::Quantity{T,U,W}) =
    Quantity(S(convert(V(),W())*y.val),V())
