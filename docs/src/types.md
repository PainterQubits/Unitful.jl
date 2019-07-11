```@meta
DocTestSetup = quote
    using Unitful
end
```
## Overview
We define a [`Unitful.Unit{U,D}`](@ref) type to represent a unit (`U` is a symbol,
like `:Meter`, and `D` keeps track of dimensional information).
Fields of a `Unit` object keep track of a rational exponents and a power-of-ten
prefix. We don't allow arbitrary floating point exponents of units because they
probably aren't very useful. The prefixes on units (e.g. `nm` or `km`) may help
to avoid overflow issues and general ugliness.

Usually, the user interacts only with `Units` objects, not `Unit` objects.
This is because generically, more than one unit is needed to describe a quantity.
An abstract type [`Unitful.Units{N,D}`](@ref) is defined, where `N` is always a tuple
of `Unit` objects, and `D` is a [`Unitful.Dimensions{N}`](@ref) object such as `ᴸ`, the
object representing the length dimension.

Subtypes of `Unitful.Units{N,D}` are used to implement different behaviors
for how to promote dimensioned quantities. The concrete subtypes have no fields and
are therefore immutable singletons. Currently implemented subtypes of `Unitful.Units{N,D}`
include [`Unitful.FreeUnits{N,D}`](@ref), [`Unitful.ContextUnits{N,D,P}`](@ref), and
[`Unitful.FixedUnits{N,D}`](@ref). Units defined in the Unitful.jl package itself are all
`Unitful.FreeUnits{N,D}` objects.

Finally, we define physical quantity types as [`Quantity{T<:Number, D, U}`](@ref), where
`D :: Dimensions` and `U <: Units`. By putting units in the type signature of a
quantity, staged functions can be used to offload as much of the unit
computation to compile-time as is possible. By also having the dimensions
explicitly in the type signature, dispatch can be done on dimensions:
`isa(1m, Length) == true`. This works because `Length` is a type alias for
some subset of `Unitful.Quantity` subtypes.

## API

### Quantities
```@docs
    Unitful.Quantity{T,D,U}
    Unitful.DimensionlessQuantity{T,U}
```

### Units and dimensions
```@docs
    Unitful.Unitlike
    Unitful.Units{N,D}
    Unitful.FreeUnits{N,D}
    Unitful.ContextUnits{N,D,P}
    Unitful.FixedUnits{N,D}
    Unitful.Dimensions{N}
    Unitful.Unit{U,D}
    Unitful.Dimension{D}
```
