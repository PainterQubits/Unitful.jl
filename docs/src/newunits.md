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

To create new units interactively, just use the [`@unit`](@ref) macro, providing
five arguments:

1. The symbol to which the [`Unitful.Units`](@ref) object should be bound.
2. A string for how the unit is displayed.
3. The name of the unit (e.g. Meter).
4. A [`Quantity`](@ref) equivalent to one of the new unit.
5. A `Bool` to indicate whether or not to make symbols for all SI prefixes
   (as in `mm`, `km`, etc.)

Usage example:

```jl
@unit pim "π-meter" PiMeter π*m false
1pim # displays as "1 π-meter"
convert(m, 1pim) # evaluates to 3.14159... m
```

You can look at `Defaults.jl` in the package to see what units are there by
default.

A note for the experts: Some care should be taken if explicitly making `Units`
objects. The ordering of `Unit` objects inside a tuple matters for type
comparisons. Using the unary multiplication operator on the `UnitData` object
will return a "canonically sorted" `Units` object. Indeed, this is how we avoid
ordering issues when multiplying quantities together.

```@docs
Unitful.@dimension
Unitful.@derived_dimension
Unitful.@baseunit
Unitful.@unit
Unitful.offsettemp
Unitful.defaults
```
