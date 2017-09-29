


<a id='Overview-1'></a>

## Overview


We define a [`Unitful.Unit{U,D}`](types.md#Unitful.Unit) type to represent a unit (`U` is a symbol, like `:Meter`, and `D` keeps track of dimensional information). Fields of a `Unit` object keep track of a rational exponents and a power-of-ten prefix. We don't allow arbitrary floating point exponents of units because they probably aren't very useful. The prefixes on units (e.g. `nm` or `km`) may help to avoid overflow issues and general ugliness.


Usually, the user interacts only with `Units` objects, not `Unit` objects. This is because generically, more than one unit is needed to describe a quantity. An abstract type [`Unitful.Units{N,D}`](types.md#Unitful.Units) is defined, where `N` is always a tuple of `Unit` objects, and `D` is some type, like `typeof(Unitful.𝐋)`, where `𝐋` is the object representing the length dimension (see [`Unitful.Dimensions{N}`](types.md#Unitful.Dimensions)).


Subtypes of `Unitful.Units{N,D}` are used to implement different behaviors for how to promote dimensioned quantities. The concrete subtypes have no fields and are therefore immutable singletons. Currently implemented subtypes of `Unitful.Units{N,D}` include [`Unitful.FreeUnits{N,D}`](types.md#Unitful.FreeUnits), [`Unitful.ContextUnits{N,D,P}`](types.md#Unitful.ContextUnits), and [`Unitful.FixedUnits{N,D}`](types.md#Unitful.FixedUnits). Units defined in the Unitful.jl package itself are all `Unitful.FreeUnits{N,D}` objects.


Finally, we define physical quantity types as [`Quantity{T<:Number, D, U}`](types.md#Unitful.Quantity), where `D <: Dimensions` and `U <: Units`. By putting units in the type signature of a quantity, staged functions can be used to offload as much of the unit computation to compile-time as is possible. By also having the dimensions explicitly in the type signature, dispatch can be done on dimensions: `isa(1m, Length) == true`. This works because `Length` is a type alias for some subset of `Unitful.Quantity` subtypes.


<a id='API-1'></a>

## API


<a id='Quantities-1'></a>

### Quantities

<a id='Unitful.Quantity' href='#Unitful.Quantity'>#</a>
**`Unitful.Quantity`** &mdash; *Type*.



"     struct Quantity{T,D,U} <: Number A quantity, which has dimensions and units specified in the type signature. The dimensions and units are allowed to be the empty set, in which case a dimensionless, unitless number results.

The type parameter `T` represents the numeric backing type. The type parameters `D <:` [`Unitful.Dimensions`](types.md#Unitful.Dimensions) and `U <:` [`Unitful.Units`](types.md#Unitful.Units). Of course, the dimensions follow from the units, but the type parameters are kept separate to permit convenient dispatch on dimensions.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L104-L116' class='documenter-source'>source</a><br>

<a id='Unitful.DimensionlessQuantity' href='#Unitful.DimensionlessQuantity'>#</a>
**`Unitful.DimensionlessQuantity`** &mdash; *Type*.



```
DimensionlessQuantity{T,U} = Quantity{T, Dimensions{()}, U}
```

Useful for dispatching on [`Unitful.Quantity`](types.md#Unitful.Quantity) types that may have units but no dimensions. (Units with differing power-of-ten prefixes are not canceled out.)

Example:

```julia-repl
julia> isa(1.0u"mV/V", DimensionlessQuantity)
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L122-L133' class='documenter-source'>source</a><br>


<a id='Units-and-dimensions-1'></a>

### Units and dimensions

<a id='Unitful.Unitlike' href='#Unitful.Unitlike'>#</a>
**`Unitful.Unitlike`** &mdash; *Type*.



```
abstract type Unitlike end
```

Represents units or dimensions. Dimensions are unit-like in the sense that they are not numbers but you can multiply or divide them and exponentiate by rationals.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L2-L6' class='documenter-source'>source</a><br>

<a id='Unitful.Units' href='#Unitful.Units'>#</a>
**`Unitful.Units`** &mdash; *Type*.



```
abstract type Units{N,D} <: Unitlike end
```

Abstract supertype of all units objects, which can differ in their implementation details.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L56-L59' class='documenter-source'>source</a><br>

<a id='Unitful.FreeUnits' href='#Unitful.FreeUnits'>#</a>
**`Unitful.FreeUnits`** &mdash; *Type*.



```
struct FreeUnits{N,D} <: Units{N,D}
```

Instances of this object represent units, possibly combinations thereof. These behave like units have behaved in previous versions of Unitful, and provide a basic level of functionality that should be acceptable to most users. See [Basic promotion mechanisms](conversion.md#Basic-promotion-mechanisms-1) in the docs for details.

Example: the unit `m` is actually a singleton of type `Unitful.FreeUnits{(Unitful.Unit{:Meter,typeof(𝐋)}(0,1//1,1.0,1//1),),typeof(𝐋)`. After dividing by `s`, a singleton of type `Unitful.FreeUnits{(Unitful.Unit{:Meter,typeof(𝐋)}(0,1//1,1.0,1//1), Unitful.Unit{:Second,typeof(𝐓)}(0,-1//1,1.0,1//1)),typeof(𝐋/𝐓)}` is returned.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L62-L74' class='documenter-source'>source</a><br>

<a id='Unitful.ContextUnits' href='#Unitful.ContextUnits'>#</a>
**`Unitful.ContextUnits`** &mdash; *Type*.



```
struct ContextUnits{N,D,P} <: Units{N,D}
```

Instances of this object represent units, possibly combinations thereof. It is in most respects like `FreeUnits{N,D}`, except that the type parameter `P` is again a `FreeUnits{M,D}` type that specifies a preferred unit for promotion. See [Advanced promotion mechanisms](conversion.md#Advanced-promotion-mechanisms-1) in the docs for details.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L80-L86' class='documenter-source'>source</a><br>

<a id='Unitful.FixedUnits' href='#Unitful.FixedUnits'>#</a>
**`Unitful.FixedUnits`** &mdash; *Type*.



```
struct FixedUnits{N,D} <: Units{N,D} end
```

Instances of this object represent units, possibly combinations thereof. These are primarily intended for use when you would like to disable automatic unit conversions. See [Advanced promotion mechanisms](conversion.md#Advanced-promotion-mechanisms-1) in the docs for details.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L95-L100' class='documenter-source'>source</a><br>

<a id='Unitful.Dimensions' href='#Unitful.Dimensions'>#</a>
**`Unitful.Dimensions`** &mdash; *Type*.



```
struct Dimensions{N} <: Unitlike
```

Instances of this object represent dimensions, possibly combinations thereof.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L25-L28' class='documenter-source'>source</a><br>

<a id='Unitful.Unit' href='#Unitful.Unit'>#</a>
**`Unitful.Unit`** &mdash; *Type*.



```
struct Unit{U,D}
    tens::Int
    power::Rational{Int}
end
```

Description of a physical unit, including powers-of-ten prefixes and powers of the unit. The name of the unit is encoded in the type parameter `U` as a symbol, e.g. `:Meter`, `:Second`, `:Gram`, etc. The type parameter `D` contains dimension information, for instance `Unit{:Meter, typeof(𝐋)}` or `Unit{:Liter, typeof(𝐋^3)}`. Note that the dimension information refers to the unit, not powers of the unit.

`Unit{U,D}` objects are almost never explicitly manipulated by the user. They are collected in a tuple, which is used for the type parameter `N` of a [`Units{N,D}`](types.md#Unitful.Units) object.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L32-L46' class='documenter-source'>source</a><br>

<a id='Unitful.Dimension' href='#Unitful.Dimension'>#</a>
**`Unitful.Dimension`** &mdash; *Type*.



```
struct Dimension{D}
    power::Rational{Int}
end
```

Description of a dimension. The name of the dimension `D` is a symbol, e.g. `:Length`, `:Time`, `:Mass`, etc.

`Dimension{D}` objects are collected in a tuple, which is used for the type parameter `N` of a [`Dimensions{N}`](types.md#Unitful.Dimensions) object.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/types.jl#L9-L18' class='documenter-source'>source</a><br>

