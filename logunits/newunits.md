


<a id='Defining-new-units-1'></a>

# Defining new units


!!! note
    Logarithmic units cannot be defined by the user and should not be used in the `@refunit` or `@unit` macros described below. This limitation will likely be lifted eventually, but not until the interface for logarithmic units settles down.



The package automatically generates a useful set of units and dimensions in the `Unitful` module in `src/pkgdefaults.jl`.


If a different set of default units or dimensions is desired, macros for generating units and dimensions are provided. To create new units interactively, most users will be happy with the [`@unit`](newunits.md#Unitful.@unit) macro and the [`Unitful.register`](manipulations.md#Unitful.register) function, which makes units defined in a module available to the [`@u_str`](manipulations.md#Unitful.@u_str) string macro.


An example of defining units in a module:


```julia-repl
julia> module MyUnits; using Unitful; @unit myMeter "m" MyMeter 1u"m" false; end
MyUnits

julia> using Unitful

julia> u"myMeter"
ERROR: Symbol myMeter could not be found in registered unit modules.

julia> Unitful.register(MyUnits)
2-element Array{Module,1}:
 Unitful
 MyUnits

julia> u"myMeter"
m
```


You could have also called `Unitful.register` inside the `MyUnits` module; the choice is somewhat analogous to whether or not to export symbols from a module, although the symbols are never really exported, just made available to the `@u_str` macro. If you want to make a precompiled units package, rather than define a module at the REPL, see [Making your own units package](extending.md#Making-your-own-units-package-1).


You can also define units directly in the `Main` module at the REPL:


```julia-repl
julia> using Unitful

julia> Unitful.register(current_module());

julia> @unit M "M" Molar 1u"mol/L" true;

julia> 1u"mM"
1 mM
```


A note for the experts: Some care should be taken if explicitly creating [`Unitful.Units`](types.md#Unitful.Units) objects. The ordering of [`Unitful.Unit`](types.md#Unitful.Unit) objects inside a tuple matters for type comparisons. Using the unary multiplication operator on the `Units` object will return a "canonically sorted" `Units` object. Indeed, this is how we avoid ordering issues when multiplying quantities together.


<a id='Useful-functions-and-macros-1'></a>

## Useful functions and macros

<a id='Unitful.@dimension' href='#Unitful.@dimension'>#</a>
**`Unitful.@dimension`** &mdash; *Macro*.



```
@dimension(symb, abbr, name)
```

Creates new dimensions. `name` will be used like an identifier in the type parameter for a [`Unitful.Dimension`](types.md#Unitful.Dimension) object. `symb` will be a symbol defined in the namespace from which this macro is called that is bound to a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object. For most intents and purposes it is this object that the user would manipulate in doing dimensional analysis. The symbol is not exported.

This macro extends [`Unitful.abbr`](display.md#Unitful.abbr) to display the new dimension in an abbreviated format using the string `abbr`.

Type aliases are created that allow the user to dispatch on [`Unitful.Quantity`](types.md#Unitful.Quantity) and [`Unitful.Units`](types.md#Unitful.Units) objects of the newly defined dimension. The type alias for quantities is simply given by `name`, and the type alias for units is given by `name*"Units"`, e.g. `LengthUnits`. Note that there is also `LengthFreeUnits`, for example, which is an alias for dispatching on `FreeUnits` with length dimensions. The aliases are not exported.

Finally, if you define new dimensions with [`@dimension`](newunits.md#Unitful.@dimension) you will need to specify a preferred unit for that dimension with [`Unitful.preferunits`](conversion.md#Unitful.preferunits), otherwise promotion will not work with that dimension. This is done automatically in the [`@refunit`](newunits.md#Unitful.@refunit) macro.

Returns the `Dimensions` object to which `symb` is bound.

Usage example from `src/pkgdefaults.jl`: `@dimension 𝐋 "𝐋" Length`


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L22-L49' class='documenter-source'>source</a><br>

<a id='Unitful.@derived_dimension' href='#Unitful.@derived_dimension'>#</a>
**`Unitful.@derived_dimension`** &mdash; *Macro*.



```
@derived_dimension(name, dims)
```

Creates type aliases to allow dispatch on [`Unitful.Quantity`](types.md#Unitful.Quantity) and [`Unitful.Units`](types.md#Unitful.Units) objects of a derived dimension, like area, which is just length squared. The type aliases are not exported.

`dims` is a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object.

Returns `nothing`.

Usage examples:

  * `@derived_dimension Area 𝐋^2` gives `Area` and `AreaUnit` type aliases
  * `@derived_dimension Speed 𝐋/𝐓` gives `Speed` and `SpeedUnit` type aliases


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L67-L81' class='documenter-source'>source</a><br>

<a id='Unitful.@refunit' href='#Unitful.@refunit'>#</a>
**`Unitful.@refunit`** &mdash; *Macro*.



```
@refunit(symb, name, abbr, dimension, tf)
```

Define a reference unit, typically SI. Rather than define conversion factors between each and every unit of a given dimension, conversion factors are given between each unit and a reference unit, defined by this macro.

This macro extends [`Unitful.abbr`](display.md#Unitful.abbr) so that the reference unit can be displayed in an abbreviated format. If `tf == true`, this macro generates symbols for every power of ten of the unit, using the standard SI prefixes. A `dimension` must be given ([`Unitful.Dimensions`](types.md#Unitful.Dimensions) object) that specifies the dimension of the reference unit.

In principle, users can use this macro, but it probably does not make much sense to do so. If you define a new (probably unphysical) dimension using [`@dimension`](newunits.md#Unitful.@dimension), then this macro will be necessary. With existing dimensions, you will almost certainly cause confusion if you use this macro. One potential use case would be to define a unit system without reference to SI. However, there's no explicit barrier to prevent attempting conversions between SI and this hypothetical unit system, which could yield unexpected results.

Note that this macro will also choose the new unit (no power-of-ten prefix) as the default unit for promotion given this dimension.

Returns the [`Unitful.FreeUnits`](types.md#Unitful.FreeUnits) object to which `symb` is bound.

Usage example: `@refunit m "m" Meter 𝐋 true`

This example, found in `src/pkgdefaults.jl`, generates `km`, `m`, `cm`, ...


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L96-L124' class='documenter-source'>source</a><br>

<a id='Unitful.@unit' href='#Unitful.@unit'>#</a>
**`Unitful.@unit`** &mdash; *Macro*.



```
@unit(symb,abbr,name,equals,tf)
```

Define a unit. Rather than specifying a dimension like in [`@refunit`](newunits.md#Unitful.@refunit), `equals` should be a [`Unitful.Quantity`](types.md#Unitful.Quantity) equal to one of the unit being defined. If `tf == true`, symbols will be made for each power-of-ten prefix.

Returns the [`Unitful.FreeUnits`](types.md#Unitful.FreeUnits) object to which `symb` is bound.

Usage example: `@unit mi "mi" Mile (201168//125)*m false`

This example will *not* generate `kmi` (kilomiles).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L139-L150' class='documenter-source'>source</a><br>

<a id='Unitful.offsettemp' href='#Unitful.offsettemp'>#</a>
**`Unitful.offsettemp`** &mdash; *Function*.



```
offsettemp(::Unit)
```

For temperature units, this function is used to set the scale offset.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/temperature.jl#L1-L4' class='documenter-source'>source</a><br>


<a id='Internals-1'></a>

## Internals

<a id='Unitful.@prefixed_unit_symbols' href='#Unitful.@prefixed_unit_symbols'>#</a>
**`Unitful.@prefixed_unit_symbols`** &mdash; *Macro*.



```
@prefixed_unit_symbols(symb,name,dimension,basefactor)
```

Not called directly by the user. Given a unit symbol and a unit's name, will define units for each possible SI power-of-ten prefix on that unit.

Example: `@prefixed_unit_symbols m Meter 𝐋 (1.0,1)` results in nm, cm, m, km, ... all getting defined in the calling namespace.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L172-L179' class='documenter-source'>source</a><br>

<a id='Unitful.@unit_symbols' href='#Unitful.@unit_symbols'>#</a>
**`Unitful.@unit_symbols`** &mdash; *Macro*.



```
@unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name, will define units without SI power-of-ten prefixes.

Example: `@unit_symbols ft Foot 𝐋` results in `ft` getting defined but not `kft`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L205-L211' class='documenter-source'>source</a><br>

<a id='Unitful.basefactor' href='#Unitful.basefactor'>#</a>
**`Unitful.basefactor`** &mdash; *Function*.



```
basefactor(x::Unit)
```

Specifies conversion factors to reference units. It returns a tuple. The first value is any irrational part of the conversion, and the second value is a rational component. This segregation permits exact conversions within unit systems that have no rational conversion to the reference units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L382-L389' class='documenter-source'>source</a><br>

