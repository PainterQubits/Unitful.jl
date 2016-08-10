# Defining new units
Units are no longer defined directly by the package. Rather, macros for
generating units and dimensions are provided. When [`Unitful.defaults`](@ref) is
called, a typically useful set of units and dimensions is generated in the
`Main` module. [`Unitful.defaults`](@ref) achieves this simply by including the
file `src/Defaults.jl` from the package. If a different set of units or
dimensions is desired, one can copy this file and use it as a template. One can
then call `include` on the modified file where appropriate. In this manner,
the user has flexibility to choose a minimal or specialized set of units
without modifying the package itself, which would flag the package as "dirty"
and hinder future updates.

To create new units interactively, most users will be happy with the
[`@unit`](@ref) macro. You can look at `Defaults.jl` in the package to see what
units are there by default.

A note for the experts: Some care should be taken if explicitly making
[`Unitful.Units`](@ref) objects. The ordering of [`Unitful.Unit`](@ref) objects
inside a tuple matters for type comparisons. Using the unary multiplication
operator on the `Units` object will return a "canonically sorted" `Units` object.
Indeed, this is how we avoid ordering issues when multiplying quantities together.

# Useful functions and macros
```@docs
Unitful.defaults
Unitful.@dimension
Unitful.@derived_dimension
Unitful.@refunit
Unitful.@unit
Unitful.offsettemp
```

# Internals
```@docs
Unitful.@prefixed_unit_symbols
Unitful.@unit_symbols
Unitful.basefactor
```
