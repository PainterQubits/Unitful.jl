"""
```
uconvert{T,D,U}(a::Units, x::Quantity{T,D,U})
```

Unit-convert a quantity to different units of the same dimension.
"""
@generated function uconvert{T,D,U}(a::Units, x::Quantity{T,D,U})
    xunits = x.parameters[3]
    aData = a()
    xData = xunits()
    conv = convfact(aData, xData)

    quote
        v = x.val * $conv
        Quantity(v, a)
    end
end

"""
```
uconvert{T,U}(a::Units,
x::Quantity{T,Dimensions{(Dimension{:Temperature}(1),)},U})
```

Unit-convert a quantity to different units of the same dimension. In this case,
we are special-casing temperature to respect scale offsets if not combined
with other dimensions.
"""
@generated function uconvert{T,U}(a::Units,
        x::Quantity{T,Dimensions{(Dimension{:Temperature}(1),)},U})
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

"""
```
convfact(s::Units, t::Units)
```

Find the conversion factor from unit `t` to unit `s`, e.g. `convfact(m,cm) = 0.01`.
"""
@generated function convfact(s::Units, t::Units)
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

    tens1 = mapreduce(+,0,tunits) do x
        tensfactor(x)
    end
    tens2 = mapreduce(+,0,sunits) do x
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

"""
```
convfact{S}(s::Units{S}, t::Units{S})
```

Returns 1. (Avoid effort when unnecessary.)
"""
convfact{S}(s::Units{S}, t::Units{S}) = 1

"""
```
convert{S,T,U,V,W}(::Type{Quantity{S,U,V}}, y::Quantity{T,U,W})
```

Extends `Base.convert` for unitful quantities.
"""
convert{S,T,U,V,W}(::Type{Quantity{S,U,V}}, y::Quantity{T,U,W}) =
    Quantity(S(convfact(V(),W())*y.val),V())
