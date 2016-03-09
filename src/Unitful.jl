"Copyright Andrew J. Keller, 2016"

module Unitful

import Base: ==, <, <=, +, -, *, /, .+, .-, .*, ./, .\, //, ^, .^
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
import Base: Rational, Complex, typemin, typemax

export baseunit
export dimension
export power
export tens
export unit, unitless
export @unit

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
abstract Unit
bitstype 32 NormalUnit      <: Unit
bitstype 32 TemperatureUnit <: Unit

global unitcount = 0
convert{T<:Integer}(::Type{T}, x::Unit) = convert(T, Intrinsics.box(Int32, x))
convert{T<:Unit}(::Type{T}, x36::Integer) = Intrinsics.box(T, convert(Int32, x36))
isless(x39::Unit, y40::Unit) = isless(Int32(x39), Int32(y40))

function nextunit{T<:Unit}(::Type{T})
    global unitcount
    x = T(unitcount + 1)
    unitcount += 1
    x
end

macro baseunit(name,abbr,dimension)
    quote
        T = ($dimension == _Temperature ? TemperatureUnit : NormalUnit)
        unit = nextunit(T)
        Unitful.abbr(::Type{Val{unit}})       = $abbr
        Unitful.dimension(::Type{Val{unit}})  = Dict($dimension=>1)
        Unitful.basefactor(::Type{Val{unit}}) = (1.0, 1)
        @uall $(esc(name)) unit
    end
end

function dimhelper(x)
    d = Dict{Dimension,Rational{Int}}()
    tup = typeof(dimension(x)).parameters[1]
    for y in tup
        d[unit(y)]=power(y)
    end
    d
end

macro unit(name,abbr,equals,tf)
    # name is a symbol
    # abbr is a string
    quote
        inex, ex = basefactor(Unitful.unit($equals))
        eq = unitless($equals)
        Base.isa(eq, Base.Complex) && error("Cannot define complex units.")
        Base.isa(eq, Base.Integer) || Base.isa(eq, Base.Rational) ?
             (ex *= eq) : (inex *= eq)
        T = (dimhelper($equals) == Dict(_Temperature=>1) ?
            TemperatureUnit : NormalUnit)
        unit = nextunit(T)
        Unitful.abbr(::Type{Val{unit}}) = $abbr
        Unitful.dimension(::Type{Val{unit}}) = dimhelper($equals)
        Unitful.basefactor(::Type{Val{unit}}) = (inex, ex)
        if $tf
            @uall $(esc(name)) unit
        else
            @u $(esc(name)) unit
        end
    end
end

"""
`dimension(x)` specifies a `Dict` containing how many powers of each
dimension correspond to a given unit. It should be implemented for all units.
"""
function dimension end

"""
Description of a unit, including powers of that unit and any 10^x exponents.
"""
immutable UnitDatum{T<:Unit}
    unit::T
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

@generated function unit(x::UnitData)
    tup = x.parameters[1]
    length(tup) > 1 && error("Call on a UnitDatum object.")
    y = tup[1]
    :(unit($y))
end

@inline unit(x::UnitDatum) = x.unit
@inline unit(x::DimensionDatum) = x.unit
@inline unitless(x::Quantity) = x.val
unitless{T<:Quantity}(x::Complex{T}) = unitless(real(x))+unitless(imag(x))*im

@inline tens(x::UnitDatum) = x.tens
@inline tens(x::DimensionDatum) = 0
@inline power(x) = x.power

@inline Quantity(x::AbstractFloat, y::UnitData{()}) = x
@inline Quantity(x::AbstractFloat, y) = FloatQuantity{typeof(x), typeof(y)}(x)
@inline Quantity(x, y::UnitData{()}) = x
@inline Quantity(x, y) = RealQuantity{typeof(x), typeof(y)}(x)

unit{T,Units}(x::Quantity{T,Units}) = Units()
unit{T,Units}(x::Complex{FloatQuantity{T,Units}}) = Units()
unit{T,Units}(x::Complex{RealQuantity{T,Units}}) = Units()
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
`basefactor(x)` specifies conversion factors to base SI units.
It returns a tuple. The first value is any irrational part of the conversion,
and the second value is a rational component. This segregation permits exact
conversions within unit systems that have no rational conversion to SI.
"""
function basefactor end

"""
`basefactor(x::UnitDatum)`

Powers of ten are not included for overflow reasons. See `tensfactor`
"""
function basefactor(x::UnitDatum)
    inex, ex = basefactor(Val{unit(x)})
    p = power(x)
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

"""
`basefactor(x::UnitData)`

Calls `basefactor` on each of the UnitDatum and multiplies together.
Needs some overflow checking?
"""
@generated function basefactor(x::UnitData)
    tunits = x.parameters[1]
    fact1 = map(basefactor, tunits)
    inex1 = mapreduce(x->getfield(x,1), *, fact1)
    ex1   = mapreduce(x->getfield(x,2), *, fact1)
    :(($inex1,$ex1))
end

function tensfactor(x::UnitDatum)
    p = power(x)
    if isinteger(p)
        p = Integer(p)
    end
    abc = (unit(x) == unit(kg) ? 3 : 0)
    tens(x)*p - abc
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
*{T<:UnitData}(x::Bool, y::T) = Quantity(x,y)

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

function *(x::Complex, y::UnitData)
    a,b = reim(x)
    Complex(a*y,b*y)
end

function *(y::UnitData, x::Complex)
    a,b = reim(x)
    Complex(a*y,b*y)
end

"Necessary to enable expressions like Complex(1V,1mV)."
@generated function Complex{S,T,U,V}(x::Quantity{S,T}, y::Quantity{U,V})
    resulttype = typeof(x(1)+y(1))
    :(Complex{$resulttype}(convert($resulttype,x),convert($resulttype,y)))
end

for (f,F) in ((Base.DotMulFun, :*),
              (Base.DotRDivFun, :/),
              (Base.MulFun, :*),
              (Base.RDivFun, :/))

    # Probably some optimizations to be done here...
    types = [RealQuantity, FloatQuantity]

    for a in types, b in types
        @eval @generated function promote_op{S,SUnits,T,TUnits}(::$f,
                ::Type{($a){S,SUnits}}, ::Type{($b){T,TUnits}})

            numtype = promote_op(($f)(),S,T)
            quant = numtype <: AbstractFloat ? FloatQuantity : RealQuantity
            unittype = typeof(($F)(SUnits(), TUnits()))
            :(($quant){$numtype, $unittype})
        end
    end

    for a in types
        @eval begin
            # number, quantity
            @generated function promote_op{R<:Real,S,SUnits}(::$f,
                ::Type{R}, ::Type{($a){S,SUnits}})

                numtype = promote_op(($f)(),R,S)
                quant = numtype <: AbstractFloat ? FloatQuantity : RealQuantity
                unittype = typeof(($F)(UnitData{()}(), SUnits()))
                :(($quant){$numtype, $unittype})
            end

            # quantity, number
            @generated function promote_op{R<:Real,S,SUnits}(::$f,
                ::Type{($a){S,SUnits}}, ::Type{R})

                numtype = promote_op(($f)(),S,R)
                quant = numtype <: AbstractFloat ? FloatQuantity : RealQuantity
                unittype = typeof(($F)(SUnits(), UnitData{()}()))
                :(($quant){$numtype, $unittype})
            end

            # unit, quantity
            @generated function promote_op{R<:UnitData,S,SUnits}(::$f,
                ::Type{($a){S,SUnits}}, ::Type{R})

                numtype = S
                quant = numtype <: AbstractFloat ? FloatQuantity : RealQuantity
                unittype = typeof(($F)(SUnits(), R()))
                :(($quant){$numtype, $unittype})
            end

            # quantity, unit
            @generated function promote_op{R<:UnitData,S,SUnits}(::$f,
                ::Type{R}, ::Type{($a){S,SUnits}})

                numtype = promote_op(($f)(),one(S),S)
                quant = numtype <: AbstractFloat ? FloatQuantity : RealQuantity
                unittype = typeof(($F)(R(), SUnits()))
                :(($quant){$numtype, $unittype})
            end
        end
    end

    @eval begin
        @generated function promote_op{R<:Real,S<:UnitData}(::$f,
            x::Type{R}, y::Type{S})
            quant = R <: AbstractFloat ? FloatQuantity : RealQuantity
            unittype = typeof(($F)(UnitData{()}(), S()))
            :(($quant){x, $unittype})
        end

        @generated function promote_op{R<:Real,S<:UnitData}(::$f,
            y::Type{S}, x::Type{R})
            quant = R <: AbstractFloat ? FloatQuantity : RealQuantity
            unittype = typeof(($F)(S(), UnitData{()}()))
            :(($quant){x, $unittype})
        end
    end
end

# See operators.jl
# Element-wise operations with units
for (f,F) in [(:./, :/), (:.*, :*), (:.+, :+), (:.-, :-)]
    @eval ($f)(x::UnitData, y::UnitData) = ($F)(x,y)
    @eval ($f)(x::Number, y::UnitData)   = ($F)(x,y)
    @eval ($f)(x::UnitData, y::Number)   = ($F)(x,y)
end
.\(x::UnitData, y::UnitData) = y./x
.\(x::Number, y::UnitData)   = y./x
.\(x::UnitData, y::Number)   = y./x

# See arraymath.jl
./(x::UnitData, Y::AbstractArray) =
    reshape([ x ./ y for y in Y ], size(Y))
./(X::AbstractArray, y::UnitData) =
    reshape([ x ./ y for x in X ], size(X))
.\(x::UnitData, Y::AbstractArray) =
    reshape([ x .\ y for y in Y ], size(Y))
.\(X::AbstractArray, y::UnitData) =
    reshape([ x .\ y for x in X ], size(X))

for (f,F) in ((:.*, Base.DotMulFun()),)
    @eval begin
        function ($f){T}(A::UnitData, B::AbstractArray{T})
            F = similar(B, promote_op($F,typeof(A),T))
            for i in eachindex(B)
                @inbounds F[i] = ($f)(A, B[i])
            end
            return F
        end
        function ($f){T}(A::AbstractArray{T}, B::UnitData)
            F = similar(A, promote_op($F,T,typeof(B)))
            for i in eachindex(A)
                @inbounds F[i] = ($f)(A[i], B)
            end
            return F
        end
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
    length(tup) == 0 && return :(x)
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

for (f, F) in [(:min, :<), (:max, :>)]
    @eval @generated function ($f)(x::Quantity, y::Quantity)
        xdim = dimension(x.parameters[2]())
        ydim = dimension(y.parameters[2]())
        if xdim != ydim
            return :(error("Dimensional mismatch."))
        end

        xunits = x.parameters[2].parameters[1]
        yunits = y.parameters[2].parameters[1]

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

    @eval ($f)(x::UnitData, y::UnitData) =
        unit(($f)(Quantity(1.0, x), Quantity(1.0, y)))
end

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

for f in [:zero, :floor, :ceil]
    @eval ($f)(x::Quantity) = Quantity(($f)(x.val), unit(x))
end

one(x::Quantity) = one(x.val)
one{T,U}(x::TypeQuantity{T,U}) = one(T)
isinteger(x::Quantity) = isinteger(x.val)
isreal(x::Quantity) = true # isreal(x.val)
isfinite(x::Quantity) = isfinite(x.val)
isinf(x::Quantity) = isinf(x.val)

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
function frexp(x::FloatQuantity)
    a,b = frexp(x.val)
    a *= unit(x)
    a,b
end

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
function show{T,Units}(io::IO, x::Quantity{T,Units})
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

"Show the unit, prefixing with any decimal prefix and appending the exponent."
function show(io::IO, x::UnitDatum)
    print(io, prefix(Val{tens(x)}()))
    print(io, abbr(Val{unit(x)}))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x))))
    nothing
end

"Show the dimension, appending any exponent."
function show(io::IO, x::DimensionDatum)
    print(io, abbr(Val{unit(x)}))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x))))
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
            const $(esc(s)) = UnitData{(UnitDatum($(esc(y)),$k,1//1),)}()
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
        const $(esc(s)) = UnitData{(UnitDatum($(esc(y)),0,1//1),)}()
        export $(esc(s))
    end
end

@generated function tscale(x::UnitData)
    tup = x.parameters[1]
    if length(tup) > 1
        return :(false)
    end
    u = unit(tup[1])
    if isa(u, TemperatureUnit)
        return :(true)
    else
        return :(false)
    end
end

offsettemp{T}(::Type{Val{T}}) = 0

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
        quote
            v = ((x.val + $t0) * $conv) - $t1
            Quantity(v, a)
        end
    else
        quote
            v = x.val * $conv
            Quantity(v, a)
        end
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

float(x::Quantity) = Quantity(float(x.val), unit(x))
Integer(x::Quantity) = Quantity(Integer(x.val), unit(x))
Rational(x::Quantity) = Quantity(Rational(x.val), unit(x))

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

# """
# Convert a unitful quantity to different units.
# """
# function convert{T,Units}(::Type{Quantity{T,Units}}, x::Quantity)
#     xunits = typeof(x).parameters[2]
#     conv = convert(Units(), xunits())
#     Quantity(T(x.val * conv), Units())
# end

@generated function convert{R,S,T,U}(::Type{FloatQuantity{R,S}}, x::Quantity{T,U})
    conv = convert(S(),U())
    :(Quantity(R(x.val*$conv),S()))
end
@generated function convert{R,S,T,U}(::Type{RealQuantity{R,S}}, x::Quantity{T,U})
    conv = convert(S(),U())
    :(Quantity(R(x.val*$conv),S()))
end

"Strip units from a number."
convert{S<:Number}(::Type{S}, x::Quantity) = convert(S, x.val)

include("Defaults.jl")

end
