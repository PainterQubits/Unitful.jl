"""
Requirements for a unit system.

Points to consider:
- ft^2 is an area, so is acre^1; dimensions cannot be determined by exponents
- how to handle units with built-in exponents (e.g. nm or km)
- how to handle adding different units with same dimension (m [L] + ft [L])
- how to handle different unit systems, including natural units (e.g. c=1)

When adding unitful quantities, they may only be added if they have the same
dimensions; you cannot add a length and a time in SI units. In natural units
time has dimensions of length and vice versa so we just call both "length"

Dispatch on unitful quantities should look at dimension: [L] [T]^-1, etc.
which is represented by a tuple (1,0,-1,...) to
decide if the operation is allowed.

Tuple may have different meanings for different unit systems
(SI vs. natural units; natural units have fewer dimensionful quantities)
so dispatch should check the unit system to interpret the tuple?

"""
module Unitful

import Base: ==, +, -, *, /, .+, .-, .*, ./, //, ^
import Base: promote_rule, promote_type, convert, show, mod
import Base: abs, conj, float, imag, real, sqrt
import Base: sin, cos, tan, cot, sec, csc

export Quantity
export UnitData
export UnitDatum

export Dimension
export Length
export Mass
export Time
export Current
export Temperature
export Amount
export Luminosity

export Unit

export dimension
export power
export tens
export unit

abstract Dimension
immutable Length      <: Dimension end
immutable Mass        <: Dimension end
immutable Time        <: Dimension end
immutable Current     <: Dimension end
immutable Temperature <: Dimension end
immutable Amount      <: Dimension end
immutable Luminosity  <: Dimension end

# Base
@enum Unit _Meter _Gram _Second _Ampere _Coulomb

# Derived

# Dimensions
abbr(::Length) = "[L]"
abbr(::Mass) = "[M]"
abbr(::Time) = "[T]"
abbr(::Current) = "[I]"
abbr(::Temperature) = "[Θ]"
abbr(::Amount) = "[N]"
abbr(::Luminosity) = "[J]"

# SI units
abbr(::Type{Val{_Meter}})  = "m"
abbr(::Type{Val{_Second}}) = "s"
abbr(::Type{Val{_Gram}})   = "g"
abbr(::Type{Val{_Ampere}}) = "A"

# Derived units
abbr(::Type{Val{_Coulomb}}) = "C"

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
unit(x::UnitDatum) = x.unit
tens(x::UnitDatum) = x.tens
power(x::UnitDatum) = x.power

immutable DatumTuple{unit, tens, power} end
dispatch(x::UnitDatum) = DatumTuple{unit(x), tens(x), power(x)}()

immutable UnitData{N}
    tup::NTuple{N,UnitDatum}
end

UnitData(a::UnitDatum...) = begin

    # Sort the units uniquely
    b = [a...]
    sort!(b, by=x->power(x))
    sort!(b, by=x->tens(x))
    sort!(b, by=x->hash(unit(x)))

    # UnitData(m,m,cm,cm^2,cm^3,nm,m^4,µs,µs^2,s)
    # ordered as:
    # nm cm cm^2 cm^3 m m m^4 µs µs^2 s

    # Collect powers of a given unit
    c = Array{UnitDatum,1}()
    i = start(b)
    oldstate = b[i]
    p=0//1
    while !done(b, i)
        (state, i) = next(b, i)
        if tens(state) == tens(oldstate) && unit(state) == unit(oldstate)
            p += power(state)
        else
            if p != 0
                push!(c, UnitDatum(unit(oldstate),tens(oldstate),p))
            end
            p = power(state)
        end
        oldstate = state
    end
    if p != 0
        push!(c, UnitDatum(unit(oldstate),tens(oldstate),p))
    end
    # results in:
    # nm cm^6 m^6 µs^3 s

    UnitData{length(c)}((c...))
end

immutable Quantity{T<:Number, Units}
    val::T
end
Quantity(val::Number, x::UnitData) = Quantity{typeof(val),x}(val)
Quantity(val::Number, x::UnitDatum) = Quantity{typeof(val),UnitData(x)}(val)

"Adding two identical units returns the same unit."
+{S<:Unit}(x::S, y::S) = x

"Default: cannot add different units."
+(x::Unit, y::Unit) = error("Need a unit addition rule.")

"Adding `UnitDatum` objects."
function +(x::UnitDatum, y::UnitDatum)

    xdim = dimension(x)
    ydim = dimension(y)

    xdim != ydim && error("Dimensional mismatch.")

    +(dispatch(x), dispatch(y))
end

@generated function +{S,T,SUnits,TUnits}(
    x::Quantity{S,SUnits}, y::Quantity{T,TUnits})

    TUnits

end

+{S,T,Units}(x::Quantity{S,Units}, y::Quantity{T,Units}) =
    Quantity{typeof(val),Units}(x.val+y.val)
-{S,T,Units}(x::Quantity{S,Units}, y::Quantity{T,Units}) =
    Quantity{typeof(val),Units}(x.val-y.val)

function +(x::UnitData, y::UnitData)
    xdim = dimension(x)
    ydim = dimension(y)
    xdim != ydim && error("Dimensional mismatch.")
    +(map(dispatch,x.tup), map(dispatch,y.tup))
end

# Multiplication

*(x::UnitDatum, y::UnitDatum) = UnitData(x,y)
*(x::UnitData, y::UnitDatum)  = UnitData(x.tup..., y)
*(x::UnitDatum, y::UnitData)  = *(y,x)
*(x::UnitData, y::UnitData)   = UnitData(x.tup..., y.tup...)
*(x::Number, y::UnitDatum)    = Quantity(x,y)
*(x::UnitDatum, y::Number)    = *(y,x)
*(x::Number, y::UnitData)     = Quantity(x,y)
*(x::UnitData, y::Number)     = *(y,x)

# Use generated functions for type stability! Fancy
@generated function *{T,Units}(x::Quantity{T,Units}, y::UnitDatum)
    result_units = Units*y
    if isa(result_units,UnitData{0})
        :(x.val)
    else
        :(Quantity{T,$result_units}(x.val))
    end
end

@generated function *{T,Units}(x::Quantity{T,Units}, y::UnitData)
    result_units = Units*y
    if isa(result_units,UnitData{0})
        :(x.val)
    else
        :(Quantity{T,$result_units}(x.val))
    end
end

@generated function *{S,T,SUnits,TUnits}(x::Quantity{S,SUnits},
        y::Quantity{T,TUnits})
    result_units = SUnits*TUnits
    if isa(result_units,UnitData{0})
        :(x.val*y.val)
    else
        quote
            z = x.val*y.val
            Quantity{typeof(z),$result_units}(z)
        end
    end
end

# Division

/(x::UnitDatum, y::UnitDatum) = UnitData(x, y^-1)
/(x::UnitData, y::UnitDatum)  = UnitData(x.tup..., y^-1)
/(x::UnitDatum, y::UnitData)  = /(y,x)
/(x::UnitData, y::UnitData)   = UnitData(x.tup..., map(x->x^-1, y.tup)...)
/(x::Number, y::UnitDatum)    = Quantity(x,y^-1)
/(x::UnitDatum, y::Number)    = (1/y) * x
/(x::Number, y::UnitData)     = Quantity(x,y^-1)
/(x::UnitData, y::Number)     = (1/y) * x
/{T,Units}(x::Quantity{T,Units}, y::UnitDatum) = Quantity(x.val, Units / y)
/{T,Units}(x::Quantity{T,Units}, y::UnitData) = Quantity(x.val, Units / y)
/{S,T,SUnits,TUnits}(x::Quantity{S,SUnits}, y::Quantity{T,TUnits}) =
    Quantity(x.val / y.val, SUnits / TUnits)

# Exponentiation

^(x::UnitDatum, y::Integer) = UnitDatum(unit(x),tens(x),power(x)*y)
^(x::UnitDatum, y) = UnitDatum(unit(x),tens(x),power(x)*y)
^(x::UnitData,  y::Integer) = UnitData(map(x->x^y,x.tup)...)
^(x::UnitData,  y) = UnitData(map(x->x^y,x.tup)...)
^{T,Units}(x::Quantity{T,Units}, y::Integer) = Quantity((x.val)^y, Units^y)
^{T,Units}(x::Quantity{T,Units}, y) = Quantity((x.val)^y, Units^y)

# Other mathematical functions
sqrt(x::UnitDatum) = x^(1//2)
sqrt(x::UnitData) = x^(1//2)
sqrt{T,Units}(x::Quantity{T,Units}) = Quantity(sqrt(x.val), sqrt(Units))
abs{T,Units}(x::Quantity{T,Units}) = Quantity(abs(x.val),Units)
conj{T,Units}(x::Quantity{T,Units}) = Quantity(conj(x.val),Units)
imag{T,Units}(x::Quantity{T,Units}) = Quantity(imag(x.val),Units)
real{T,Units}(x::Quantity{T,Units}) = Quantity(real(x.val),Units)

# Conversion
float(x::Quantity) = float(x.val)

import Base: length, getindex, next, float64, float, int, show, start, step, last, done, first, eltype, one, zero
one(x::Quantity) = one(x.val)
zero(x::Quantity) = zero(x.val) #* unit?

function mergeadd!(a::Dict, b::Dict)
    for (k,v) in b
        if !haskey(a,k)
            a[k] = v
        else
            a[k] += v
        end
    end
end

dimension(::Type{Val{_Meter}})   = Dict{Dimension,Int64}(Length()=>1)
dimension(::Type{Val{_Second}})  = Dict{Dimension,Int64}(Time()=>1)
dimension(::Type{Val{_Gram}})    = Dict{Dimension,Int64}(Mass()=>1)
dimension(::Type{Val{_Ampere}})  = Dict{Dimension,Int64}(Current()=>1)
#dimension(::_Coulomb) = Dict{Dimension,Int64}(Current()=>1, Time()=>1)

function dimension(u::UnitDatum)
    dims = dimension(Val{unit(u)})
    for (k,v) in dims
        dims[k] *= power(u)
    end
    dims
end

function dimension(u::UnitData)
    dims = Dict()
    for i in 1:length(u.tup)
        unitdatum = u.tup[i]
        mergeadd!(dims, dimension(unitdatum))
    end
    dims
end

dimension{S,SUnits}(x::Quantity{S,SUnits}) = dimension(SUnits)

"Format a unitful quantity."
function show{T,Units}(io::IO,x::Quantity{T,Units})
    show(io,x.val)
    print(io," ")
    show(io,Units)
    nothing
end

"Call `show` on each `UnitDatum` in the tuple held by `UnitData`."
function show(io::IO,x::UnitData)
    map(x.tup) do y
        show(io,y)
    end
    nothing
end

"Prefix the unit with any decimal prefix and append the exponent."
function show(io::IO,x::UnitDatum)
    print(io, prefix(Val{tens(x)}), abbr(Val{unit(x)}),
        (power(x) == 1//1 ? "" : superscript(power(x))))
    nothing
end

"Show the dimensions."
function show{N}(io::IO,x::Dict{Dimension,N})
    for (k,v) in x
        print(io, abbr(k)*"^"*(isa(v,Int64) ? string(v) : "("*string(v)*")"))
    end
    nothing
end

"Prints exponents nicely with Unicode."
superscript(i::Rational) = begin
    i.den == 1 ? "^"*string(i.num) : "^"*replace(string(i),"//","/")
end

# spare code
# @generated function eq()
#     x = Set((N,M)) == Set((J,K))
#     :($x)
# end

include("Rules.jl")
include("Defaults.jl")

end
