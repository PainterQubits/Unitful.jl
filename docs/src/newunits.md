The package automatically generates a useful set of units and dimensions in the
`Unitful` module by including the file `deps/Defaults.jl`, which is generated
when this package is built. If a different set of default units or dimensions is
desired, one can modify this file and reload `Unitful`. (You can also delete it
and run `Pkg.build("Unitful")` to recover "factory settings.") In this manner,
the user has flexibility to choose a minimal or specialized set of units without
modifying the source code itself, which would flag the package as "dirty" and
hinder future updates.

Macros for generating units and dimensions are provided. To create new units
interactively, most users will be happy with the [`@unit`](@ref) macro.
You can look at `deps/Defaults.jl` in the package to see what units are there
by default.

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
Unitful.@preferunit
Unitful.@unit
Unitful.offsettemp
```

## Internals
```@docs
Unitful.@prefixed_unit_symbols
Unitful.@unit_symbols
Unitful.basefactor
```
