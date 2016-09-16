"""
```
uconvert{T,U}(a::Units, x::Quantity{T,U})
```

Convert a [`Unitful.Quantity`](@ref) to different units. The conversion will
fail if the target units `a` have a different dimension than the dimension of
the quantity `x`. You can use this method to switch between equivalent
representations of the same unit, like `N m` and `J`.

Example:

```jldoctest
julia> uconvert(u"hr",3602u"s")
1801//1800 hr
julia> uconvert(u"J",1.0u"N*m")
1.0 J
```
"""
function uconvert{T,D,U}(a::Units, x::Quantity{T,D,U})
    if typeof(a) == U
        Quantity(x.val, a)    # preserves numeric type if convfact is 1
    else
        Quantity(x.val * convfact(a, U()), a)
    end
end

"""
```
uconvert{T,U}(a::Units, x::Quantity{T,Dimensions{(Dimension{:Temperature}(1),)},U})
```

In this method, we are special-casing temperature conversion to respect scale
offsets, if they do not appear in combination with other dimensions.
"""
@generated function uconvert{T,D,U}(a::Units,
        x::Quantity{T,D,Units{U,Dimensions{(Dimension{:Temperature}(1),)}}})
    if a == U
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

function uconvert(a::Units, x::Number)
    if dimension(a) == Dimensions{()}()
        Quantity(x * convfact(a, Units{(), Dimensions{()}}()), a)
    else
        error("Dimensional mismatch.")
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

    tens1 = mapreduce(tensfactor, +, 0, tunits)
    tens2 = mapreduce(tensfactor, +, 0, sunits)

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

Returns 1. (Avoids effort when unnecessary.)
"""
convfact{S}(s::Units{S}, t::Units{S}) = 1

"""
```
convert{T,D,U}(::Type{Quantity{T,D,U}}, x::Number)
```

Direct type conversion using `convert` is permissible provided conversion
is between two quantities of the same dimension.
"""
function convert{T,D,U}(::Type{Quantity{T,D,U}}, x::Number)
    if dimension(x) == D()
        if U == Units{(), Dimensions{()}}   # catch UnitlessQuantity
            return UnitlessQuantity{T}(x.val)
        else
            return Quantity(T(uconvert(U(),x).val), U())
        end
    else
        error("Dimensional mismatch.")
    end
end

function convert{D}(::Type{DimensionedQuantity{D}}, x::Quantity)
    if dimension(x) == D()
        return x
    else
        error("Dimensional mismatch.")
    end
end

"""
```
convert{T}(::Type{UnitlessQuantity{T}}, x::Quantity)
```

Attempt conversion of `x` to a [`Unitful.UnitlessQuantity`](@ref) type.
"""
function convert{T}(::Type{UnitlessQuantity{T}}, x::Quantity)
    if isa(x, UnitlessQuantity)
        UnitlessQuantity{T}(x.val)
    else
        error("Dimensional mismatch.")
    end
end

"""
```
convert{T,U}(::Type{DimensionlessQuantity{T,U}}, x::Number)
```

Convert `x` to a [`Unitful.DimensionlessQuantity`](@ref) type.
"""
convert{T,U}(::Type{DimensionlessQuantity{T,U}}, x::Number) =
    uconvert(U(), convert(T,x))

convert(::Type{Number}, y::Quantity) = y
convert{T<:Real}(::Type{T}, y::Quantity) =
    T(uconvert(NoUnits, y))
convert{T<:Complex}(::Type{T}, y::Quantity) =
    T(uconvert(NoUnits, y))
