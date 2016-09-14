
"""
```
immutable Dimension{D}
    power::Rational{Int}
    Dimension(p) = new(p)
    Dimension(t,p) = new(p)
end
```

Description of a dimension. The name of the dimension `D` is a symbol, e.g.
`:Length`, `:Time`, `:Mass`, etc.

`Dimension{D}` objects are collected in a tuple, which is used for the type
parameter `N` of a [`Dimensions{N}`](@ref) object.

The two-argument constructor ignores the first argument and is used only in the
function [`*(::Unitlike,::Unitlike...)`](@ref).
"""
immutable Dimension{D}
    power::Rational{Int}
    Dimension(p) = new(p)
    Dimension(t,p) = new(p)
end

"""
```
immutable Unit{U}
    tens::Int
    power::Rational{Int}
end
```

Description of a physical unit, including powers-of-ten prefixes and powers of
the unit. The name of the unit `U` is a symbol, e.g. `:Meter`, `:Second`,
`:Gram`, etc. `Unit{U}` objects are collected in a tuple, which is used for the
type parameter `N` of a [`Units{N,D}`](@ref) object.
"""
immutable Unit{U}
    tens::Int
    power::Rational{Int}
end

"""
```
abstract Unitlike
```

Abstract container type for units or dimensions, which need similar
manipulations for collecting powers and sorting. This abstract type is probably
not strictly necessary but facilitates code reuse (see
[`*(::Unitlike,::Unitlike...)`](@ref)).
"""
abstract Unitlike

"""
```
abstract DimensionedUnits{D} <: Unitlike
```

Abstract type used in dispatching on the dimension of a unit.
"""
abstract DimensionedUnits{D} <: Unitlike

"""
```
immutable Units{N,D} <: DimensionedUnits{D}
```

Instances of this object represent units, possibly combinations thereof.
Example: the unit `m` is actually a singleton of type
`Units{(Unit{:Meter}(0,1),), typeof(u"𝐋")}`.
After dividing by `s`, a singleton of type
`Units{(Unit{:Meter}(0,1),Unit{:Second}(0,-1)), typeof(u"𝐋")}` is returned.
"""
immutable Units{N,D} <: DimensionedUnits{D} end

"""
```
immutable Dimensions{N} <: Unitlike
```

Instances of this object represent dimensions, possibly combinations thereof.
"""
immutable Dimensions{N} <: Unitlike end

"""
```
abstract DimensionedQuantity{D} <: Number
```

Super-type of [`Unitful.Quantity`](@ref) types. Used in dispatch on quantities
of a particular dimension, without having to specify the units. The type
parameter `D <: ` [`Unitful.Dimensions`](@ref).
"""
abstract DimensionedQuantity{D} <: Number

"""
```
immutable Quantity{T,D,U} <: DimensionedQuantity{D}
```

A quantity, which has dimensions and units specified in the type signature.
The dimensions and units are allowed to be the empty set, in which case a
dimensionless, unitless number results.

The type parameter `T` represents the numeric backing type. The type parameters
`D <: ` [`Unitful.Dimensions`](@ref) and `U <: ` [`Unitful.Units`](@ref).
Of course, the dimensions follow from the units, but the type parameters are
kept separate to permit convenient dispatch on dimensions.
"""
immutable Quantity{T,D,U} <: DimensionedQuantity{D}
    val::T
    Quantity(v::Number) = new(v)
    Quantity(v::Quantity) = convert(Quantity{T,D,U}, v)
end

"""
```
typealias UnitlessQuantity{T} Quantity{T, Dimensions{()}, Units{(), Dimensions{()}}}
```

When [`Unitful.Quantity`](@ref) objects are combined with unitless numbers in a
matrix or vector, e.g. as is sometimes encountered in general relativity, we wrap
the unitless numbers in a `UnitlessQuantity{T}` type. This way, the array can
specialize on the numeric backing type. Otherwise, the most specific container
would be something like `AbstractArray{Number}`.
"""
typealias UnitlessQuantity{T} Quantity{T, Dimensions{()}, Units{(),Dimensions{()}}}

UnitlessQuantity{T<:Quantity}(x::T) =
    error("To strip units, divide out by `unit(x)`.")
UnitlessQuantity{T<:Number}(x::T) = UnitlessQuantity{T}(x)

"""
```
typealias DimensionlessQuantity{T,U} Quantity{T, Dimensions{()},U}
```

Useful for dispatching on [`Unitful.Quantity`](@ref) types that may have units
but no dimensions. (Units with differing power-of-ten prefixes are not canceled
out.)

Example:
```jldoctest
julia> isa(1.0u"mV/V", DimensionlessQuantity)
true
```
"""
typealias DimensionlessQuantity{T,U} Quantity{T, Dimensions{()}, U}

"""
```
@generated function Quantity(x::Number, y::Units)
```

Outer constructor for `Quantity`s. This is a generated function to avoid
determining the dimensions of a given set of units each time a new quantity is
made.
"""
@generated function Quantity(x::Number, y::Units)
    if y == Units{(), Dimensions{()}}
        :(x)
    else
        u = y()
        d = dimension(u)
        :(Quantity{typeof(x), typeof($d), typeof($u)}(x))
    end
end
