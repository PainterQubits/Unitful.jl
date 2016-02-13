"Copyright Andrew J. Keller, 2016"

module Unitful

import Base: ==, <, <=, +, -, *, /, .+, .-, .*, ./, //, ^
import Base: show, convert
import Base: abs, float, inv, sqrt
import Base: sin, cos, tan, cot, sec, csc
import Base: min, max, floor, ceil

import Base: mod, rem, div, fld, cld, trunc, round, sign, signbit
import Base: isless, isapprox, isinteger, isreal, isinf, isfinite
import Base: prevfloat, nextfloat, maxintfloat, rat, step, linspace
import Base: promote_op, promote_rule, unsafe_getindex, colon
import Base: length, float, range, start, done, next, last, one, zero
import Base: getindex, eltype, step, last, first, frexp
import Base: Rational

export baseunit
export dimension
export power
export tens
export unit, unitless

export Quantity, FloatQuantity, RealQuantity
export UnitDatum, UnitData

# Dimensions
@enum(Dimension,
    _Mass, _Length, _Time, _Current, _Temperature, _Amount, _Luminosity, _Angle)

"`abbr(x)` provides a string that can be used to print units."
function abbr end

abbr(x) = "???"     # Indicate missing abbreviations

abbr(::Type{Val{_Length}})      = "[L]"
abbr(::Type{Val{_Mass}})        = "[M]"
abbr(::Type{Val{_Time}})        = "[T]"
abbr(::Type{Val{_Current}})     = "[I]"
abbr(::Type{Val{_Temperature}}) = "[Θ]"
abbr(::Type{Val{_Amount}})      = "[N]"
abbr(::Type{Val{_Luminosity}})  = "[J]"
abbr(::Type{Val{_Angle}})       = "[°]"

# Units
@enum(Unit,
_Mile, _Yard, _Foot, _Inch, _Meter,
_Are, _Acre,
_Second, _Minute, _Hour, _Day, _Week,
_Gram,
_Ampere,
_Kelvin, _Celsius, _Rankine, _Fahrenheit,
_Mole,
_Candela,
_Degree, _Radian,
_Newton,
_Pascal,
_Watt,
_Joule, _eV,
_Coulomb,
_Volt,
_Ohm,
_Siemens,
_Farad,
_Henry,
_Tesla,
_Weber)

# Length
abbr(::Type{Val{_Meter}})      = "m"
abbr(::Type{Val{_Mile}})       = "mi"
abbr(::Type{Val{_Yard}})       = "yd"
abbr(::Type{Val{_Foot}})       = "ft"
abbr(::Type{Val{_Inch}})       = "in"

# Area
abbr(::Type{Val{_Are}})        = "a"
abbr(::Type{Val{_Acre}})       = "ac"

# Time
abbr(::Type{Val{_Second}})     = "s"
abbr(::Type{Val{_Minute}})     = "min"
abbr(::Type{Val{_Hour}})       = "h"
abbr(::Type{Val{_Day}})        = "d"
abbr(::Type{Val{_Week}})       = "wk"

# Mass
abbr(::Type{Val{_Gram}})       = "g"

# Current
abbr(::Type{Val{_Ampere}})     = "A"

# Temperature
abbr(::Type{Val{_Kelvin}})     = "K"
abbr(::Type{Val{_Celsius}})    = "°C"
abbr(::Type{Val{_Rankine}})    = "°Ra"
abbr(::Type{Val{_Fahrenheit}}) = "°F"

# Amount
abbr(::Type{Val{_Mole}})       = "mol"

# Luminosity
abbr(::Type{Val{_Candela}})    = "cd"

# Angle
abbr(::Type{Val{_Degree}})     = "°"
abbr(::Type{Val{_Radian}})     = "rad"

# Derived units
abbr(::Type{Val{_Newton}})     = "N"
abbr(::Type{Val{_Pascal}})     = "Pa"
abbr(::Type{Val{_Watt}})       = "W"
abbr(::Type{Val{_Joule}})      = "J"
abbr(::Type{Val{_eV}})         = "eV"
abbr(::Type{Val{_Coulomb}})    = "C"
abbr(::Type{Val{_Volt}})       = "V"
abbr(::Type{Val{_Ohm}})        = "Ω"
abbr(::Type{Val{_Siemens}})    = "S"
abbr(::Type{Val{_Farad}})      = "F"
abbr(::Type{Val{_Henry}})      = "H"
abbr(::Type{Val{_Tesla}})      = "T"
abbr(::Type{Val{_Weber}})      = "Wb"

"""
`dimension(x)` specifies a `Dict` containing how many powers of each
dimension correspond to a given unit. It should be implemented for all units.
"""
function dimension end

for x in [_Meter, _Mile, _Yard, _Foot, _Inch]
    @eval dimension(::Type{Val{$x}}) = Dict(_Length=>1)
end

for x in [_Are, _Acre]
    @eval dimension(::Type{Val{$x}}) = Dict(_Length=>2)
end

for x in [_Second, _Minute, _Hour, _Day, _Week]
    @eval dimension(::Type{Val{$x}}) = Dict(_Time=>1)
end

for x in [_Kelvin, _Celsius, _Rankine, _Fahrenheit]
    @eval dimension(::Type{Val{$x}}) = Dict(_Temperature=>1)
end

for x in [_Degree, _Radian]
    @eval dimension(::Type{Val{$x}}) = Dict(_Angle=>1)
end

dimension(::Type{Val{_Gram}})    = Dict(_Mass=>1)
dimension(::Type{Val{_Ampere}})  = Dict(_Current=>1)
dimension(::Type{Val{_Candela}}) = Dict(_Luminosity=>1)
dimension(::Type{Val{_Mole}})    = Dict(_Mole=>1)
dimension(::Type{Val{_Newton}})  = Dict(_Mass=>1, _Length=>1, _Time=>-2)
dimension(::Type{Val{_Pascal}})  = Dict(_Mass=>1, _Length=>-1, _Time=>-2)
dimension(::Type{Val{_Watt}})    = Dict(_Mass=>1, _Length=>2, _Time=>-3)
dimension(::Type{Val{_Joule}})   = Dict(_Mass=>1, _Length=>2, _Time=>-2)
dimension(::Type{Val{_eV}})      = Dict(_Mass=>1, _Length=>2, _Time=>-2)
dimension(::Type{Val{_Coulomb}}) = Dict(_Current=>1, _Time=>1)
dimension(::Type{Val{_Volt}})    = Dict(_Mass=>1, _Length=>2, _Time=>-3, _Current=>-1)
dimension(::Type{Val{_Ohm}})     = Dict(_Mass=>1, _Length=>2, _Time=>-3, _Current=>-2)
dimension(::Type{Val{_Siemens}}) = Dict(_Mass=>-1, _Length=>-2, _Time=>3, _Current=>2)
dimension(::Type{Val{_Farad}})   = Dict(_Mass=>-1, _Length=>-2, _Time=>4, _Current=>2)
dimension(::Type{Val{_Henry}})   = Dict(_Mass=>1, _Length=>2, _Time=>-2, _Current=>-2)
dimension(::Type{Val{_Tesla}})   = Dict(_Mass=>1, _Time=>-2, _Current=>-1)
dimension(::Type{Val{_Weber}})   = Dict(_Mass=>1, _Length=>2, _Time=>-2, _Current=>-1)

"""
Description of a unit, including powers of that unit and any 10^x exponents.
"""
immutable UnitDatum
    unit::Unit
    tens::Int
    power::Rational{Int}
end

"""
Description of a "dimension" like length, &c. including powers of that dimension.
"""
immutable DimensionDatum
    unit::Dimension
    power::Rational{Int}
end
DimensionDatum(a,b,c) = DimensionDatum(a,c)

@inline unit(x) = one(x)
@inline unit(x::UnitDatum) = x.unit
@inline unit(x::DimensionDatum) = x.unit
@inline tens(x::UnitDatum) = x.tens
@inline tens(x::DimensionDatum) = 0
@inline power(x) = x.power

"A unit or dimension."
abstract  Unitlike

"A container for `UnitDatum` objects to be stored in the type signature."
immutable UnitData{N} <: Unitlike end

"A container for `DimensionDatum` objects to be stored in the type signature."
immutable DimensionData{N} <: Unitlike end

"""
`RealQuantity` has a numeric value and associated units. It should be used
with integers or rationals.
"""
immutable RealQuantity{T<:Real, Units} <: Real
    val::T
end

"""
`FloatQuantity` has a numeric value and associated units. It should be used
with `AbstractFloat` numeric types and is itself a subtype
of `AbstractFloat`. This is needed to tie into certain `Range` subtypes.
"""
immutable FloatQuantity{T<:AbstractFloat, Units} <: AbstractFloat
    val::T
end

"Sometimes we don't care what kind of quantity we are dealing with."
typealias Quantity{T,U} Union{RealQuantity{T,U},
                              FloatQuantity{T,U}}

"Shorthand to simplify some promotion rules."
typealias TypeQuantity{T,U} Union{Type{RealQuantity{T,U}},
                                  Type{FloatQuantity{T,U}}}

"Simple constructors for the appropriate `Quantity` type."
function Quantity end

@inline Quantity(x::AbstractFloat, y::UnitData{()}) = x
@inline Quantity(x::AbstractFloat, y) = FloatQuantity{typeof(x), typeof(y)}(x)
@inline Quantity(x, y::UnitData{()}) = x
@inline Quantity(x, y) = RealQuantity{typeof(x), typeof(y)}(x)

unit{T,Units}(x::Quantity{T,Units}) = Units()
unit{T,Units}(x::Type{Quantity{T,Units}}) = Units()

"""
All units being the same, specifies how to promote
`FloatQuantity` and `RealQuantity`.
"""
function promote_rule{R,S,T}(x::Type{FloatQuantity{R,S}}, y::Type{RealQuantity{T,S}})
    promote_type(R,T) <: AbstractFloat ?
        FloatQuantity{promote_type(R,T), S} :
        RealQuantity{promote_type(R,T), S}
end

"""
`basefactor(x)` specifies a conversion factor to base SI units.

Where possible use an exact factor, e.g.
```
basefactor(x::Type{Val{_Inch}}) = 254//10000 # the inch is exactly 0.0254 m
```
"""
function basefactor end

basefactor(x::Type{Val{_Meter}})      = 1
basefactor(x::Type{Val{_Mile}})       = 1609344//1000       # English mile
basefactor(x::Type{Val{_Yard}})       = 9144//10000
basefactor(x::Type{Val{_Foot}})       = 3048//10000
basefactor(x::Type{Val{_Inch}})       = 254//10000

basefactor(x::Type{Val{_Are}})        = 100                 # hectare = 100 ares
basefactor(x::Type{Val{_Acre}})       = 40468564224//(10^7) # international acre

basefactor(x::Type{Val{_Second}})     = 1
basefactor(x::Type{Val{_Minute}})     = 60
basefactor(x::Type{Val{_Hour}})       = 3600
basefactor(x::Type{Val{_Day}})        = 86400
basefactor(x::Type{Val{_Week}})       = 604800

basefactor(x::Type{Val{_Gram}})       = 1//1000    # because of the kg

basefactor(x::Type{Val{_Ampere}})     = 1

basefactor(x::Type{Val{_Kelvin}})     = 1
basefactor(x::Type{Val{_Celsius}})    = 1
basefactor(x::Type{Val{_Rankine}})    = 5//9       # Some special casing needed
basefactor(x::Type{Val{_Fahrenheit}}) = 5//9       # Some special casing needed

basefactor(x::Type{Val{_Candela}})    = 1

basefactor(x::Type{Val{_Mole}})       = 1

basefactor(x::Type{Val{_Degree}})     = pi/180
basefactor(x::Type{Val{_Radian}})     = 1

basefactor(x::Type{Val{_Newton}})     = 1
basefactor(x::Type{Val{_Pascal}})     = 1
basefactor(x::Type{Val{_Watt}})       = 1
basefactor(x::Type{Val{_Joule}})      = 1
basefactor(x::Type{Val{_eV}})         = 1.6021766208e-19  # CODATA 2014
basefactor(x::Type{Val{_Coulomb}})    = 1
basefactor(x::Type{Val{_Volt}})       = 1
basefactor(x::Type{Val{_Ohm}})        = 1
basefactor(x::Type{Val{_Siemens}})    = 1
basefactor(x::Type{Val{_Farad}})      = 1
basefactor(x::Type{Val{_Henry}})      = 1
basefactor(x::Type{Val{_Tesla}})      = 1
basefactor(x::Type{Val{_Weber})       = 1

"""
`basefactor(x::UnitDatum)`

Specifies how the base factor is computed when 10^x factors and powers of the
unit are taken into account.

TO DO: Could be improved to enable exact conversions;
right now there is an explicit floating point conversion because of the 10^x.
"""
function basefactor(x::UnitDatum)
    (basefactor(Val{unit(x)}) * 10^float(tens(x)))^power(x)
end

"Map the x in 10^x to an SI prefix."
const prefixdict = Dict(
    -24 => "y",
    -21 => "z",
    -18 => "a",
    -15 => "f",
    -12 => "p",
    -9  => "n",
    -6  => "μ",     # tab-complete \mu, not option-m on a Mac!
    -3  => "m",
    -2  => "c",
    -1  => "d",
    0   => "",
    1   => "da",
    2   => "h",
    3   => "k",
    6   => "M",
    9   => "G",
    12  => "T",
    15  => "P",
    18  => "E",
    21  => "Z",
    24  => "Y"
)

"""
Unnecessary generated function to make the code easy to maintain.
"""
@generated function prefix(x::Val)
    if haskey(prefixdict, x.parameters[1])
        str = prefixdict[x.parameters[1]]
        :($str)
    else
        :(error("Invalid prefix"))
    end
end


# Addition / subtraction
for op in [:+, :-]

    @eval ($op){S,T,Units}(x::Quantity{S,Units}, y::Quantity{T,Units}) =
        Quantity(($op)(x.val,y.val), Units())

    # If not generated, there are run-time allocations
    @eval @generated function ($op){S,T,SUnits,TUnits}(x::Quantity{S,SUnits},
            y::Quantity{T,TUnits})
        result_units = SUnits() + TUnits()
        :($($op)(convert($result_units, x), convert($result_units, y)))
    end

    @eval ($op)(x::Quantity) = Quantity(($op)(x.val),unit(x))
end

# Addition / subtraction for arrays
for f in (Base.DotAddFun,
          Base.DotSubFun,
          Base.AddFun,
          Base.SubFun)

    # If not generated, there are run-time allocations
    @eval @generated function promote_op{S,SUnits,T,TUnits}(::$f,
        ::Type{Quantity{S,SUnits}}, ::Type{Quantity{T,TUnits}})

        numtype = promote_op(($f)(),S,T)
        quant = numtype <: AbstractFloat ? FloatQuantity : RealQuantity
        resunits = typeof(+(SUnits(), TUnits()))
        :(($quant){$numtype, $resunits})

    end
end

# Multiplication

"Construct a unitful quantity by multiplication."
*(x::Real, y::UnitData, z::UnitData...) = Quantity(x,*(y,z...))

"Kind of weird but okay, sure"
*(x::UnitData, y::Real) = *(y,x)

"""
Given however many unit-like objects, multiply them together. The following
applies equally well to `DimensionData` instead of `UnitData`.

Collect `UnitDatum` from the types of the `UnitData` objects. For identical
units including SI prefixes (i.e. cm ≠ m), collect powers and sort uniquely.
The unique sorting permits easy unit comparisons.

It is likely that some compile-time optimization would be good...
"""
@generated function *(a0::Unitlike, a::Unitlike...)

    # Sort the units uniquely. This is a generated function so we
    # have access to the types of the arguments, not the values!

    D = (issubtype(a0,UnitData) ? UnitDatum : DimensionDatum)
    b = Array{D,1}()
    a0p = a0.parameters[1]
    length(a0p) > 0 && push!(b, a0p...)
    for x in a
        xp = x.parameters[1]
        length(xp) > 0 && push!(b, xp...)
    end

    sort!(b, by=x->power(x))
    D == UnitDatum && sort!(b, by=x->tens(x))
    sort!(b, by=x->Int(unit(x)))

    # UnitData(m,m,cm,cm^2,cm^3,nm,m^4,µs,µs^2,s)
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
                push!(c, D(unit(oldstate),tens(oldstate),p))
            end
            p = power(state)
        end
        oldstate = state
    end
    if p != 0
        push!(c, D(unit(oldstate),tens(oldstate),p))
    end
    # results in:
    # nm cm^6 m^6 µs^3 s

    d = (c...)
    T = (issubtype(a0,UnitData) ? UnitData : DimensionData)
    :(($T){$d}())
end

@generated function *{T,Units}(x::Quantity{T,Units}, y::UnitData, z::UnitData...)
    result_units = *(Units(),y(),map(x->x(),z)...)
    if isa(result_units,UnitData{()})
        :(x.val)
    else
        :(Quantity(x.val,$result_units))
    end
end


@generated function *(x::Quantity, y::Quantity)
    xunits = x.parameters[2]()
    yunits = y.parameters[2]()
    result_units = xunits*yunits
    quote
        z = x.val*y.val
        Quantity(z,$result_units)
    end
end

# Next line resolves some method ambiguity:
*{T<:Quantity}(x::Bool, y::T) =
    ifelse(x, y, ifelse(signbit(y), -zero(y), zero(y)))
*(y::Real, x::Quantity) = *(x,y)
*(x::Quantity, y::Real) = Quantity(x.val*y, unit(x))

for (f,F) in ((Base.DotMulFun, :*),
              (Base.DotRDivFun, :/),
              (Base.MulFun, :*),
              (Base.RDivFun, :/))

    # Tried doing this without @generated and the @inferred macro
    # failed. The runtime test (numtype <: AbstractFloat)
    # was likely the source of the problem.
    @eval @generated function promote_op{S,SUnits,T,TUnits}(::$f,
        x::TypeQuantity{S,SUnits}, y::TypeQuantity{T,TUnits})

        X = x.parameters[1].parameters[1]
        Y = y.parameters[1].parameters[1]
        XUnits = x.parameters[1].parameters[2]
        YUnits = y.parameters[1].parameters[2]

        numtype = promote_op(($f)(),S,T)
        quant = numtype <: AbstractFloat ? FloatQuantity : RealQuantity
        unittype = typeof(($F)(XUnits(), YUnits()))
        :(($quant){$numtype, $unittype})
    end
end

# Division (floating point)

/(x::UnitData, y::UnitData)       = *(x,inv(y))
/(x::Real, y::UnitData)           = Quantity(x,inv(y))
/(x::UnitData, y::Real)           = (1/y) * x
/(x::Quantity, y::UnitData)       = Quantity(x.val, unit(x) / y)
/(x::Quantity, y::Quantity)       = Quantity(x.val / y.val, unit(x) / unit(y))
/(x::Quantity, y::Real)           = Quantity(x.val / y, unit(x))
/(x::Real, y::Quantity)           = Quantity(x / y.val, inv(unit(y)))

# Division (rationals)

Rational(x::Quantity) = Quantity(Rational(x.val), unit(x))

//(x::UnitData, y::UnitData) = x/y
//(x::Real, y::UnitData)   = Rational(x)/y
//(x::UnitData, y::Real)   = (1//y) * x

//(x::UnitData, y::Quantity) = Quantity(1//y.val, x / unit(y))
//(x::Quantity, y::UnitData) = Quantity(x.val, unit(x) / y)
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

# Exponentiation...
#    is not type stable.
# For now we define a special `inv` method to at least
# enable division to be fast.

"Fast inverse units."
@generated function inv(x::UnitData)
    tup = x.parameters[1]
    tup2 = map(x->x^-1,tup)
    y = *(UnitData{tup2}())
    :($y)
end

^(x::UnitDatum, y::Integer) = UnitDatum(unit(x),tens(x),power(x)*y)
^(x::UnitDatum, y) = UnitDatum(unit(x),tens(x),power(x)*y)

^(x::DimensionDatum, y::Integer) = DimensionDatum(unit(x),power(x)*y)
^(x::DimensionDatum, y) = DimensionDatum(unit(x),power(x)*y)

function ^(x::Unitlike, y::Integer)
    T = (isa(x, UnitData) ? UnitData : DimensionData)
    *(T{map(a->a^y, typeof(x).parameters[1])}())
end

function ^(x::Unitlike, y)
    T = (isa(x, UnitData) ? UnitData : DimensionData)
    *(T{map(a->a^y, typeof(x).parameters[1])}())
end

^{T,Units}(x::Quantity{T,Units}, y::Integer) = Quantity((x.val)^y, Units()^y)
^{T,Units}(x::Quantity{T,Units}, y::Rational) = Quantity((x.val)^y, Units()^y)
^{T,Units}(x::FloatQuantity{T,Units}, y::Rational) = Quantity((x.val)^y, Units()^y)
^{T,Units}(x::Quantity{T,Units}, y::Real) = Quantity((x.val)^y, Units()^y)

# Other mathematical functions
"Fast square root for units."
@generated function sqrt(x::UnitData)
    tup = x.parameters[1]
    tup2 = map(x->x^(1//2),tup)
    y = *(UnitData{tup2}())
    :($y)
end
sqrt(x::Quantity) = Quantity(sqrt(x.val), sqrt(unit(x)))
 abs(x::Quantity) = Quantity(abs(x.val),  unit(x))

for y in [:sin, :cos, :tan, :cot, :sec, :csc]
    @eval ($y){T}(x::Quantity{T,UnitData{(UnitDatum(_Degree,0,1),)}}) = ($y)(x.val*pi/180)
    @eval ($y){T}(x::Quantity{T,UnitData{(UnitDatum(_Radian,0,1),)}}) = ($y)(x.val)
end

@generated function min(x::Quantity, y::Quantity)
    xdim = dimension(x.parameters[2]())
    ydim = dimension(y.parameters[2]())
    if xdim != ydim
        return :(error("Dimensional mismatch."))
    end

    xunits = x.parameters[2].parameters[1]
    yunits = y.parameters[2].parameters[1]

    factx = mapreduce(*,xunits) do a
        basefactor(a)
    end

    facty = mapreduce(*,yunits) do b
        basefactor(b)
    end

    :((x.val*$factx < y.val*$facty) ? x : y)
end

@generated function max(x::Quantity, y::Quantity)
    xdim = dimension(x.parameters[2]())
    ydim = dimension(y.parameters[2]())
    if xdim != ydim
        return :(error("Dimensional mismatch."))
    end

    xunits = x.parameters[2].parameters[1]
    yunits = y.parameters[2].parameters[1]

    factx = mapreduce(*,xunits) do a
        basefactor(a)
    end

    facty = mapreduce(*,yunits) do b
        basefactor(b)
    end

    :((x.val*$factx > y.val*$facty) ? x : y)
end

min(x::UnitData, y::UnitData) = unit(min(Quantity(1.0, x), Quantity(1.0, y)))
max(x::UnitData, y::UnitData) = unit(max(Quantity(1.0, x), Quantity(1.0, y)))

trunc(x::Quantity) = Quantity(trunc(x.val), unit(x))
round(x::Quantity) = Quantity(round(x.val), unit(x))

isless{A,B}(x::Quantity{A,B}, y::Quantity{A,B}) = isless(x.val, y.val)
isless(x::Quantity, y::Quantity) = isless(convert(unit(y), x).val,y.val)
<{A,B}(x::Quantity{A,B}, y::Quantity{A,B}) = (x.val < y.val)
<(x::Quantity, y::Quantity) = <(convert(unit(y), x).val,y.val)

isapprox{A,B,C}(x::Quantity{A,C}, y::Quantity{B,C}) = isapprox(x.val, y.val)
isapprox(x::Quantity, y::Quantity) = isapprox(convert(unit(y), x).val, y.val)

=={A<:Real,B<:Real,C}(x::Quantity{A,C}, y::Quantity{B,C}) = (x.val == y.val)
function ==(x::Quantity, y::Quantity)
    dimension(x) != dimension(y) && return false
    convert(unit(y), x).val == y.val
end
==(x::Quantity, y::Complex) = false
=={T,U}(x::FloatQuantity{T,U}, y::Rational) = false
==(x::Quantity, y::Irrational) = false
==(x::Quantity, y::Number) = false
==(y::Complex, x::Quantity) = false
==(y::Irrational, x::Quantity) = false
=={T,U}(x::Rational, y::FloatQuantity{T,U}) = false
==(y::Number, x::Quantity) = false

<=(x::Quantity, y::Quantity) = <(x,y) || x==y

for f in [:one, :zero, :floor, :ceil]
    @eval ($f)(x::Quantity) = Quantity(($f)(x.val), unit(x))
end

isinteger(x::Quantity) = isinteger(x.val)
isreal(x::Quantity) = true # isreal(x.val)
isfinite(x::Quantity) = isfinite(x.val)
isinf(x::Quantity) = isinf(x.val)

"Needed for array operations to work right."
promote_op{R<:Real,S<:Quantity}(::Base.DotMulFun, ::Type{R}, ::Type{S}) = S
#promote_op{R<:Real,S<:Quantity}(::Base.DotMulFun, ::Type{R}, ::Type{S}) = S

"Forward numeric promotion wherever appropriate."
promote_rule{S,T,U}(::Type{Quantity{S,U}},::Type{Quantity{T,U}}) =
    Quantity{promote_type(S,T),U}

sign(x::Quantity) = sign(x.val)
signbit(x::Quantity) = signbit(x.val)

maxintfloat{T,U}(x::FloatQuantity{T,U}) = FloatQuantity(maxintfloat(T),U())

"`prevfloat(x)` preserves units."
prevfloat(x::Quantity) = Quantity(prevfloat(x.val), unit(x))

"`nextfloat(x)` preserves units."
nextfloat(x::Quantity) = Quantity(nextfloat(x.val), unit(x))

"""
`frexp(x::FloatQuantity)`

Same as for a unitless `AbstractFloat`, but the first number in the
result carries the units of the input.
"""
frexp(x::FloatQuantity) = map(*, frexp(x.val), (unit(x), one(x.val)))

function linspace{S,T,U}(start::RealQuantity{S,U}, stop::Quantity{T,U},
        len::Real=50)
    nums = promote(AbstractFloat(unitless(start)), AbstractFloat(unitless(stop)))
    quants = map(x->Quantity(x,U()), nums)

    linspace(quants..., len)
end

function linspace{S,T,U}(start::FloatQuantity{S,U}, stop::RealQuantity{T,U},
        len::Real=50)
    nums = promote(AbstractFloat(unitless(start)), AbstractFloat(unitless(stop)))
    quants = map(x->Quantity(x,U()), nums)

    linspace(quants..., len)
end

@generated function linspace(start::Real, stop::Real, len::Real=50)
    if start <: Quantity || stop <: Quantity
        :(error("Dimensional mismatch"))
    else
        :(linspace(promote(AbstractFloat(start), AbstractFloat(stop))..., len))
    end
end

include("Redefinitions.jl")

"""
Merge the keys of two dictionaries, adding the values if the keys were shared.
The first argument is modified.
"""
function mergeadd!(a::Dict, b::Dict)
    for (k,v) in b
        !haskey(a,k) ? (a[k] = v) : (a[k] += v)
    end
end

function dimension(x::Number)
    UnitData{()}()
end

function dimension(u::UnitDatum)
    dims = dimension(Val{unit(u)})
    for (k,v) in dims
        dims[k] *= power(u)
    end
    t = [DimensionDatum(k,v) for (k,v) in dims]
    *(DimensionData{(t...)}())
end

dimension{N}(u::UnitData{N}) = mapreduce(dimension, *, N)
dimension{S,SUnits}(x::Quantity{S,SUnits}) = dimension(SUnits())

"Format a unitful quantity."
function show{T,Units}(io::IO,x::Quantity{T,Units})
    show(io,x.val)
    print(io," ")
    show(io,Units())
    nothing
end

"Call `show` on each `UnitDatum` in the tuple held by `UnitData`."
function show(io::IO,x::Unitlike)
    first = ""
    tup = typeof(x).parameters[1]
    map(tup) do y
        print(io,first)
        show(io,y)
        first = " "
    end
    nothing
end

"Prefix the unit with any decimal prefix and append the exponent."
function show(io::IO, x::UnitDatum)
    print(io, prefix(Val{tens(x)}()))
    print(io, abbr(Val{unit(x)}))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x))))
    nothing
end

"Prints exponents nicely with Unicode."
superscript(i::Rational) = begin
    i.den == 1 ? "^"*string(i.num) : "^"*replace(string(i),"//","/")
end

"""
Given a unit abbreviation and a `Unit` object, will define and export
`UnitDatum` for each possible SI prefix on that unit.

e.g. nm, cm, m, km, ... all get defined when `@uall m _Meter` is typed.
"""
macro uall(x,y)
    expr = Expr(:block)

    for (k,v) in prefixdict
        s = symbol(v,x)
        ea = quote
            const $(esc(s)) = UnitData{(UnitDatum($y,$k,1),)}()
            export $(esc(s))
        end
        push!(expr.args, ea)
    end

    expr
end

"""
Given a unit abbreviation and a `Unit` object, will define and export
`UnitDatum`, without prefixes.

e.g. ft gets defined but not kft when `@u ft _Foot` is typed.
"""
macro u(x,y)
    s = symbol(x)
    quote
        const $(esc(s)) = UnitData{(UnitDatum($y,0,1),)}()
        export $(esc(s))
    end
end

# WIP
# macro simplify_prefixes()
#     quote
#         @generated function simplify(x::Quantity)
#             tup = u.parameters[1]
#
#         end
#     end
# end

"Strip units and convert to float."
float(x::Quantity) = float(x.val)

"Strip units and convert to an integer."
Integer(x::Quantity) = Integer(x.val)

"""
Convert a unitful quantity to different units.
"""
function convert{T,Units}(::Type{Quantity{T,Units}}, x::Quantity)
    xunits = typeof(x).parameters[2]
    conv = convert(Units(), xunits())
    Quantity(T(x.val * conv), Units())
end

function tscale(x::UnitData)
    tup = typeof(x).parameters[1]
    if length(tup) > 1
        return false
    end
    u = unit(tup[1])
    if u == _Celsius || u == _Kelvin || u == _Rankine || u == _Fahrenheit
        return true
    else
        return false
    end
end

offsettemp{T}(::Type{Val{T}}) = 0
offsettemp(::Type{Val{_Fahrenheit}}) = 459.67
offsettemp(::Type{Val{_Celsius}}) = 273.15

"""
Convert a unitful quantity to different units.

Is a generated function to allow for special casing, e.g. temperature conversion
"""
@generated function convert(a::UnitData, x::Quantity)
    xunits = x.parameters[2]
    aData = a()
    xData = xunits()
    conv = convert(aData, xData)

    if tscale(aData)
        tup0 = xunits.parameters[1]
        tup1 = a.parameters[1]
        t0 = offsettemp(Val{unit(tup0[1])})
        t1 = offsettemp(Val{unit(tup1[1])})
        :(Quantity(((x.val + $t0) * $conv) - $t1, a))
    else
        :(Quantity(x.val * $conv, a))
    end
end

"""
Find the conversion factor from unit `t` to unit `s`, e.g.
`convert(m,cm) = 0.01`.
"""
@generated function convert(s::UnitData, t::UnitData)
    sunits = s.parameters[1]
    tunits = t.parameters[1]

    # Check if conversion is possible in principle
    sdim = dimension(UnitData{sunits}())
    tdim = dimension(UnitData{tunits}())
    sdim != tdim && error("Dimensional mismatch.")

    conv = 1.0

    # first convert to base SI units.
    # fact1 is what would need to be multiplied to get to base SI units
    # fact2 is what would be multiplied to get from the result to base SI units

    fact1 = mapreduce(*,tunits) do x    # x is a UnitDatum
        basefactor(x)
    end
    fact2 = mapreduce(*,sunits) do x
        basefactor(x)
    end

    y = fact1 / fact2
    :($y)
end

"No conversion factor needed if you already have the right units."
convert{S}(s::UnitData{S}, t::UnitData{S}) = 1

"Put units on a number."
convert{T,U,S}(::Type{FloatQuantity{T,U}}, x::Rational{S}) =
    Quantity(T(x),U())

"Put units on a number."
convert{T,U}(::TypeQuantity{T,U}, x::Real) = Quantity(convert(T,x), U())

"Needed to avoid complaints about ambiguous methods"
convert(::Type{Bool}, x::Quantity)    = Bool(x.val)
"Needed to avoid complaints about ambiguous methods"
convert(::Type{Integer}, x::Quantity) = Integer(x.val)
"Needed to avoid complaints about ambiguous methods"
convert(::Type{Complex}, x::Quantity) = Complex(x.val,0)

convert{T,U}(::Type{Rational{BigInt}}, x::FloatQuantity{T,U}) =
    Rational{BigInt}(x.val)

convert{S<:Integer,T,U}(::Type{Rational{S}}, x::FloatQuantity{T,U}) =
    Rational{S}(x.val)

convert{R,S,T,U}(::Type{FloatQuantity{R,S}}, x::Quantity{T,U}) =
    Quantity(R(x.val),convert(S,U()))
convert{R,S,T,U}(::Type{RealQuantity{R,S}}, x::Quantity{T,U}) =
    Quantity(R(x.val),convert(S,U()))

"Strip units from a number."
convert{S<:Number}(::Type{S}, x::Quantity) = convert(S, x.val)

include("Defaults.jl")

end
