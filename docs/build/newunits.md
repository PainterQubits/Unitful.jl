
Units are no longer defined directly by the package. Rather, macros for generating units and dimensions are provided. When [`Unitful.defaults`](newunits.md#Unitful.defaults) is called, a typically useful set of units and dimensions is generated in the `Main` module. [`Unitful.defaults`](newunits.md#Unitful.defaults) achieves this simply by including the file `src/Defaults.jl` from the package. If a different set of units or dimensions is desired, one can copy this file and use it as a template. One can then call `include` on the modified file where appropriate. In this manner, the user has flexibility to choose a minimal or specialized set of units without modifying the package itself, which would flag the package as "dirty" and hinder future updates.


To create new units interactively, just use the [`@unit`](newunits.md#Unitful.@unit) macro, providing five arguments:


1. The symbol to which the [`Unitful.Units`](types.md#Unitful.Units) object should be bound.
2. A string for how the unit is displayed.
3. The name of the unit (e.g. Meter).
4. A [`Quantity`](types.md#Unitful.Quantity) equivalent to one of the new unit.
5. A `Bool` to indicate whether or not to make symbols for all SI prefixes (as in `mm`, `km`, etc.)


Usage example:


```jl
@unit pim "π-meter" PiMeter π*m false
1pim # displays as "1 π-meter"
convert(m, 1pim) # evaluates to 3.14159... m
```


You can look at `Defaults.jl` in the package to see what units are there by default.


A note for the experts: Some care should be taken if explicitly making `Units` objects. The ordering of `Unit` objects inside a tuple matters for type comparisons. Using the unary multiplication operator on the `UnitData` object will return a "canonically sorted" `Units` object. Indeed, this is how we avoid ordering issues when multiplying quantities together.

<a id='Unitful.@dimension' href='#Unitful.@dimension'>#</a>
**`Unitful.@dimension`** &mdash; *Macro*.



```
macro dimension(name, abbr)
```

Extends [`Unitful.abbr`](display.md#Unitful.abbr). Creates a type alias for the new dimension and exports it.

Usage example: `@dimension 𝐋 "L" Length` (see `src/Defaults.jl`.)


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/User.jl#L1-L10' class='documenter-source'>source</a><br>

<a id='Unitful.@derived_dimension' href='#Unitful.@derived_dimension'>#</a>
**`Unitful.@derived_dimension`** &mdash; *Macro*.



```
macro derived_dimension(dimension, derived...)
```

Creates type aliases for derived dimensions, like `[Area] = [Length]^2`. Exports them.

Usage example: `@derived_dimension Area 𝐋^2`


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/User.jl#L24-L33' class='documenter-source'>source</a><br>

<a id='Unitful.@baseunit' href='#Unitful.@baseunit'>#</a>
**`Unitful.@baseunit`** &mdash; *Macro*.



```
macro baseunit(symb, name, abbr, dimension)
```

Define a base unit, typically but not necessarily SI.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/User.jl#L43-L49' class='documenter-source'>source</a><br>

<a id='Unitful.@unit' href='#Unitful.@unit'>#</a>
**`Unitful.@unit`** &mdash; *Macro*.



```
macro unit(symb,abbr,name,equals,tf)
```

Define a unit.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/User.jl#L60-L66' class='documenter-source'>source</a><br>

<a id='Unitful.offsettemp' href='#Unitful.offsettemp'>#</a>
**`Unitful.offsettemp`** &mdash; *Function*.



```
offsettemp(::Unit)
```

For temperature units, this function is used to set the scale offset.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/Unitful.jl#L627-L633' class='documenter-source'>source</a><br>

<a id='Unitful.defaults' href='#Unitful.defaults'>#</a>
**`Unitful.defaults`** &mdash; *Function*.



```
defaults()
```

Includes the file `src/Defaults.jl` from the Unitful package. This results in common units and dimensions being generated in the `Main` module.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f4f296fd4a32ae0e4d3ce39aa2a151c6f794c519/src/User.jl#L90-L97' class='documenter-source'>source</a><br>

