"""
    convfact(s::Units, t::Units)
Find the conversion factor from unit `t` to unit `s`, e.g., `convfact(m,cm) == 1//100`.
"""
@generated function convfact(s::Units, t::Units)
    sunits = s.parameters[1]
    tunits = t.parameters[1]

    # Check if conversion is possible in principle
    sdim = dimension(s())
    tdim = dimension(t())
    sdim != tdim && throw(DimensionError(s(),t()))

    # first convert to base SI units.
    # fact1 is what would need to be multiplied to get to base SI units
    # fact2 is what would be multiplied to get from the result to base SI units

    inex1, ex1 = basefactor(t())
    inex2, ex2 = basefactor(s())

    a = inex1 / inex2
    ex = ex1 // ex2     # do overflow checking?

    tens1 = mapreduce(tensfactor, +, tunits; init=0)
    tens2 = mapreduce(tensfactor, +, sunits; init=0)

    pow = tens1-tens2

    fpow = 10.0^pow
    if fpow > typemax(Int) || 1/(fpow) > typemax(Int)
        a *= fpow
    else
        comp = (pow > 0 ? fpow * numerator(ex) : 1/fpow * denominator(ex))
        if comp > typemax(Int)
            a *= fpow
        else
            ex *= (10//1)^pow
        end
    end

    if ex isa Rational && denominator(ex) == 1
        ex = numerator(ex)
    end
    a ≈ 1.0 ? (inex = 1) : (inex = a)
    y = inex * ex
    :($y)
end

"""
    convfact{S}(s::Units{S}, t::Units{S})
Returns 1. (Avoids effort when unnecessary.)
"""
convfact(s::Units{S}, t::Units{S}) where {S} = 1

"""
    uconvert(a::Units, x::Quantity{T,D,U}) where {T,D,U}
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
function uconvert(a::Units, x::Quantity{T,D,U}) where {T,D,U}
    if typeof(a) == U
        return Quantity(x.val, a)    # preserves numeric type if convfact is 1
    elseif (a isa AffineUnits) || (x isa AffineQuantity)
        return uconvert_affine(a, x)
    else
        return Quantity(x.val * convfact(a, U()), a)
    end
end

function uconvert(a::Units, x::Number)
    if dimension(a) == NoDims
        Quantity(x * convfact(a, NoUnits), a)
    else
        throw(DimensionError(a,x))
    end
end

uconvert(a::Units, x::Missing) = missing

@generated function uconvert_affine(a::Units, x::Quantity)
    # TODO: test, may be able to get bad things to happen here when T<:LogScaled
    auobj = a()
    xuobj = x.parameters[3]()
    conv = convfact(auobj, xuobj)

    t0 = x <: AffineQuantity ? x.parameters[3].parameters[end].parameters[end] :
        :(zero($(x.parameters[1])))
    t1 = a <: AffineUnits ? a.parameters[end].parameters[end] :
        :(zero($(x.parameters[1])))
    quote
        dimension(a) != dimension(x) && return throw(DimensionError(a, x))
        return Quantity(((x.val - $t0) * $conv) + $t1, a)
    end
end

function convert(::Type{Quantity{T,D,U}}, x::Number) where {T,D,U}
    if dimension(x) == D
        Quantity(T(uconvert(U(),x).val), U())
    else
        throw(DimensionError(U(),x))
    end
end

# needed ever since julialang/julia#28216
convert(::Type{Quantity{T,D,U}}, x::Quantity{T,D,U}) where {T,D,U} = x

function convert(::Type{Quantity{T,D}}, x::Quantity) where {T,D}
    (dimension(x) !== D) && throw(DimensionError(D, x))
    return Quantity{T,D,typeof(unit(x))}(convert(T, x.val))
end
function convert(::Type{Quantity{T,D}}, x::Number) where {T,D}
    (D !== NoDims) && throw(DimensionError(D, NoDims))
    Quantity{T,NoDims,typeof(NoUnits)}(x)
end
function convert(::Type{Quantity{T}}, x::Quantity) where {T}
    Quantity{T,dimension(x),typeof(unit(x))}(convert(T, x.val))
end
function convert(::Type{Quantity{T}}, x::Number) where {T}
    Quantity{T,NoDims,typeof(NoUnits)}(x)
end

convert(::Type{DimensionlessQuantity{T,U}}, x::Number) where {T,U} =
    uconvert(U(), convert(T,x))
function convert(::Type{DimensionlessQuantity{T,U}}, x::Quantity) where {T,U}
    if dimension(x) == NoDims
        _Quantity(T(x.val), U())
    else
        throw(DimensionError(NoDims,x))
    end
end

convert(::Type{Number}, y::Quantity) = y
convert(::Type{T}, y::Quantity) where {T <: Real} =
    T(uconvert(NoUnits, y))
convert(::Type{T}, y::Quantity) where {T <: Complex} =
    T(uconvert(NoUnits, y))
