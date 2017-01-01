


<a id='Overview-1'></a>

## Overview


We define a [`Unitful.Unit{U,D}`](types.md#Unitful.Unit) type to represent a unit (`U` is a symbol, like `:Meter`, and `D` keeps track of dimensional information). Fields of a `Unit` object keep track of a rational exponents and a power-of-ten prefix. We don't allow arbitrary floating point exponents of units because they probably aren't very useful. The prefixes on units (e.g. `nm` or `km`) may help to avoid overflow issues and general ugliness.


We define the immutable singleton [`Unitful.Units{N,D}`](types.md#Unitful.Units), where `N` is always a tuple of `Unit` objects, and `D` is some type, like `typeof(Unitful.𝐋)`, where `𝐋` is the object representing the length dimension. Usually, the user interacts only with `Units` objects, not `Unit` objects.


We define a function [`dimension`](manipulations.md#Unitful.dimension-Tuple{Number}) that turns, for example, `acre^2` into `𝐋^4`. We can add quantities with the same dimension, regardless of specific units. Note that dimensions cannot be determined by powers of the units: `ft^2` is an area, but so is `ac^1` (an acre).


We define physical quantity types as [`Quantity{T<:Number, D, U}`](types.md#Unitful.Quantity), where `D <: Dimensions` and `U <: Units`. By putting units in the type signature of a quantity, staged functions can be used to offload as much of the unit computation to compile-time as is possible. By also having the dimensions explicitly in the type signature, dispatch can be done on dimensions: `isa(1m, Length) == true`. This works because `Length` is a type alias for some subset of [`Unitful.Quantity`](types.md#Unitful.Quantity) subtypes.


<a id='Quantities-1'></a>

## Quantities

<a id='Unitful.Quantity' href='#Unitful.Quantity'>#</a>
**`Unitful.Quantity`** &mdash; *Type*.



```
immutable Quantity{T,D,U} <: Number
```

A quantity, which has dimensions and units specified in the type signature. The dimensions and units are allowed to be the empty set, in which case a dimensionless, unitless number results.

The type parameter `T` represents the numeric backing type. The type parameters `D <:` [`Unitful.Dimensions`](types.md#Unitful.Dimensions) and `U <:` [`Unitful.Units`](types.md#Unitful.Units). Of course, the dimensions follow from the units, but the type parameters are kept separate to permit convenient dispatch on dimensions.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/d2424123e50241db7a88b81f66f302923fb394fe/src/Types.jl#L82-L95' class='documenter-source'>source</a><br>

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


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/d2424123e50241db7a88b81f66f302923fb394fe/src/Types.jl#L102-L116' class='documenter-source'>source</a><br>


<a id='Units-and-dimensions-1'></a>

## Units and dimensions

<a id='Unitful.Unitlike' href='#Unitful.Unitlike'>#</a>
**`Unitful.Unitlike`** &mdash; *Type*.



```
abstract Unitlike
```

Abstract type facilitating some code reuse between [`Unitful.Units`](types.md#Unitful.Units) and [`Unitful.Dimensions`](types.md#Unitful.Dimensions) objects.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/d2424123e50241db7a88b81f66f302923fb394fe/src/Types.jl#L50-L57' class='documenter-source'>source</a><br>

<a id='Unitful.Units' href='#Unitful.Units'>#</a>
**`Unitful.Units`** &mdash; *Type*.



```
immutable Units{N,D} <: Unitlike
```

Instances of this object represent units, possibly combinations thereof. Example: the unit `m` is actually a singleton of type `Unitful.Units{(Unitful.Unit{:Meter,typeof(𝐋)}(0,1//1,1.0,1//1),),typeof(𝐋)`. After dividing by `s`, a singleton of type `Unitful.Units{(Unitful.Unit{:Meter,typeof(𝐋)}(0,1//1,1.0,1//1),Unitful.Unit{:Second,typeof(𝐓)}(0,-1//1,1.0,1//1)),typeof(𝐋/𝐓)}` is returned.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/d2424123e50241db7a88b81f66f302923fb394fe/src/Types.jl#L60-L70' class='documenter-source'>source</a><br>

<a id='Unitful.Dimensions' href='#Unitful.Dimensions'>#</a>
**`Unitful.Dimensions`** &mdash; *Type*.



```
immutable Dimensions{N} <: Unitlike
```

Instances of this object represent dimensions, possibly combinations thereof.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/d2424123e50241db7a88b81f66f302923fb394fe/src/Types.jl#L73-L79' class='documenter-source'>source</a><br>

<a id='Unitful.Unit' href='#Unitful.Unit'>#</a>
**`Unitful.Unit`** &mdash; *Type*.



```
immutable Unit{U,D}
    tens::Int
    power::Rational{Int}
    inex::Float64
    ex::Rational{Int}
    Unit(a,b,c,d) = new(a,b,c,d)
    Unit(a,b,c::NTuple{2}) = new(a,b,c[1],c[2])
end
```

Description of a physical unit, including powers-of-ten prefixes and powers of the unit. The name of the unit is encoded in the type parameter `U` as a symbol, e.g. `:Meter`, `:Second`, `:Gram`, etc. The type parameter `D` contains dimension information, for instance `Unit{:Meter, typeof(𝐋)}` or `Unit{:Liter, typeof(𝐋^3)}`. Note that the dimension information refers to the unit, not powers of the unit.

`Unit{U,D}` objects are almost never explicitly manipulated by the user. They are collected in a tuple, which is used for the type parameter `N` of a [`Units{N,D}`](types.md#Unitful.Units) object.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/d2424123e50241db7a88b81f66f302923fb394fe/src/Types.jl#L19-L40' class='documenter-source'>source</a><br>

<a id='Unitful.Dimension' href='#Unitful.Dimension'>#</a>
**`Unitful.Dimension`** &mdash; *Type*.



```
immutable Dimension{D}
    power::Rational{Int}
end
```

Description of a dimension. The name of the dimension `D` is a symbol, e.g. `:Length`, `:Time`, `:Mass`, etc.

`Dimension{D}` objects are collected in a tuple, which is used for the type parameter `N` of a [`Dimensions{N}`](types.md#Unitful.Dimensions) object.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/d2424123e50241db7a88b81f66f302923fb394fe/src/Types.jl#L2-L14' class='documenter-source'>source</a><br>

