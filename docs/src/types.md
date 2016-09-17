```@meta
DocTestSetup = quote
    using Unitful
end
```
## Overview
We define a [`Unitful.Unit{U}`](@ref) type to represent a unit (`U` is a symbol,
like `:Meter`). `Unit`s keep track of a rational exponents and a power-of-ten
prefix. We don't allow arbitrary floating point exponents of units because they
probably aren't very useful. The prefixes on units (e.g. `nm` or `km`) may help
to avoid overflow issues and general ugliness.

We define the immutable singleton [`Unitful.Units{N,D}`](@ref), where `N` is
always a tuple of `Unit` objects, and `D` is some type, like `typeof(Unitful.𝐋)`,
where `𝐋` is the object representing the length dimension. Usually, the user
interacts only with `Units` objects, not `Unit` objects.

We define a function [`dimension`](@ref) that turns, for example, `acre^2` into
`𝐋^4`. We can add quantities with the same dimension, regardless of specific units.
Note that dimensions cannot be determined by powers of the units:
`ft^2` is an area, but so is `ac^1` (an acre).

We define physical quantity types as [`Quantity{T<:Number, D, U}`](@ref), where
`D <: Dimensions` and `U <: Units`. By putting units in the type signature of a
quantity, staged functions can be used to offload as much of the unit
computation to compile-time as is possible. By also having the dimensions
explicitly in the type signature, dispatch can be done on dimensions:
`isa(1m, Length) == true`. This works because `Length` is a type alias for
some subset of [`Unitful.DimensionedQuantity`](@ref) subtypes.

## Quantities
```@docs
    Unitful.DimensionedQuantity{D}
    Unitful.Quantity{T,D,U}
    Unitful.DimensionlessQuantity{T,U}
```

## Units and dimensions
```@docs
    Unitful.Unitlike
    Unitful.Units{N}
    Unitful.Dimensions{N}
    Unitful.Unit{U}
    Unitful.Dimension{D}
```
