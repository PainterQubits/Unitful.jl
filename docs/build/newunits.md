
The package automatically generates a useful set of units and dimensions in the `Unitful` module by including the file `deps/Defaults.jl`, which is generated when this package is built. If a different set of default units or dimensions is desired, one can modify this file and reload `Unitful`. (You can also delete it and run `Pkg.build("Unitful")` to recover "factory settings.") In this manner, the user has flexibility to choose a minimal or specialized set of units without modifying the source code itself, which would flag the package as "dirty" and hinder future updates.


Macros for generating units and dimensions are provided. To create new units interactively, most users will be happy with the [`@unit`](newunits.md#Unitful.@unit) macro. You can look at `deps/Defaults.jl` in the package to see what units are there by default.


A note for the experts: Some care should be taken if explicitly creating [`Unitful.Units`](types.md#Unitful.Units) objects. The ordering of [`Unitful.Unit`](types.md#Unitful.Unit) objects inside a tuple matters for type comparisons. Using the unary multiplication operator on the `Units` object will return a "canonically sorted" `Units` object. Indeed, this is how we avoid ordering issues when multiplying quantities together.


<a id='Useful-functions-and-macros-1'></a>

## Useful functions and macros

<a id='Unitful.@dimension' href='#Unitful.@dimension'>#</a>
**`Unitful.@dimension`** &mdash; *Macro*.



```
macro dimension(symb, abbr, name)
```

Creates new dimensions. `name` will be used like an identifier in the type parameter for a [`Unitful.Dimension`](types.md#Unitful.Dimension) object. `symb` will be a symbol defined in the namespace from which this macro is called that is bound to a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object. For most intents and purposes it is this object that the user would manipulate in doing dimensional analysis. The symbol is not exported.

This macro extends [`Unitful.abbr`](display.md#Unitful.abbr) to display the new dimension in an abbreviated format using the string `abbr`.

Finally, type aliases are created that allow the user to dispatch on [`Unitful.Quantity`](types.md#Unitful.Quantity) and [`Unitful.Units`](types.md#Unitful.Units) objects of the newly defined dimension. The type alias for quantities is simply given by `name`, and the type alias for units is given by `name*"Unit"`, e.g. `LengthUnit`.

Usage example: `@dimension 𝐋 "L" Length` (see `src/Defaults.jl`.)


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/User.jl#L22-L43' class='documenter-source'>source</a><br>

<a id='Unitful.@derived_dimension' href='#Unitful.@derived_dimension'>#</a>
**`Unitful.@derived_dimension`** &mdash; *Macro*.



```
macro derived_dimension(name, dims)
```

Creates type aliases to allow dispatch on [`Unitful.Quantity`](types.md#Unitful.Quantity) and [`Unitful.Units`](types.md#Unitful.Units) objects of a derived dimension, like area, which is just length squared. The type aliases are not exported.

`dims` is a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object.

Usage examples:

  * `@derived_dimension Area 𝐋^2` gives `Area` and `AreaUnit` type aliases
  * `@derived_dimension Speed 𝐋/𝐓` gives `Speed` and `SpeedUnit` type aliases


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/User.jl#L56-L71' class='documenter-source'>source</a><br>

<a id='Unitful.@refunit' href='#Unitful.@refunit'>#</a>
**`Unitful.@refunit`** &mdash; *Macro*.



```
macro refunit(symb, name, abbr, dimension, tf)
```

Define a reference unit, typically SI. Rather than define conversion factors between each and every unit of a given dimension, conversion factors are given between each unit and a reference unit, defined by this macro.

This macro extends [`Unitful.abbr`](display.md#Unitful.abbr) so that the reference unit can be displayed in an abbreviated format. If `tf == true`, this macro generates symbols for every power of ten of the unit, using the standard SI prefixes. A `dimension` must be given ([`Unitful.Dimensions`](types.md#Unitful.Dimensions) object) that specifies the dimension of the reference unit.

Usage example: `@refunit m "m" Meter 𝐋 true`

This example will generate `km`, `m`, `cm`, ...


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/User.jl#L81-L99' class='documenter-source'>source</a><br>

<a id='Unitful.@unit' href='#Unitful.@unit'>#</a>
**`Unitful.@unit`** &mdash; *Macro*.



```
macro unit(symb,abbr,name,equals,tf)
```

Define a unit. Rather than specifying a dimension like in [`@refunit`](newunits.md#Unitful.@refunit), `equals` should be a [`Unitful.Quantity`](types.md#Unitful.Quantity) equal to one of the unit being defined. If `tf == true`, symbols will be made for each power-of-ten prefix.

Usage example: `@unit mi "mi" Mile (201168//125)*m false`

This example will *not* generate `kmi` (kilomiles).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/User.jl#L112-L124' class='documenter-source'>source</a><br>

<a id='Unitful.preferunits' href='#Unitful.preferunits'>#</a>
**`Unitful.preferunits`** &mdash; *Function*.



```
function preferunits(u0::Units, u::Units...)
```

This function specifies the default fallback units for promotion. Units provided to this function must have a pure dimension of power 1, like 𝐋 or 𝐓 but not 𝐋/𝐓 or 𝐋^2. The function will complain if this is not the case. Additionally, the function will complain if you provide two units with the same dimension, as a courtesy to the user.

Once [`Unitful.upreferred`](manipulations.md#Unitful.upreferred) has been called or quantities have been promoted, this function will no longer work properly.

Usage example: `preferunits(u"m,s,A,K,cd,kg,mol"...)`


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/User.jl#L205-L220' class='documenter-source'>source</a><br>

<a id='Unitful.offsettemp' href='#Unitful.offsettemp'>#</a>
**`Unitful.offsettemp`** &mdash; *Function*.



```
offsettemp(::Unit)
```

For temperature units, this function is used to set the scale offset.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/Unitful.jl#L864-L870' class='documenter-source'>source</a><br>


<a id='Internals-1'></a>

## Internals

<a id='Unitful.@prefixed_unit_symbols' href='#Unitful.@prefixed_unit_symbols'>#</a>
**`Unitful.@prefixed_unit_symbols`** &mdash; *Macro*.



```
macro prefixed_unit_symbols(symb,name,dimension,basefactor)
```

Not called directly by the user. Given a unit symbol and a unit's name, will define units for each possible SI power-of-ten prefix on that unit.

Example: `@prefixed_unit_symbols m Meter 𝐋 (1.0,1)` results in nm, cm, m, km, ... all getting defined in the calling namespace.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/User.jl#L147-L157' class='documenter-source'>source</a><br>

<a id='Unitful.@unit_symbols' href='#Unitful.@unit_symbols'>#</a>
**`Unitful.@unit_symbols`** &mdash; *Macro*.



```
macro unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name, will define units without SI power-of-ten prefixes.

Example: `@unit_symbols ft Foot 𝐋` results in `ft` getting defined but not `kft`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/User.jl#L183-L192' class='documenter-source'>source</a><br>

<a id='Unitful.basefactor' href='#Unitful.basefactor'>#</a>
**`Unitful.basefactor`** &mdash; *Function*.



```
basefactor(x::Unit)
```

Specifies conversion factors to reference units. It returns a tuple. The first value is any irrational part of the conversion, and the second value is a rational component. This segregation permits exact conversions within unit systems that have no rational conversion to the reference units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/4dff77ea1e2efbb4a80488849882a36498d62b83/src/User.jl#L381-L391' class='documenter-source'>source</a><br>

