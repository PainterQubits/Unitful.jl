Like SIUnits.jl, units are part of the type signature of a quantity. From there,
the implementations diverge. Unitful.jl uses generated functions to enable more
flexibility than found in SIUnits.jl. Support is targeted to Julia 0.5 and up.

We define a [`Unitful.Unit{U}`](@ref) type to represent a unit (`U` is a symbol,
like `:Meter`). `Unit`s keep track of a rational exponents and a power-of-ten
prefix. We don't allow arbitrary floating point exponents of units because they
probably aren't very useful. The prefixes on units (e.g. `nm` or `km`) may help
to avoid overflow issues and general ugliness.

We define the immutable singleton [`Unitful.Units{N}`](@ref), where `N` is
always a tuple of `Unit` objects. Usually, the user interacts only with `Units`
objects, not `Unit` objects.

We define a function [`dimension`](@ref) that turns, for example, `acre^2` into
`[L]^4`. We can in principle add quantities with the same dimension
(`acre [L]^2 + ft^2 [L]^2`), provided some promotion rules are given. Note that
dimensions cannot be determined by powers of the units: `ft^2` is an area, but
so is `acre^1`.

We define physical quantity types as [`Quantity{T<:Number, D, U}`](@ref), where
`D <: Dimensions` and `U <: Units`. By putting units in the type signature of a
quantity, staged functions can be used to offload as much of the unit
computation to compile-time as is possible. By also having the dimensions
explicitly in the type signature, dispatch can be done on dimensions:
`isa(1m, Length) == true`. This works because `Length{T,U}` is a type alias for
some subset of `Quantity` subtypes.

```@docs
    Unitful.Quantity{T,D,U}
    Unitful.Unitlike
    Unitful.Units{N}
    Unitful.Dimensions{N}
    Unitful.Unit{U}
    Unitful.Dimension{D}
```
