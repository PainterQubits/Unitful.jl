
<a id='Defining-new-units-1'></a>

# Defining new units


The package automatically generates a useful set of units and dimensions in the `Unitful` module in `src/pkgdefaults.jl`.


If a different set of default units or dimensions is desired, macros for generating units and dimensions are provided. To create new units interactively, most users will be happy with the [`@unit`](newunits.md#Unitful.@unit) macro.


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

Type aliases are created that allow the user to dispatch on [`Unitful.Quantity`](types.md#Unitful.Quantity) and [`Unitful.Units`](types.md#Unitful.Units) objects of the newly defined dimension. The type alias for quantities is simply given by `name`, and the type alias for units is given by `name*"Unit"`, e.g. `LengthUnit`.

Finally, if you define new dimensions with [`@dimension`](newunits.md#Unitful.@dimension) you will need to specify a preferred unit for that dimension with [`Unitful.preferunits`](conversion.md#Unitful.preferunits), otherwise promotion will not work with that dimension.

Usage example from `src/pkgdefaults.jl`: `@dimension 𝐋 "L" Length`


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/bf0bb83e82f4b1bac8ed249c4fb8ab986d568100/src/User.jl#L23-L48' class='documenter-source'>source</a><br>

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


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/bf0bb83e82f4b1bac8ed249c4fb8ab986d568100/src/User.jl#L61-L76' class='documenter-source'>source</a><br>

<a id='Unitful.@refunit' href='#Unitful.@refunit'>#</a>
**`Unitful.@refunit`** &mdash; *Macro*.



```
macro refunit(symb, name, abbr, dimension, tf)
```

Define a reference unit, typically SI. Rather than define conversion factors between each and every unit of a given dimension, conversion factors are given between each unit and a reference unit, defined by this macro.

This macro extends [`Unitful.abbr`](display.md#Unitful.abbr) so that the reference unit can be displayed in an abbreviated format. If `tf == true`, this macro generates symbols for every power of ten of the unit, using the standard SI prefixes. A `dimension` must be given ([`Unitful.Dimensions`](types.md#Unitful.Dimensions) object) that specifies the dimension of the reference unit.

In principle, users can use this macro, but it probably does not make much sense to do so. If you define a new (probably unphysical) dimension using [`@dimension`](newunits.md#Unitful.@dimension), then this macro will be necessary. With existing dimensions, you will almost certainly cause confusion if you use this macro. One potential use case would be to define a unit system without reference to SI. However, there's no explicit barrier to prevent attempting conversions between SI and this hypothetical unit system, which could yield unexpected results.

Usage example: `@refunit m "m" Meter 𝐋 true`

This example, found in `src/pkgdefaults.jl`, generates `km`, `m`, `cm`, ...


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/bf0bb83e82f4b1bac8ed249c4fb8ab986d568100/src/User.jl#L86-L112' class='documenter-source'>source</a><br>

<a id='Unitful.@unit' href='#Unitful.@unit'>#</a>
**`Unitful.@unit`** &mdash; *Macro*.



```
macro unit(symb,abbr,name,equals,tf)
```

Define a unit. Rather than specifying a dimension like in [`@refunit`](newunits.md#Unitful.@refunit), `equals` should be a [`Unitful.Quantity`](types.md#Unitful.Quantity) equal to one of the unit being defined. If `tf == true`, symbols will be made for each power-of-ten prefix.

Usage example: `@unit mi "mi" Mile (201168//125)*m false`

This example will *not* generate `kmi` (kilomiles).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/bf0bb83e82f4b1bac8ed249c4fb8ab986d568100/src/User.jl#L125-L137' class='documenter-source'>source</a><br>

<a id='Unitful.offsettemp' href='#Unitful.offsettemp'>#</a>
**`Unitful.offsettemp`** &mdash; *Function*.



```
offsettemp(::Unit)
```

For temperature units, this function is used to set the scale offset.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/bf0bb83e82f4b1bac8ed249c4fb8ab986d568100/src/Unitful.jl#L916-L922' class='documenter-source'>source</a><br>


<a id='Internals-1'></a>

## Internals

<a id='Unitful.@prefixed_unit_symbols' href='#Unitful.@prefixed_unit_symbols'>#</a>
**`Unitful.@prefixed_unit_symbols`** &mdash; *Macro*.



```
macro prefixed_unit_symbols(symb,name,dimension,basefactor)
```

Not called directly by the user. Given a unit symbol and a unit's name, will define units for each possible SI power-of-ten prefix on that unit.

Example: `@prefixed_unit_symbols m Meter 𝐋 (1.0,1)` results in nm, cm, m, km, ... all getting defined in the calling namespace.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/bf0bb83e82f4b1bac8ed249c4fb8ab986d568100/src/User.jl#L158-L168' class='documenter-source'>source</a><br>

<a id='Unitful.@unit_symbols' href='#Unitful.@unit_symbols'>#</a>
**`Unitful.@unit_symbols`** &mdash; *Macro*.



```
macro unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name, will define units without SI power-of-ten prefixes.

Example: `@unit_symbols ft Foot 𝐋` results in `ft` getting defined but not `kft`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/bf0bb83e82f4b1bac8ed249c4fb8ab986d568100/src/User.jl#L194-L203' class='documenter-source'>source</a><br>

<a id='Unitful.basefactor' href='#Unitful.basefactor'>#</a>
**`Unitful.basefactor`** &mdash; *Function*.



```
basefactor(x::Unit)
```

Specifies conversion factors to reference units. It returns a tuple. The first value is any irrational part of the conversion, and the second value is a rational component. This segregation permits exact conversions within unit systems that have no rational conversion to the reference units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/bf0bb83e82f4b1bac8ed249c4fb8ab986d568100/src/User.jl#L383-L393' class='documenter-source'>source</a><br>

