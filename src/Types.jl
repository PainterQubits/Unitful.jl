
"""
```
immutable Dimension{D}
    power::Rational{Int}
end
```

Description of a dimension. The name of the dimension `D` is a symbol, e.g.
`:Length`, `:Time`, `:Mass`, etc.

`Dimension{D}` objects are collected in a tuple, which is used for the type
parameter `N` of a [`Dimensions{N}`](@ref) object.
"""
immutable Dimension{D}
    power::Rational{Int}
end

"""
```
immutable Unit{U,D}
    tens::Int
    power::Rational{Int}
end
```

Description of a physical unit, including powers-of-ten prefixes and powers of
the unit. The name of the unit is encoded in the type parameter `U` as a symbol,
e.g. `:Meter`, `:Second`, `:Gram`, etc. The type parameter `D` contains dimension
information, for instance `Unit{:Meter, typeof(𝐋)}` or `Unit{:Liter, typeof(𝐋^3)}`.
Note that the dimension information refers to the unit, not powers of the unit.

`Unit{U,D}` objects are almost never explicitly manipulated by the user. They
are collected in a tuple, which is used for the type parameter `N` of a
[`Units{N,D}`](@ref) object.
"""
immutable Unit{U,D}
    tens::Int
    power::Rational{Int}
end

"""
```
abstract type Unitlike end
```

Abstract type facilitating some code reuse between [`Unitful.Units`](@ref) and
[`Unitful.Dimensions`](@ref) objects.
"""
@compat abstract type Unitlike end

"""
```
immutable Units{N,D} <: Unitlike
```

Instances of this object represent units, possibly combinations thereof.
Example: the unit `m` is actually a singleton of type
`Unitful.Units{(Unitful.Unit{:Meter,typeof(𝐋)}(0,1//1,1.0,1//1),),typeof(𝐋)`.
After dividing by `s`, a singleton of type
`Unitful.Units{(Unitful.Unit{:Meter,typeof(𝐋)}(0,1//1,1.0,1//1),Unitful.Unit{:Second,typeof(𝐓)}(0,-1//1,1.0,1//1)),typeof(𝐋/𝐓)}` is returned.
"""
immutable Units{N,D} <: Unitlike end

"""
```
immutable Dimensions{N} <: Unitlike
```

Instances of this object represent dimensions, possibly combinations thereof.
"""
immutable Dimensions{N} <: Unitlike end


@static if VERSION < v"0.6.0-dev.2643"
    include_string("""
    immutable Quantity{T,D,U} <: Number
        val::T
        Quantity(v::Number) = new(v)
        Quantity(v::Quantity) = convert(Quantity{T,D,U}, v)
    end
    """)
else
    include_string("""
    immutable Quantity{T,D,U} <: Number
        val::T
        Quantity{T,D,U}(v::Number) where {T,D,U} = new(v)
        Quantity{T,D,U}(v::Quantity) where {T,D,U} = convert(Quantity{T,D,U}, v)
    end
    """)
end

"""
```
immutable Quantity{T,D,U} <: Number
```

A quantity, which has dimensions and units specified in the type signature.
The dimensions and units are allowed to be the empty set, in which case a
dimensionless, unitless number results.

The type parameter `T` represents the numeric backing type. The type parameters
`D <: ` [`Unitful.Dimensions`](@ref) and `U <: ` [`Unitful.Units`](@ref).
Of course, the dimensions follow from the units, but the type parameters are
kept separate to permit convenient dispatch on dimensions.
"""
Quantity

"""
```
DimensionlessQuantity{T,U} = Quantity{T, Dimensions{()},U}
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
@compat DimensionlessQuantity{T,U} = Quantity{T, Dimensions{()}, U}
