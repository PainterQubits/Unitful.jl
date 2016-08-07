
Like SIUnits.jl, units are part of the type signature of a quantity. From there, the implementations diverge. Unitful.jl uses generated functions to enable more flexibility than found in SIUnits.jl. Support is targeted to Julia 0.5 and up.


We define a [`Unitful.Unit{U}`](types.md#Unitful.Unit) type to represent a unit (`U` is a symbol, like `:Meter`). `Unit`s keep track of a rational exponents and a power-of-ten prefix. We don't allow arbitrary floating point exponents of units because they probably aren't very useful. The prefixes on units (e.g. `nm` or `km`) may help to avoid overflow issues and general ugliness.


We define the immutable singleton [`Unitful.Units{N}`](types.md#Unitful.Units), where `N` is always a tuple of `Unit` objects. Usually, the user interacts only with `Units` objects, not `Unit` objects.


We define a function [`dimension`](@ref) that turns, for example, `acre^2` into `[L]^4`. We can in principle add quantities with the same dimension (`acre [L]^2 + ft^2 [L]^2`), provided some promotion rules are given. Note that dimensions cannot be determined by powers of the units: `ft^2` is an area, but so is `acre^1`.


We define physical quantity types as [`Quantity{T<:Number, D, U}`](types.md#Unitful.Quantity), where `D <: Dimensions` and `U <: Units`. By putting units in the type signature of a quantity, staged functions can be used to offload as much of the unit computation to compile-time as is possible. By also having the dimensions explicitly in the type signature, dispatch can be done on dimensions: `isa(1m, Length) == true`. This works because `Length{T,U}` is a type alias for some subset of `Quantity` subtypes.

<a id='Unitful.Quantity' href='#Unitful.Quantity'>#</a>
**`Unitful.Quantity`** &mdash; *Type*.



```
immutable Quantity{T<:Number,D,U} <: Number
```

A physical quantity, which is dimensionful and has units. The type parameter `T` represents the numeric backing type. The type parameters `D <:` [`Unitful.Dimensions`](types.md#Unitful.Dimensions) and `U <:` [`Unitful.Units`](types.md#Unitful.Units). Of course, the dimensions follow from the units, but the type parameters are kept separate to permit convenient dispatch on dimensions.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/Types.jl#L77-L87' class='documenter-source'>source</a><br>

<a id='Unitful.Unitlike' href='#Unitful.Unitlike'>#</a>
**`Unitful.Unitlike`** &mdash; *Type*.



```
abstract Unitlike
```

Abstract container type for units or dimensions, which need similar manipulations for collecting powers and sorting. This abstract type is probably not strictly necessary but facilitates code reuse (see [`*(::Unitlike,::Unitlike...)`](@ref)).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/Types.jl#L44-L53' class='documenter-source'>source</a><br>

<a id='Unitful.Units' href='#Unitful.Units'>#</a>
**`Unitful.Units`** &mdash; *Type*.



```
immutable Units{N} <: Unitlike
```

Instances of this object represent units, possibly combinations thereof. Example: the unit `m` is actually a singleton of type `Units{(Unit{:Meter}(0,1),)}`. After dividing by `s`, a singleton of type `Units{(Unit{:Meter}(0,1),Unit{:Second}(0,-1))}` is returned.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/Types.jl#L56-L65' class='documenter-source'>source</a><br>

<a id='Unitful.Dimensions' href='#Unitful.Dimensions'>#</a>
**`Unitful.Dimensions`** &mdash; *Type*.



```
immutable Dimensions{N} <: Unitlike
```

Instances of this object represent dimensions, possibly combinations thereof.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/Types.jl#L68-L74' class='documenter-source'>source</a><br>

<a id='Unitful.Unit' href='#Unitful.Unit'>#</a>
**`Unitful.Unit`** &mdash; *Type*.



```
immutable Unit{U}
    tens::Int
    power::Rational{Int}
end
```

Description of a physical unit, including powers-of-ten prefixes and powers of the unit. The name of the unit `U` is a symbol, e.g. `:Meter`, `:Second`, `:Gram`, etc. `Unit{U}` objects are collected in a tuple, which is used for the type parameter `N` of a [`Units{N}`](types.md#Unitful.Units) object.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/Types.jl#L26-L38' class='documenter-source'>source</a><br>

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

The two-argument constructor ignores the first argument and is used only in the function [`*(::Unitlike,::Unitlike...)`](@ref).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/Types.jl#L2-L19' class='documenter-source'>source</a><br>

