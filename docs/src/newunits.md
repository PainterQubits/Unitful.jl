The package automatically generates a useful set of units and dimensions in the
`Unitful` module in `src/pkgdefaults.jl`.

If a different set of default units or dimensions is desired, macros for
generating units and dimensions are provided. To create new units
interactively, most users will be happy with the [`@unit`](@ref) macro.

A note for the experts: Some care should be taken if explicitly creating
[`Unitful.Units`](@ref) objects. The ordering of [`Unitful.Unit`](@ref) objects
inside a tuple matters for type comparisons. Using the unary multiplication
operator on the `Units` object will return a "canonically sorted" `Units` object.
Indeed, this is how we avoid ordering issues when multiplying quantities together.

## Useful functions and macros
```@docs
Unitful.@dimension
Unitful.@derived_dimension
Unitful.@refunit
Unitful.@unit
Unitful.preferunits
Unitful.offsettemp
```

## Internals
```@docs
Unitful.@prefixed_unit_symbols
Unitful.@unit_symbols
Unitful.basefactor
```
