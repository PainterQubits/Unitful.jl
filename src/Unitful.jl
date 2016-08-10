__precompile__(true)
module Unitful

import Base: ==, <, <=, +, -, *, /, .+, .-, .*, ./, .\, //, ^, .^
import Base: show, convert
import Base: abs, abs2, float, inv, sqrt
import Base: sin, cos, tan, cot, sec, csc
import Base: min, max, floor, ceil

import Base: mod, rem, div, fld, cld, trunc, round, sign, signbit
import Base: isless, isapprox, isinteger, isreal, isinf, isfinite
import Base: copysign, flipsign
import Base: prevfloat, nextfloat, maxintfloat, rat, step #, linspace
import Base: promote_op, promote_array_type, promote_rule, unsafe_getindex
import Base: length, float, start, done, next, last, one, zero, colon#, range
import Base: getindex, eltype, step, last, first, frexp
import Base: Rational, Complex, typemin, typemax
import Base: steprange_last, unitrange_last

export unit, unitless, dimension
export @dimension, @derived_dimension, @refunit, @unit
export Quantity

include("Types.jl")
include("User.jl")

"""
```
unitless(x::Quantity)
```

Strip units from a quantity and return the numeric value.
"""
unitless(x::Quantity) = x.val

"""
```
unitless(x::Number)
```

Returns `x`, since ordinary numbers have no units.
"""
unitless(x::Number) = x

"""
```
unit{T,D,U}(x::Quantity{T,D,U})
```

Returns the units associated with a quantity, `U()`.
"""
unit{T,D,U}(x::Quantity{T,D,U}) = U()

"""
```
unit(x::Number)
```

Returns a `Unitful.Units{()}` object to indicate that ordinary
numbers have no units.
"""
unit(x::Number) = Units{()}()

"""
```
dimension(x::Number)
```

Returns a `Unitful.Dimensions{()}` object to indicate that ordinary
numbers are dimensionless.
"""
dimension(x::Number) = Dimensions{()}()

"""
```
dimension{N}(u::Units{N})
```

Returns a [`Unitful.Dimensions`](@ref) object corresponding to the dimensions
of the units.
"""
dimension{N}(u::Units{N}) = mapreduce(dimension, *, N)

"""
```
dimension{T,D,U}(x::Quantity{T,D,U})
```

Returns a [`Unitful.Dimensions`](@ref) object `D()` corresponding to the
dimensions of quantity `x`.
"""
dimension{T,D,U}(x::Quantity{T,D,U}) = D()

function basefactorhelper(inex, ex, p)
    if isinteger(p)
        p = Integer(p)
    end

    can_exact = (ex < typemax(Int))
    can_exact &= (1/ex < typemax(Int))

    ex2 = float(ex)^p
    can_exact &= (ex2 < typemax(Int))
    can_exact &= (1/ex2 < typemax(Int))
    can_exact &= isinteger(p)

    if can_exact
        (inex^p, (ex//1)^p)
    else
        ((inex * ex)^p, 1)
    end
end

@generated function basefactor(x::Units)
    tunits = x.parameters[1]
    fact1 = map(basefactor, tunits)
    inex1 = mapreduce(x->getfield(x,1), *, fact1)
    ex1   = mapreduce(x->getfield(x,2), *, fact1)
    :(($inex1,$ex1))
end

function tensfactor(x::Unit)
    p = power(x)
    if isinteger(p)
        p = Integer(p)
    end
    tens(x)*p
end

# Addition / subtraction
for op in [:+, :-]
    @eval ($op){S,T,D,U}(x::Quantity{S,D,U}, y::Quantity{T,D,U}) =
        Quantity(($op)(x.val,y.val), U())

    # If not generated, there are run-time allocations
    @eval @generated function ($op){S,T,D,SU,TU}(x::Quantity{S,D,SU},
            y::Quantity{T,D,TU})
        result_units = SU() + TU()
        :($($op)(convert($result_units, x), convert($result_units, y)))
    end

    @eval ($op)(x::Quantity) = Quantity(($op)(x.val),unit(x))
end

*(x::Number, y::Units, z::Units...) = Quantity(x,*(y,z...))

# Kind of weird, but okay, no need to make things noncommutative.
*(x::Units, y::Number) = *(y,x)

# These six are defined for use in `*(a0::Unitlike, a::Unitlike...)`
unit{S}(x::Unit{S}) = S
unit{S}(x::Dimension{S}) = S
tens(x::Unit) = x.tens
tens(x::Dimension) = 0
power(x::Unit) = x.power
power(x::Dimension) = x.power

"""
```
*(a0::Unitlike, a::Unitlike...)
```

Given however many unit-like objects, multiply them together. The following
applies equally well to `Dimensions` instead of `Units`.

Collect [`Unitful.Unit`](@ref) objects from the type parameter of the
[`Unitful.Units`](@ref) objects. For identical units including SI prefixes
(i.e. cm ≠ m), collect powers and sort uniquely by the name of the unit.
The unique sorting permits easy unit comparisons.
"""
@generated function *(a0::Unitlike, a::Unitlike...)

    # Sort the units uniquely. This is a generated function so that we
    # don't have to figure out the units each time.

    D = (issubtype(a0,Units) ? Unit : Dimension)
    b = Array{D,1}()
    a0p = a0.parameters[1]
    length(a0p) > 0 && append!(b, a0p)
    for x in a
        xp = x.parameters[1]
        length(xp) > 0 && append!(b, xp)
    end

    sort!(b, by=x->power(x))
    D == Unit && sort!(b, by=x->tens(x))
    sort!(b, by=x->unit(x))

    # Units(m,m,cm,cm^2,cm^3,nm,m^4,µs,µs^2,s)
    # ordered as:
    # nm cm cm^2 cm^3 m m m^4 µs µs^2 s

    # Collect powers of a given unit
    c = Array{D,1}()
    i = start(b)
    oldstate = b[i]
    p=0//1
    while !done(b, i)
        (state, i) = next(b, i)
        if tens(state) == tens(oldstate) && unit(state) == unit(oldstate)
            p += power(state)
        else
            if p != 0
                push!(c, D{unit(oldstate)}(tens(oldstate),p))
            end
            p = power(state)
        end
        oldstate = state
    end
    if p != 0
        push!(c, D{unit(oldstate)}(tens(oldstate),p))
    end
    # results in:
    # nm cm^6 m^6 µs^3 s

    d = (c...)
    T = (issubtype(a0,Units) ? Units : Dimensions)
    :(($T){$d}())
end

@generated function *{T,D,U}(x::Quantity{T,D,U}, y::Units, z::Units...)
    result_units = *(U(),y(),map(x->x(),z)...)
    if isa(result_units,Units{()})
        :(x.val)
    else
        :(Quantity(x.val,$result_units))
    end
end

@generated function *(x::Quantity, y::Quantity)
    xunits = x.parameters[3]()
    yunits = y.parameters[3]()
    result_units = xunits*yunits
    quote
        z = x.val*y.val
        Quantity(z,$result_units)
    end
end

# Next two lines resolves some method ambiguity:
*{T<:Quantity}(x::Bool, y::T) =
    ifelse(x, y, ifelse(signbit(y), -zero(y), zero(y)))
*(x::Quantity, y::Bool) = Quantity(x.val*y, unit(x))

*(y::Number, x::Quantity) = *(x,y)
*(x::Quantity, y::Number) = Quantity(x.val*y, unit(x))

# See operators.jl
# Element-wise operations with units
for (f,F) in [(:./, :/), (:.*, :*), (:.+, :+), (:.-, :-)]
    @eval ($f)(x::Units, y::Units) = ($F)(x,y)
    @eval ($f)(x::Number, y::Units)   = ($F)(x,y)
    @eval ($f)(x::Units, y::Number)   = ($F)(x,y)
end
.\(x::Units, y::Units) = y./x
.\(x::Number, y::Units)   = y./x
.\(x::Units, y::Number)   = y./x

# See arraymath.jl
./(x::Units, Y::AbstractArray) =
    reshape([ x ./ y for y in Y ], size(Y))
./(X::AbstractArray, y::Units) =
    reshape([ x ./ y for x in X ], size(X))
.\(x::Units, Y::AbstractArray) =
    reshape([ x .\ y for y in Y ], size(Y))
.\(X::AbstractArray, y::Units) =
    reshape([ x .\ y for x in X ], size(X))

for f in (:.*,)
    @eval begin
        function ($f){T}(A::Units, B::AbstractArray{T})
            F = similar(B, promote_op($f,typeof(A),typeof(B)))
            for (iF, iB) in zip(eachindex(F), eachindex(B))
                @inbounds F[iF] = ($f)(A, B[iB])
            end
            return F
        end
        function ($f){T}(A::AbstractArray{T}, B::Units)
            F = similar(A, promote_op($f,typeof(A),typeof(B)))
            for (iF, iA) in zip(eachindex(F), eachindex(A))
                @inbounds F[iF] = ($f)(A[iA], B)
            end
            return F
        end
    end
end

# Division (floating point)

/(x::Units, y::Units)           = *(x,inv(y))
/(x::Dimensions, y::Dimensions) = *(x,inv(y))
/(x::Real, y::Units)            = Quantity(x,inv(y))
/(x::Units, y::Real)            = (1/y) * x
/(x::Quantity, y::Units)        = Quantity(x.val, unit(x) / y)
/(x::Quantity, y::Quantity)     = Quantity(x.val / y.val, unit(x) / unit(y))
/(x::Quantity, y::Real)         = Quantity(x.val / y, unit(x))
/(x::Real, y::Quantity)         = Quantity(x / y.val, inv(unit(y)))

# Division (rationals)

//(x::Units, y::Units)  = x/y
//(x::Real, y::Units)   = Rational(x)/y
//(x::Units, y::Real)   = (1//y) * x

//(x::Units, y::Quantity) = Quantity(1//y.val, x / unit(y))
//(x::Quantity, y::Units) = Quantity(x.val, unit(x) / y)
//(x::Quantity, y::Quantity) = Quantity(x.val // y.val, unit(x) / unit(y))

//(x::Quantity, y::Real) = Quantity(x.val // y, unit(x))
//(x::Real, y::Quantity) = Quantity(x // y.val, inv(unit(y)))

# Division (other functions)

for f in (:div, :fld, :cld)
    @eval function ($f)(x::Quantity, y::Quantity)
        z = convert(unit(y), x)
        ($f)(z.val,y.val)
    end
end

for f in (:mod, :rem)
    @eval function ($f)(x::Quantity, y::Quantity)
        z = convert(unit(y), x)
        Quantity(($f)(z.val,y.val), unit(y))
    end
end

# Exponentiation is not type stable.
# For now we define a special `inv` method to at least
# enable division to be fast.

for T in (:Units, :Dimensions)
    @eval @generated function inv(x::$T)
        tup = x.parameters[1]
        length(tup) == 0 && return :(x)
        tup2 = map(x->x^-1,tup)
        y = *($T{tup2}())
        :($y)
    end
end

^{T}(x::Unit{T}, y::Integer) = Unit{T}(tens(x),power(x)*y)
^{T}(x::Unit{T}, y) = Unit{T}(tens(x),power(x)*y)

^{T}(x::Dimension{T}, y::Integer) = Dimension{T}(power(x)*y)
^{T}(x::Dimension{T}, y) = Dimension{T}(power(x)*y)

for z in (:Units, :Dimensions)
    @eval begin
        function ^{T}(x::$z{T}, y::Integer)
            *($z{map(a->a^y, T)}())
        end

        function ^{T}(x::$z{T}, y)
            *($z{map(a->a^y, T)}())
        end
    end
end

^{T,D,U}(x::Quantity{T,D,U}, y::Integer) = Quantity((x.val)^y, U()^y)
^{T,D,U}(x::Quantity{T,D,U}, y::Rational) = Quantity((x.val)^y, U()^y)
^{T,D,U}(x::Quantity{T,D,U}, y::Real) = Quantity((x.val)^y, U()^y)

# Other mathematical functions

# This is a generated function to ensure type stability and keep `sqrt` fast.
@generated function sqrt(x::Units)
    tup = x.parameters[1]
    tup2 = map(x->x^(1//2),tup)
    y = *(Units{tup2}())
    :($y)
end

for (f, F) in [(:min, :<), (:max, :>)]
    @eval @generated function ($f)(x::Quantity, y::Quantity)
        xdim = x.parameters[2]()
        ydim = y.parameters[2]()
        if xdim != ydim
            return :(error("Dimensional mismatch."))
        end

        xunits = x.parameters[3].parameters[1]
        yunits = y.parameters[3].parameters[1]

        factx = mapreduce(.*, xunits) do x
            vcat(basefactor(x)...)
        end
        facty = mapreduce(.*, yunits) do x
            vcat(basefactor(x)...)
        end

        tensx = mapreduce(tensfactor, +, xunits)
        tensy = mapreduce(tensfactor, +, yunits)

        convx = *(factx..., (10.0)^tensx)
        convy = *(facty..., (10.0)^tensy)

        :($($F)(x.val*$convx, y.val*$convy) ? x : y)
    end

    @eval ($f)(x::Units, y::Units) =
        unit(($f)(Quantity(1.0, x), Quantity(1.0, y)))
end

sqrt(x::Quantity) = Quantity(sqrt(x.val), sqrt(unit(x)))
abs(x::Quantity) = Quantity(abs(x.val),  unit(x))
abs2(x::Quantity) = Quantity(abs2(x.val), unit(x)*unit(x))

trunc(x::Quantity) = Quantity(trunc(x.val), unit(x))
round(x::Quantity) = Quantity(round(x.val), unit(x))

copysign(x::Quantity, y::Number) = Quantity(copysign(x.val,unitless(y)), unit(x))
flipsign(x::Quantity, y::Number) = Quantity(flipsign(x.val,unitless(y)), unit(x))

isless{T,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) = isless(x.val, y.val)
isless(x::Quantity, y::Quantity) = isless(convert(unit(y), x).val,y.val)
<{T,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) = (x.val < y.val)
<(x::Quantity, y::Quantity) = <(convert(unit(y), x).val,y.val)

isapprox{T,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) = isapprox(x.val, y.val)
isapprox(x::Quantity, y::Quantity) = isapprox(convert(unit(y), x).val, y.val)

=={S,T,D,U}(x::Quantity{S,D,U}, y::Quantity{T,D,U}) = (x.val == y.val)
function ==(x::Quantity, y::Quantity)
    dimension(x) != dimension(y) && return false
    convert(unit(y), x).val == y.val
end

==(x::Quantity, y::Complex) = false
==(x::Quantity, y::Irrational) = false
==(x::Quantity, y::Number) = false
==(y::Complex, x::Quantity) = false
==(y::Irrational, x::Quantity) = false
==(y::Number, x::Quantity) = false
<=(x::Quantity, y::Quantity) = <(x,y) || x==y

for f in (:zero, :floor, :ceil)
    @eval ($f)(x::Quantity) = Quantity(($f)(x.val), unit(x))
end

one(x::Quantity) = one(x.val)
one{T,D,U}(x::Type{Quantity{T,D,U}}) = one(T)

isinteger(x::Quantity) = isinteger(x.val)
isreal(x::Quantity) = isreal(x.val)
isfinite(x::Quantity) = isfinite(x.val)
isinf(x::Quantity) = isinf(x.val)

sign(x::Quantity) = sign(x.val)
signbit(x::Quantity) = signbit(x.val)

prevfloat{T<:AbstractFloat,D,U}(x::Quantity{T,D,U}) =
    Quantity(prevfloat(x.val), unit(x))
nextfloat{T<:AbstractFloat,D,U}(x::Quantity{T,D,U}) =
    Quantity(nextfloat(x.val), unit(x))

function frexp{T<:AbstractFloat,D,U}(x::Quantity{T,D,U})
    a,b = frexp(x.val)
    a *= unit(x)
    a,b
end

float(x::Quantity) = Quantity(float(x.val), unit(x))
Integer(x::Quantity) = Quantity(Integer(x.val), unit(x))
Rational(x::Quantity) = Quantity(Rational(x.val), unit(x))

colon(start::Quantity, step::Quantity, stop::Quantity) =
    StepRange(promote(start, step, stop)...)

function Base.steprange_last{T<:Quantity}(start::T, step, stop)
    z = zero(step)
    step == z && throw(ArgumentError("step cannot be zero"))
    if stop == start
        last = stop
    else
        if (step > z) != (stop > start)
            last = start - step
        else
            diff = stop - start
            if T<:Signed && (diff > zero(diff)) != (stop > start)
                # handle overflowed subtraction with unsigned rem
                if diff > zero(diff)
                    remain = -convert(T, unsigned(-diff) % step)
                else
                    remain = convert(T, unsigned(diff) % step)
                end
            else
                remain = Base.steprem(start,stop,step)
            end
            last = stop - remain
        end
    end
    last
end

"""
```
offsettemp(::Unit)
```

For temperature units, this function is used to set the scale offset.
"""
offsettemp(::Unit) = 0

include("Display.jl")
include("Promotion.jl")
include("Conversion.jl")

# Default rules for addition and subtraction.
for op in [:+, :-]
    # Can change to min(x,y), x, or y
    @eval ($op)(x::Unitful.Units, y::Units) = max(x,y)
end

end
