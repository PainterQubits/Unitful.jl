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
[`Units{N,D}`](@ref) object.
"""
struct Unit{U,D}
    tens::Int
    power::Rational{Int}
end

"""
    abstract type Unitlike end
Represents units or dimensions. Dimensions are unit-like in the sense that they are
not numbers but you can multiply or divide them and exponentiate by rationals.
"""
abstract type Unitlike end

"""
    abstract type Units{N,D} <: Unitlike end
Abstract supertype of all units objects, which can differ in their implementation details.
"""
abstract type Units{N,D} <: Unitlike end

"""
    struct FreeUnits{N,D} <: Units{N,D}
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
struct FreeUnits{N,D} <: Units{N,D} end
FreeUnits{N,D}(::Units{N,D}) = FreeUnits{N,D}()

"""
    struct ContextUnits{N,D,P} <: Units{N,D}
Instances of this object represent units, possibly combinations thereof.
It is in most respects like `FreeUnits{N,D}`, except that the type parameter `P` is
again a `FreeUnits{M,D}` type that specifies a preferred unit for promotion.
See [Advanced promotion mechanisms](@ref) in the docs for details.
"""
struct ContextUnits{N,D,P} <: Units{N,D} end
function ContextUnits{N,D}(x::Units{N,D}, y::Units)
    D() !== dimension(y) && throw(DimensionError(x,y))
    ContextUnits{N,D,typeof(FreeUnits(y))}()
end
ContextUnits{N,D}(u::Units{N,D}) = ContextUnits{N,D,typeof(FreeUnits(upreferred(u)))}()

"""
    struct FixedUnits{N,D} <: Units{N,D} end
Instances of this object represent units, possibly combinations thereof.
These are primarily intended for use when you would like to disable automatic unit
conversions. See [Advanced promotion mechanisms](@ref) in the docs for details.
"""
struct FixedUnits{N,D} <: Units{N,D} end
FixedUnits{N,D}(::Units{N,D}) = FixedUnits{N,D}()

"""
    struct Dimensions{N} <: Unitlike
Instances of this object represent dimensions, possibly combinations thereof.
"""
struct Dimensions{N} <: Unitlike end

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
    Quantity{T,D,U}(v::Number) where {T,D,U} = new(v)
    Quantity{T,D,U}(v::Quantity) where {T,D,U} = convert(Quantity{T,D,U}, v)
end

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
