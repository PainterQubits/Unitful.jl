


<a id='Overview-1'></a>

## Overview


We define a [`Unitful.Unit{U}`](types.md#Unitful.Unit) type to represent a unit (`U` is a symbol, like `:Meter`). `Unit`s keep track of a rational exponents and a power-of-ten prefix. We don't allow arbitrary floating point exponents of units because they probably aren't very useful. The prefixes on units (e.g. `nm` or `km`) may help to avoid overflow issues and general ugliness.


We define the immutable singleton [`Unitful.Units{N}`](types.md#Unitful.Units), where `N` is always a tuple of `Unit` objects. Usually, the user interacts only with `Units` objects, not `Unit` objects.


We define a function [`dimension`](manipulations.md#Unitful.dimension-Tuple{Number}) that turns, for example, `acre^2` into `𝐋^4`. We can add quantities with the same dimension, regardless of specific units. Note that dimensions cannot be determined by powers of the units: `ft^2` is an area, but so is `ac^1` (an acre).


We define physical quantity types as [`Quantity{T<:Number, D, U}`](types.md#Unitful.Quantity), where `D <: Dimensions` and `U <: Units`. By putting units in the type signature of a quantity, staged functions can be used to offload as much of the unit computation to compile-time as is possible. By also having the dimensions explicitly in the type signature, dispatch can be done on dimensions: `isa(1m, Length) == true`. This works because `Length{T}` is a type alias for some subset of [`Unitful.DimensionedQuantity`](types.md#Unitful.DimensionedQuantity) subtypes.


<a id='Quantities-1'></a>

## Quantities

<a id='Unitful.AbstractQuantity' href='#Unitful.AbstractQuantity'>#</a>
**`Unitful.AbstractQuantity`** &mdash; *Type*.



```
abstract AbstractQuantity{T<:Number} <: Number
```

Super-type of [`Unitful.DimensionedQuantity`](types.md#Unitful.DimensionedQuantity) types. Used in promotion when making arrays of quantities with differing dimensions (or when combining with unitless numbers). The type parameter `T` is the numeric backing type.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L77-L85' class='documenter-source'>source</a><br>

<a id='Unitful.DimensionedQuantity' href='#Unitful.DimensionedQuantity'>#</a>
**`Unitful.DimensionedQuantity`** &mdash; *Type*.



```
abstract DimensionedQuantity{T,D} <: AbstractQuantity{T}
```

Super-type of [`Unitful.Quantity`](types.md#Unitful.Quantity) types. Used in dispatch on quantities of a particular dimension, without having to specify the units. The type parameter `T` is the numeric backing type, and `D <:` [`Unitful.Dimensions`](types.md#Unitful.Dimensions).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L88-L96' class='documenter-source'>source</a><br>

<a id='Unitful.Quantity' href='#Unitful.Quantity'>#</a>
**`Unitful.Quantity`** &mdash; *Type*.



```
immutable Quantity{T,D,U} <: DimensionedQuantity{T,D}
```

A quantity, which has dimensions and units specified in the type signature. The dimensions and units are allowed to be the empty set, in which case a dimensionless, unitless number results.

The type parameter `T` represents the numeric backing type. The type parameters `D <:` [`Unitful.Dimensions`](types.md#Unitful.Dimensions) and `U <:` [`Unitful.Units`](types.md#Unitful.Units). Of course, the dimensions follow from the units, but the type parameters are kept separate to permit convenient dispatch on dimensions.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L99-L112' class='documenter-source'>source</a><br>

<a id='Unitful.DimensionlessQuantity' href='#Unitful.DimensionlessQuantity'>#</a>
**`Unitful.DimensionlessQuantity`** &mdash; *Constant*.



```
typealias DimensionlessQuantity{T,U} Quantity{T, Dimensions{()},U}
```

Useful for dispatching on [`Unitful.Quantity`](types.md#Unitful.Quantity) types that may have units but no dimensions. (Units with differing power-of-ten prefixes are not canceled out.)

Example:

```jlcon
julia> isa(1.0u"mV/V", DimensionlessQuantity)
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L134-L148' class='documenter-source'>source</a><br>

<a id='Unitful.UnitlessQuantity' href='#Unitful.UnitlessQuantity'>#</a>
**`Unitful.UnitlessQuantity`** &mdash; *Constant*.



```
typealias UnitlessQuantity{T} Quantity{T, Dimensions{()}, Units{()}}
```

When [`Unitful.Quantity`](types.md#Unitful.Quantity) objects are combined with unitless numbers in a matrix or vector, e.g. as is sometimes encountered in general relativity, we wrap the unitless numbers in a `UnitlessQuantity{T}` type. This way, the array can specialize on the numeric backing type. Otherwise, the most specific container would be something like `AbstractArray{Number}`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L117-L127' class='documenter-source'>source</a><br>


<a id='Units-and-dimensions-1'></a>

## Units and dimensions

<a id='Unitful.Unitlike' href='#Unitful.Unitlike'>#</a>
**`Unitful.Unitlike`** &mdash; *Type*.



```
abstract Unitlike
```

Abstract container type for units or dimensions, which need similar manipulations for collecting powers and sorting. This abstract type is probably not strictly necessary but facilitates code reuse (see [`*(::Unitlike,::Unitlike...)`](manipulations.md#Base.:*-Tuple{Unitful.Unitlike,Vararg{Unitful.Unitlike,N}})).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L44-L53' class='documenter-source'>source</a><br>

<a id='Unitful.Units' href='#Unitful.Units'>#</a>
**`Unitful.Units`** &mdash; *Type*.



```
immutable Units{N} <: Unitlike
```

Instances of this object represent units, possibly combinations thereof. Example: the unit `m` is actually a singleton of type `Units{(Unit{:Meter}(0,1),)}`. After dividing by `s`, a singleton of type `Units{(Unit{:Meter}(0,1),Unit{:Second}(0,-1))}` is returned.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L56-L65' class='documenter-source'>source</a><br>

<a id='Unitful.Dimensions' href='#Unitful.Dimensions'>#</a>
**`Unitful.Dimensions`** &mdash; *Type*.



```
immutable Dimensions{N} <: Unitlike
```

Instances of this object represent dimensions, possibly combinations thereof.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L68-L74' class='documenter-source'>source</a><br>

<a id='Unitful.Unit' href='#Unitful.Unit'>#</a>
**`Unitful.Unit`** &mdash; *Type*.



```
immutable Unit{U}
    tens::Int
    power::Rational{Int}
end
```

Description of a physical unit, including powers-of-ten prefixes and powers of the unit. The name of the unit `U` is a symbol, e.g. `:Meter`, `:Second`, `:Gram`, etc. `Unit{U}` objects are collected in a tuple, which is used for the type parameter `N` of a [`Units{N}`](types.md#Unitful.Units) object.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L26-L38' class='documenter-source'>source</a><br>

<a id='Unitful.Dimension' href='#Unitful.Dimension'>#</a>
**`Unitful.Dimension`** &mdash; *Type*.



```
immutable Dimension{D}
    power::Rational{Int}
    Dimension(p) = new(p)
    Dimension(t,p) = new(p)
end
```

Description of a dimension. The name of the dimension `D` is a symbol, e.g. `:Length`, `:Time`, `:Mass`, etc.

`Dimension{D}` objects are collected in a tuple, which is used for the type parameter `N` of a [`Dimensions{N}`](types.md#Unitful.Dimensions) object.

The two-argument constructor ignores the first argument and is used only in the function [`*(::Unitlike,::Unitlike...)`](manipulations.md#Base.:*-Tuple{Unitful.Unitlike,Vararg{Unitful.Unitlike,N}}).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Types.jl#L2-L19' class='documenter-source'>source</a><br>

