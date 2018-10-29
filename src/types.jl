
"""
    abstract type Unitlike end
Represents units or dimensions. Dimensions are unit-like in the sense that they are
not numbers but you can multiply or divide them and exponentiate by rationals.
"""
abstract type Unitlike end

"""
    struct Dimension{D}
        power::Rational{Int}
    end
Description of a dimension. The name of the dimension `D` is a symbol, e.g.
`:Length`, `:Time`, `:Mass`, etc.

`Dimension{D}` objects are collected in a tuple, which is used for the type
parameter `N` of a [`Dimensions{N}`](@ref) object.
"""
struct Dimension{D}
    power::Rational{Int}
end
@inline name(x::Dimension{D}) where {D} = D
@inline power(x::Dimension) = x.power

"""
    struct Dimensions{N} <: Unitlike
Instances of this object represent dimensions, possibly combinations thereof.
"""
struct Dimensions{N} <: Unitlike end
const NoDims = Dimensions{()}()

"""
    struct Unit{U,D}
        tens::Int
        power::Rational{Int}
    end
Description of a physical unit, including powers-of-ten prefixes and powers of
the unit. The name of the unit is encoded in the type parameter `U` as a symbol,
e.g. `:Meter`, `:Second`, `:Gram`, etc. The type parameter `D` contains dimension
information, for instance `Unit{:Meter, typeof(𝐋)}` or `Unit{:Liter, typeof(𝐋^3)}`.
Note that the dimension information refers to the unit, not powers of the unit.

`Unit{U,D}` objects are almost never explicitly manipulated by the user. They
are collected in a tuple, which is used for the type parameter `N` of a
[`Units{N,D,A}`](@ref) object.
"""
struct Unit{U,D}
    tens::Int
    power::Rational{Int}
end
@inline name(x::Unit{U}) where {U} = U
@inline tens(x::Unit) = x.tens
@inline power(x::Unit) = x.power
@inline dimension(u::Unit{U,D}) where {U,D} = D()^u.power

struct Affine{T} end

"""
    abstract type Units{N,D,A} <: Unitlike end
Abstract supertype of all units objects, which can differ in their implementation details.
`A` is a translation for affine quantities; for non-affine quantities it is `nothing`.
"""
abstract type Units{N,D,A} <: Unitlike end

affinetranslation(::Units{N,D,Affine{T}}) where {N,D,T} = T
affinetranslation(::Units{N,D,nothing}) where {N,D} = false

"""
    absoluteunit(::Units)
Given a unit, which may or may not be for constructing affine quantities (e.g. `°C`),
return the corresponding unit on the absolute temperature scale (e.g. `K`).
"""
function absoluteunit end

"""
    struct FreeUnits{N,D,A} <: Units{N,D,A}
Instances of this object represent units, possibly combinations thereof. These behave like
units have behaved in previous versions of Unitful, and provide a basic level of
functionality that should be acceptable to most users. See
[Basic promotion mechanisms](@ref) in the docs for details.

Example: the unit `m` is actually a singleton of type
`Unitful.FreeUnits{(Unitful.Unit{:Meter,typeof(𝐋)}(0,1//1,1.0,1//1),),typeof(𝐋)`.
After dividing by `s`, a singleton of type
`Unitful.FreeUnits{(Unitful.Unit{:Meter,typeof(𝐋)}(0,1//1,1.0,1//1),
Unitful.Unit{:Second,typeof(𝐓)}(0,-1//1,1.0,1//1)),typeof(𝐋/𝐓)}` is returned.
"""
struct FreeUnits{N,D,A} <: Units{N,D,A} end
FreeUnits{N,D}() where {N,D} = FreeUnits{N,D,nothing}()
FreeUnits(::Units{N,D,A}) where {N,D,A} = FreeUnits{N,D,A}()

const NoUnits = FreeUnits{(), Dimensions{()}}()
(y::FreeUnits)(x::Number) = uconvert(y,x)
absoluteunit(::FreeUnits{N,D,A}) where {N,D,A} = FreeUnits{N,D}()

"""
    struct ContextUnits{N,D,P,A} <: Units{N,D,A}
Instances of this object represent units, possibly combinations thereof.
It is in most respects like `FreeUnits{N,D,A}`, except that the type parameter `P` is
again a `FreeUnits{M,D}` type that specifies a preferred unit for promotion.
See [Advanced promotion mechanisms](@ref) in the docs for details.
"""
struct ContextUnits{N,D,P,A} <: Units{N,D,A} end
function ContextUnits(x::Units{N,D,A}, y::Units) where {N,D,A}
    D() !== dimension(y) && throw(DimensionError(x,y))
    ContextUnits{N,D,typeof(FreeUnits(y)),A}()
end
ContextUnits{N,D,P}() where {N,D,P} = ContextUnits{N,D,P,nothing}()
ContextUnits(u::Units{N,D,A}) where {N,D,A} =
    ContextUnits{N,D,typeof(FreeUnits(upreferred(u))),A}()

(y::ContextUnits)(x::Number) = uconvert(y,x)
absoluteunit(::ContextUnits{N,D,P,A}) where {N,D,P,A} = ContextUnits{N,D,P}()

"""
    struct FixedUnits{N,D,A} <: Units{N,D,A} end
Instances of this object represent units, possibly combinations thereof.
These are primarily intended for use when you would like to disable automatic unit
conversions. See [Advanced promotion mechanisms](@ref) in the docs for details.
"""
struct FixedUnits{N,D,A} <: Units{N,D,A} end
FixedUnits{N,D}() where {N,D} = FixedUnits{N,D,nothing}()
FixedUnits(::Units{N,D,A}) where {N,D,A} = FixedUnits{N,D,A}()

absoluteunit(::FixedUnits{N,D,A}) where {N,D,A} = FixedUnits{N,D}()

""""
    struct Quantity{T,D,U} <: Number
A quantity, which has dimensions and units specified in the type signature.
The dimensions and units are allowed to be the empty set, in which case a
dimensionless, unitless number results.

The type parameter `T` represents the numeric backing type. The type parameters
`D <: ` [`Unitful.Dimensions`](@ref) and `U <: ` [`Unitful.Units`](@ref).
Of course, the dimensions follow from the units, but the type parameters are
kept separate to permit convenient dispatch on dimensions.
"""
struct Quantity{T,D,U} <: Number
    val::T
    Quantity{T,D,U}(v::Number) where {T,D,U} = new{T,D,U}(v)
    Quantity{T,D,U}(v::Quantity) where {T,D,U} = convert(Quantity{T,D,U}, v)
end

"""
    DimensionlessUnits{U}
Useful for dispatching on [`Unitful.Units`](@ref) types that have no dimensions.

Example:
```jldoctest
julia> isa(Unitful.rad, DimensionlessUnits)
true
"""
const DimensionlessUnits{U} = Units{U, Dimensions{()}}

"""
    AffineUnits{N,D,A} = Units{N,D,A} where A<:Affine
Useful for dispatching on unit objects that indicate a quantity should affine-transform
under unit conversion, like absolute temperatures.
"""
const AffineUnits{N,D,A} = Units{N,D,A} where A<:Affine

"""
    ScalarUnits{N,D} = Units{N,D,nothing}
Useful for dispatching on unit objects that indicate a quantity should transform in the
usual scalar way under unit conversion.
"""
const ScalarUnits{N,D} = Units{N,D,nothing}

"""
    DimensionlessQuantity{T,U} = Quantity{T, Dimensions{()}, U}
Useful for dispatching on [`Unitful.Quantity`](@ref) types that may have units
but no dimensions. (Units with differing power-of-ten prefixes are not canceled
out.)

Example:
```jldoctest
julia> isa(1.0u"mV/V", DimensionlessQuantity)
true
```
"""
const DimensionlessQuantity{T,U} = Quantity{T, Dimensions{()}, U}

"""
    AffineQuantity{T,D,U} = Quantity{T,D,U} where U<:AffineUnits
Useful for dispatching on quantities that affine-transform under unit conversion, like
absolute temperatures.
"""
const AffineQuantity{T,D,U} = Quantity{T,D,U} where U<:AffineUnits

"""
    ScalarQuantity{T,D,U} = Quantity{T,D,U} where U<:ScalarUnits
Useful for dispatching on quantities that transform in the usual scalar way under unit
conversion.
"""
const ScalarQuantity{T,D,U} = Quantity{T,D,U} where U<:ScalarUnits

"""
    struct LogInfo{N,B,P}
Describes a logarithmic unit. Type parameters include:
- `N`: The name of the logarithmic unit, e.g. `:Decibel`, `:Neper`.
- `B`: The base of the logarithm.
- `P`: A prefactor to multiply the logarithm when the log is of a power ratio.
"""
struct LogInfo{N,B,P} end

"""
    abstract type LogScaled{L<:LogInfo} <: Number end
Abstract supertype of [`Unitful.Level`](@ref) and [`Unitful.Gain`](@ref). It is only
used in promotion to put levels and gains onto a common log scale.
"""
abstract type LogScaled{L<:LogInfo} <: Number end

"""
    struct Level{L, S, T<:Number} <: LogScaled{L}
A logarithmic scale-based level. Details about the logarithmic scale are encoded in
`L <: LogInfo`. `S` is a reference quantity for the level, not a type. This type has one
field, `val::T`, and the log of the ratio `val/S` is taken. This type differs from
[`Unitful.Gain`](@ref) in that `val` is a linear quantity.
"""
struct Level{L, S, T<:Number} <: LogScaled{L}
    val::T
    function Level{L,S,T}(x) where {L,S,T}
        dimension(S) != dimension(x) && throw(DimensionError(S,x))
        return new{L,S,T}(x)
    end
end
function Level{L,S}(val::Number) where {L,S}
    dimension(S) != dimension(val) && throw(DimensionError(S, val))
    return Level{L,S,typeof(val)}(val)
end

"""
    struct Gain{L, S, T<:Real} <: LogScaled{L}
A logarithmic scale-based gain or attenuation factor. This type has one field, `val::T`.
For example, given a gain of `20dB`, we have `val===20`. This type differs from
[`Unitful.Level`](@ref) in that `val` is stored after computing the logarithm.
"""
struct Gain{L, S, T<:Real} <: LogScaled{L}
    val::T
end

"""
    struct MixedUnits{T<:LogScaled, U<:Units}

Struct for representing mixed logarithmic / linear units. Primarily useful as an
intermediate for `uconvert`. `T` is `<: Level` or `<: Gain`.
"""
struct MixedUnits{T<:LogScaled, U<:Units}
    units::U
end
MixedUnits{T}() where {T} = MixedUnits{T, typeof(NoUnits)}(NoUnits)
MixedUnits{T}(u::Units) where {T} = MixedUnits{T,typeof(u)}(u)
(y::MixedUnits)(x::Number) = uconvert(y,x)
