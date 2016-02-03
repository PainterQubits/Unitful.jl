"""
Requirements for a unit system.

Points to consider:
- ft^2 is an area, so is acre^1; dimensions cannot be determined by exponents
- how to handle units with built-in exponents (e.g. nm or km)
- how to handle adding different units with same dimension (m [L] + ft [L])
- how to handle different unit systems, including natural units

When adding unitful quantities, they may only be added if they have the same
dimensions; you cannot add a length and a time in SI units. In natural units
time has dimensions of length and vice versa so we just call both "length"

Operations on unitful quantities should look at dimension: [L] [T]^-1, etc.
which is represented by a tuple (1,0,-1,...) to decide if the operation is allowed.

- TODO: Clean up min/max with closures in Julia 0.5
- TODO: How to handle cases where there is an exact conversion between two
non-SI units? Right now if we convert 12 inches to feet there is an epsilon
error from some floating-point math.

"""
module Unitful

import Base: ==, <, <=, +, -, *, /, .+, .-, .*, ./, //, ^
import Base: show, convert
import Base: abs, float, inv, sqrt
import Base: sin, cos, tan, cot, sec, csc
import Base: min, max, floor, ceil

import Base: mod, rem, div
import Base: isless, isapprox, isinteger, isreal, isfinite
import Base: promote_op, promote_rule
import Base: length, float, range, start, done, next, colon, one, zero
import Base: getindex, eltype, step, last, first

export baseunit
export dimension
export power
export tens
export unit

export promote_op

# Dimensions
@enum Dimension _Mass _Length _Time _Current _Temperature _Amount _Luminosity _Angle

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
_Gram,
_Foot, _Inch, _Meter,
_Second, _Minute, _Hour,
_Ampere,
_Coulomb,
_Volt,
_Degree, _Radian)

abbr(::Type{Val{_Meter}})   = "m"
abbr(::Type{Val{_Foot}})    = "ft"
abbr(::Type{Val{_Inch}})    = "in"

abbr(::Type{Val{_Second}})  = "s"
abbr(::Type{Val{_Minute}})  = "min"
abbr(::Type{Val{_Hour}})    = "h"

abbr(::Type{Val{_Gram}})    = "g"
abbr(::Type{Val{_Ampere}})  = "A"
abbr(::Type{Val{_Coulomb}}) = "C"
abbr(::Type{Val{_Volt}})    = "V"

abbr(::Type{Val{_Degree}})  = "°"
abbr(::Type{Val{_Radian}})  = "rad"

for x in [_Meter, _Foot, _Inch]
    @eval dimension(::Type{Val{$x}}) = Dict(_Length=>1)
end

for x in [_Second, _Minute, _Hour]
    @eval dimension(::Type{Val{$x}}) = Dict(_Time=>1)
end

dimension(::Type{Val{_Gram}})    = Dict(_Mass=>1)
dimension(::Type{Val{_Ampere}})  = Dict(_Current=>1)
dimension(::Type{Val{_Coulomb}}) = Dict(_Current=>1, _Time=>1)
dimension(::Type{Val{_Volt}})    = Dict(_Mass=>1, _Length=>2, _Time=>-3, _Current=>-1)

for x in [_Degree, _Radian]
    @eval dimension(::Type{Val{$x}}) = Dict(_Angle=>1)
end

basefactor(x::Type{Val{_Meter}}) = 1
basefactor(x::Type{Val{_Foot}}) = 0.3048
basefactor(x::Type{Val{_Inch}}) = 0.0254

basefactor(x::Type{Val{_Second}}) = 1
basefactor(x::Type{Val{_Minute}}) = 60
basefactor(x::Type{Val{_Hour}}) = 3600

basefactor(x::Type{Val{_Gram}}) = 0.001    # because of the kg
basefactor(x::Type{Val{_Ampere}}) = 1
basefactor(x::Type{Val{_Coulomb}}) = 1
basefactor(x::Type{Val{_Volt}}) = 1

basefactor(x::Type{Val{_Degree}}) = pi/180.
basefactor(x::Type{Val{_Radian}}) = 1

const prefixdict = Dict(
    -24 => "y",
    -21 => "z",
    -18 => "a",
    -15 => "f",
    -12 => "p",
    -9  => "n",
    -6  => "µ",
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

@generated function prefix{N}(x::Type{Val{N}})
    if haskey(prefixdict, N)
        str = prefixdict[N]
        :($str)
    else
        :(error("Invalid prefix"))
    end
end

"""
Describes a numerical quantity and a unit (`UnitTuple`).

The type of the UnitTuple describes the system of measurement,
and the parameters of the type
"""
immutable UnitDatum
    unit::Unit
    tens::Int
    power::Rational{Int}
end

immutable DimensionDatum
    unit::Dimension
    power::Rational{Int}
end
DimensionDatum(a,b,c) = DimensionDatum(a,c)

unit(x) = x.unit
tens(x::UnitDatum) = x.tens
tens(x::DimensionDatum) = 0
power(x) = x.power

abstract  Unitlike
immutable UnitData{N} <: Unitlike end
immutable DimensionData{N} <: Unitlike end

typealias NNN Real
immutable Quantity{T<:NNN, Units} <: NNN
    val::T
end
Quantity(x,y) = Quantity{typeof(x),typeof(y)}(x)
unit{T,Units}(x::Quantity{T,Units}) = Units()

# Addition / subtraction
for op in [:+, :-]
    @eval ($op){S,T,Units}(x::Quantity{S,Units}, y::Quantity{T,Units}) =
        Quantity(($op)(x.val,y.val), Units())
    @eval function ($op){S,T,SUnits,TUnits}(x::Quantity{S,SUnits}, y::Quantity{T,TUnits})
        result_units = SUnits() + TUnits()
        ($op)(convert(result_units, x), convert(result_units, y))
    end
    @eval ($op)(x::Quantity) = Quantity(($op)(x.val),unit(x))
end

# Multiplication

"Make a unitful quantity."
*(x::NNN, y::UnitData, z::UnitData...) = Quantity(x,*(y,z...))
*(x::UnitData, y::NNN) = *(y,x)          # ... although this is kind of weird

"""
Given however many unit-like objects, multiply them together.

Collect `Datum` from the types of the `Data` objects. For identical
units including SI prefixes (i.e. cm ≠ m), collect powers and sort uniquely.
The unique sorting has some advantages:

- could reduce compile-time overhead, compared to without sorting
- unique ordering of units permits easy unit comparisons

You can think of this as mapping a product of units to a unique result of units.
All computation is done at compile time and so at run time this is very fast.
"""
@generated function *(a0::Unitlike, a::Unitlike...)

    # Sort the units uniquely. This is a generated function so we
    # have access to the types of the arguments, not the values!

    D = (issubtype(a0,UnitData) ? UnitDatum : DimensionDatum)
    b = Array{D,1}()
    push!(b, a0.parameters[1]...)
    for x in a
        push!(b, x.parameters[1]...)
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
    if isa(result_units,UnitData{()})
        :(x.val*y.val)
    else
        quote
            z = x.val*y.val
            Quantity(z,$result_units)
        end
    end
end

*(x::Quantity, y::NNN) = Quantity(x.val*y, unit(x))
*(x::Bool, y::Quantity) = ifelse(x, y, ifelse(signbit(y), -zero(y), zero(y)))
*(y::NNN, x::Quantity) = *(x,y)

# Division (floating point)

/(x::UnitData, y::UnitData) = *(x,inv(y))
/(x::NNN, y::UnitData)   = Quantity(x,inv(y))
/(x::UnitData, y::NNN)   = (1/y) * x
/(x::Quantity, y::UnitData) = Quantity(x.val, unit(x) / y)
/(x::Quantity, y::Quantity) = Quantity(x.val / y.val, unit(x) / unit(y))
/(x::Quantity, y::NNN)   = Quantity(x.val / y, unit(x))
/(x::NNN, y::Quantity)   = Quantity(x / y.val, inv(unit(y)))

# Division (rationals)

//(x::UnitData, y::UnitData) = x/y
//(x::NNN, y::UnitData)   = x/y
//(x::UnitData, y::NNN)   = (1//y) * x

//(x::Quantity, y::Quantity) = Quantity(x.val // y.val, unit(x) / unit(y))

# function //(x::Quantity, y::Complex)
#     xr = complex(Rational(real(x).val),Rational(imag(x).val))
#     yr = complex(Rational(real(y).val),Rational(imag(y).val))
#     Quantity(xr//yr, unit(x))
# end

//(x::Quantity, y::NNN) = Quantity(x.val // y, unit(x))
//(x::NNN, y::Quantity) = Quantity(x // y.val, inv(unit(y)))

# Division (other functions)

function mod(x::Quantity, y::Quantity)
    z = convert(unit(y), x)
    Quantity(mod(z.val,y.val), unit(y))
end

function rem(x::Quantity, y::Quantity)
    z = convert(unit(y), x)
    Quantity(rem(z.val,y.val), unit(y))
end

div(x::Quantity, y::Quantity) = Quantity(div(x.val, y.val), unit(x) / unit(y))

# Exponentiation...
#    is not type stable.
# For now we define a special `inv` method to at least
# enable division to be fast.

"1/units"
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

"Not type stable but could be made type-stable using closures?"
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
^{T,Units}(x::Quantity{T,Units}, y::Real) = Quantity((x.val)^y, Units()^y)

# Other mathematical functions
sqrt(x::UnitData) = x^(1//2)
sqrt(x::Quantity) = Quantity(sqrt(x.val), sqrt(unit(x)))
 abs(x::Quantity) = Quantity(abs(x.val),  unit(x))

for y in [:sin, :cos, :tan, :cot, :sec, :csc]
    @eval ($y){T}(x::Quantity{T,UnitData{(UnitDatum(_Degree,0,1),)}}) = ($y)(x.val*pi/180.)
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
        basefactor(a)      # special case for temperature?
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
        basefactor(a)      # special case for temperature?
    end

    facty = mapreduce(*,yunits) do b
        basefactor(b)
    end

    :((x.val*$factx > y.val*$facty) ? x : y)
end

min(x::UnitData, y::UnitData) = unit(min(Quantity(1.0, x), Quantity(1.0, y)))
max(x::UnitData, y::UnitData) = unit(max(Quantity(1.0, x), Quantity(1.0, y)))

isless{A,B}(x::Quantity{A,B}, y::Quantity{A,B}) = isless(x.val, y.val)
isless(x::Quantity, y::Quantity) = isless(convert(unit(y), x).val,y.val)
<{A,B}(x::Quantity{A,B}, y::Quantity{A,B}) = (x.val < y.val)
<(x::Quantity, y::Quantity) = <(convert(unit(y), x).val,y.val)

isapprox{A,B,C}(x::Quantity{A,C}, y::Quantity{B,C}) = isapprox(x.val, y.val)
isapprox(x::Quantity, y::Quantity) = isapprox(convert(unit(y), x).val, y.val)
=={A,B,C}(x::Quantity{A,C}, y::Quantity{B,C}) = (x.val == y.val)
==(x::Quantity, y::Quantity) = convert(unit(y), x).val == y.val
<=(x::Quantity, y::Quantity) = <(x,y) || x==y

for f in [:one, :zero, :floor, :ceil]
    @eval ($f)(x::Quantity) = Quantity(($f)(x.val), unit(x))
end

isinteger(x::Quantity) = isinteger(x.val)
isreal(x::Quantity) = true # isreal(x.val)
isfinite(x::Quantity) = isfinite(x.val)

"Needed for array operations to work right."
promote_op{R<:NNN,S<:Quantity}(::Base.DotMulFun, ::Type{R}, ::Type{S}) = S
#promote_op{R<:NNN,S<:Quantity}(::Base.DotMulFun, ::Type{R}, ::Type{S}) = S

"Forward numeric promotion wherever appropriate."
promote_rule{S,T,U}(::Type{Quantity{S,U}},::Type{Quantity{T,U}}) =
    Quantity{promote_type(S,T),U}

# range.jl release-0.4 l346
start{T,U}(r::UnitRange{Quantity{T,U}})  = oftype(r.start+one(r.start),r.start)
# range.jl release-0.4 l347
next{T,U}(r::UnitRange{Quantity{T,U}}, i) = (convert(Quantity{T,U}, i), i+one(i))
# range.jl release-0.4 l348
done{T,U}(r::UnitRange{Quantity{T,U}}, i) = i == oftype(i, r.stop) + one(r.stop)
# range.jl release-0.4 l271
length{T,U}(r::UnitRange{Quantity{T,U}}) = Integer(r.stop) - Integer(r.start) + 1
# range.jl release-0.4 l84
range(a::Quantity, len::Integer) =
    UnitRange{typeof(a)}(a, oftype(a, a + oftype(a, len-1)))

# range.jl release-0.5 l162
colon{A<:AbstractFloat,C}(a::Quantity{A,C},b::Quantity{A,C}) = colon(a, one(a), b)

# .+{T<:Real,S}(x::Quantity{T,S}, r::Range) = (+(x,first(r))):step(r):(+(x,last(r)))
# .+{T<:Real,S}(r::Range, x::Quantity{T,S}) = +(x,r)

# .-{T<:Real,}

# broadcast does not respect promote_op apparently

# colon{A,B,C}(a::Quantity{A,C}, b::Quantity{B,C}) =

function mergeadd!(a::Dict, b::Dict)
    for (k,v) in b
        if !haskey(a,k)
            a[k] = v
        else
            a[k] += v
        end
    end
end

function dimension(u::UnitDatum)
    dims = dimension(Val{unit(u)})
    for (k,v) in dims
        dims[k] *= power(u)
    end
    t = [DimensionDatum(k,v) for (k,v) in dims]
    *(DimensionData{(t...)}())
end

function dimension{N}(u::UnitData{N})
    dims = dimension(N[1])
    for i in 2:length(N)
        dims *= dimension(N[i])
    end
    *(dims)
end

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
function show(io::IO, x::Union{UnitDatum,DimensionDatum})
    print(io, prefix(Val{tens(x)}))
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

# Conversion

# Some of our `convert` syntax breaks Julia conventions in that the first
# argument is not a type. This decision is not taken lightly but the result
# is very convenient.

# "Give an SI unit for a given dimension. Relies on enum ordering..."
# @generated function baseunit(x::DimensionData)
#     tup = x.parameters[1]
#     c = [UnitDatum(Unit(Int(unit(y))), 0, power(y)) for y in tup]
#     d = (c...)
#     :(UnitData{$d}())
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

"""
Convert a unitful quantity to different units.
"""
function convert(a::UnitData, x::Quantity)
    xunits = typeof(x).parameters[2]
    conv = convert(a, xunits())
    Quantity(x.val * conv, a)
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
        basefactor(x)      # special case for temperature?
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
convert{T,U}(::Type{Quantity{T,U}}, x::Real) = Quantity(convert(T,x), U())

# convert(::Type{Bool}, x::Quantity) = convert(Bool, x.val)
# convert(::Type{Integer}, x::Quantity) = Integer(x.val)
#
# "Strip units from a number."
# convert{S<:Number,T,U}(::Type{S}, x::Quantity{T,U}) = convert(S, x.val)

function basefactor(x::UnitDatum)
    (basefactor(Val{unit(x)}) * 10^float(tens(x)))^power(x)
end

include("Defaults.jl")

end
