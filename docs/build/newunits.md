
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

Finally, a type alias is created that allows to dispatch on [`Unitful.Quantity`](types.md#Unitful.Quantity) objects of the newly defined dimension. The type alias symbol is given by `name`.

Usage example: `@dimension 𝐋 "L" Length` (see `src/Defaults.jl`.)


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/34085a079f619d84ee1ab2250377a406c9942fd6/src/User.jl#L1-L21' class='documenter-source'>source</a><br>

<a id='Unitful.@derived_dimension' href='#Unitful.@derived_dimension'>#</a>
**`Unitful.@derived_dimension`** &mdash; *Macro*.



```
macro derived_dimension(symb, dims)
```

Creates type aliases to allow dispatch on [`Unitful.Quantity`](types.md#Unitful.Quantity) objects of a derived dimension, like area, which is just length squared. The type aliases are not exported. `symb` is the name of the derived dimension and `dims` is a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object.

Usage examples:

  * `@derived_dimension Area 𝐋^2`
  * `@derived_dimension Speed 𝐋/𝐓`


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/34085a079f619d84ee1ab2250377a406c9942fd6/src/User.jl#L33-L47' class='documenter-source'>source</a><br>

<a id='Unitful.@refunit' href='#Unitful.@refunit'>#</a>
**`Unitful.@refunit`** &mdash; *Macro*.



```
macro refunit(symb, name, abbr, dimension)
```

Define a reference unit, typically SI. Rather than define conversion factors between each and every unit of a given dimension, conversion factors are given between each unit and a reference unit, defined by this macro.

This macro extends [`Unitful.abbr`](display.md#Unitful.abbr) so that the reference unit can be displayed in an abbreviated format. It also generates symbols for every power of ten of the unit, using the standard SI prefixes. A `dimension` must be given ([`Unitful.Dimensions`](types.md#Unitful.Dimensions) object) that specifies the dimension of the reference unit.

Usage example: `@refunit m "m" Meter 𝐋 true`

This will generate `km`, `m`, `cm`, ...


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/34085a079f619d84ee1ab2250377a406c9942fd6/src/User.jl#L55-L73' class='documenter-source'>source</a><br>

<a id='Unitful.@unit' href='#Unitful.@unit'>#</a>
**`Unitful.@unit`** &mdash; *Macro*.



```
macro unit(symb,abbr,name,equals,tf)
```

Define a unit. Rather than specifying a dimension like in [`@refunit`](newunits.md#Unitful.@refunit), `equals` should be a [`Unitful.Quantity`](types.md#Unitful.Quantity) equal to one of the unit being defined. The last argument `tf::Bool` should be `true` if symbols should be made for each power-of-ten prefix, otherwise `false`.

Usage example: `@unit mi "mi" Mile (201168//125)*m false`

This will *not* generate `kmi` (kilomiles).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/34085a079f619d84ee1ab2250377a406c9942fd6/src/User.jl#L88-L101' class='documenter-source'>source</a><br>

<a id='Unitful.offsettemp' href='#Unitful.offsettemp'>#</a>
**`Unitful.offsettemp`** &mdash; *Function*.



```
offsettemp(::Unit)
```

For temperature units, this function is used to set the scale offset.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/34085a079f619d84ee1ab2250377a406c9942fd6/src/Unitful.jl#L686-L692' class='documenter-source'>source</a><br>


<a id='Internals-1'></a>

## Internals

<a id='Unitful.@prefixed_unit_symbols' href='#Unitful.@prefixed_unit_symbols'>#</a>
**`Unitful.@prefixed_unit_symbols`** &mdash; *Macro*.



```
macro prefixed_unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name, will define units for each possible SI power-of-ten prefix on that unit.

Example: `@prefixed_unit_symbols m Meter` results in nm, cm, m, km, ... all getting defined in the calling namespace.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/34085a079f619d84ee1ab2250377a406c9942fd6/src/User.jl#L125-L135' class='documenter-source'>source</a><br>

<a id='Unitful.@unit_symbols' href='#Unitful.@unit_symbols'>#</a>
**`Unitful.@unit_symbols`** &mdash; *Macro*.



```
macro unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name, will define units without SI power-of-ten prefixes.

Example: `@unit_symbols ft Foot` results in `ft` getting defined but not `kft`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/34085a079f619d84ee1ab2250377a406c9942fd6/src/User.jl#L151-L160' class='documenter-source'>source</a><br>

<a id='Unitful.basefactor' href='#Unitful.basefactor'>#</a>
**`Unitful.basefactor`** &mdash; *Function*.



```
basefactor(x::Unit)
```

Specifies conversion factors to reference units. It returns a tuple. The first value is any irrational part of the conversion, and the second value is a rational component. This segregation permits exact conversions within unit systems that have no rational conversion to the reference units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/34085a079f619d84ee1ab2250377a406c9942fd6/src/User.jl#L232-L242' class='documenter-source'>source</a><br>

