


<a id='Converting-between-units-1'></a>

## Converting between units


Since `convert` in Julia already means something specific (conversion between Julia types), we define [`uconvert`](conversion.md#Unitful.uconvert) for conversion between units. Typically this will also involve a conversion between types, but this function takes care of figuring out which type is appropriate for representing the desired units.


Exact conversions between units are respected where possible. If rational arithmetic would result in an overflow, then floating-point conversion should proceed. Use of floating-point numbers inhibits exact conversion.

<a id='Unitful.uconvert' href='#Unitful.uconvert'>#</a>
**`Unitful.uconvert`** &mdash; *Function*.



```
uconvert{T,D,U}(a::Units, x::Quantity{T,D,U})
```

Convert a [`Unitful.Quantity`](types.md#Unitful.Quantity) to different units. The conversion will fail if the target units `a` have a different dimension than the dimension of the quantity `x`. You can use this method to switch between equivalent representations of the same unit, like `N m` and `J`.

Example:

```julia-repl
julia> uconvert(u"hr",3602u"s")
1801//1800 hr
julia> uconvert(u"J",1.0u"N*m")
1.0 J
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/conversion.jl#L1-L16' class='documenter-source'>source</a><br>


```
uconvert{T,D,U}(a::Units, x::Quantity{T,typeof(𝚯),<:TemperatureUnits})
```

In this method, we are special-casing temperature conversion to respect scale offsets, if they do not appear in combination with other dimensions.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/temperature.jl#L7-L11' class='documenter-source'>source</a><br>


Since objects are callable, we can also make [`Unitful.Units`](types.md#Unitful.Units) callable with a `Number` as an argument, for a unit conversion shorthand:


```julia-repl
julia> u"cm"(1u"m")
100//1 cm
```


This syntax is a little confusing, but becomes appealing with the function chaining operator `|>`:


```julia-repl
julia> 1u"m" |> u"cm"
100//1 cm
```


Note that since [`Unitful.Units`](types.md#Unitful.Units) objects have no fields, we don't have to worry about ambiguity with constructor calls. This way of converting units results in behavior identical to calling [`uconvert`](conversion.md#Unitful.uconvert).


<a id='Dimensionless-quantities-1'></a>

### Dimensionless quantities


For dimensionless quantities, `uconvert` can be used to strip the units without losing power-of-ten information:


```julia-repl
julia> uconvert(Unitful.NoUnits, 1.0u"μm/m")
1.0e-6

julia> uconvert(Unitful.NoUnits, 1.0u"m")
ERROR: DimensionError:  and m are not dimensionally compatible.
```


You can also directly convert to a subtype of `Real` or `Complex`:


```julia-repl
julia> Float64(1.0u"μm/m")
1.0e-6
```


<a id='Temperature-conversion-1'></a>

### Temperature conversion


If the dimension of a `Quantity` is purely temperature, then conversion respects scale offsets. For instance, converting 0°C to °F returns the expected result, 32°F. If instead temperature appears in combination with other units, scale offsets don't make sense and we consider temperature *intervals*.


```julia-repl
julia> uconvert(u"K", 21.0u"°C")
294.15 K
```


<a id='Basic-promotion-mechanisms-1'></a>

## Basic promotion mechanisms


We decide the result units for addition and subtraction operations based on looking at the types only. We can't take runtime values into account without compromising runtime performance.


If two quantities with the same units are added or subtracted, then the result units will be the same. If two quantities with differing units (but same dimension) are added or subtracted, then the result units will be specified by promotion.


<a id='Promotion-rules-for-specific-dimensions-1'></a>

### Promotion rules for specific dimensions


You can specify the result units for promoting quantities of a specific dimension once at the start of a Julia session, specifically *before* `upreferred` *has been called or quantities have been promoted*. For example, you can specify that when promoting two quantities with different energy units, the resulting quantities should be in `g*cm^2/s^2`. This is accomplished by defining a `Unitful.promote_unit` method for the units themselves. Here's an example.


```julia-repl
julia> using Unitful

julia> Unitful.promote_unit{S<:Unitful.EnergyUnits, T<:Unitful.EnergyUnits}(::S, ::T) = u"g*cm^2/s^2"

julia> promote(2.0u"J", 1.0u"kg*m^2/s^2")
(2.0e7 g cm^2 s^-2, 1.0e7 g cm^2 s^-2)

julia> Unitful.promote_unit{S<:Unitful.EnergyUnits, T<:Unitful.EnergyUnits}(::S, ::T) = u"J"

julia> promote(2.0u"J", 1.0u"kg*m^2/s^2")
(2.0e7 g cm^2 s^-2, 1.0e7 g cm^2 s^-2)
```


Notice how the first definition of `Base.promote_rule` had a permanent effect. This is true of promotion rules for types defined in Base too; try defining a new promotion rule for `Int` and `Float64` and you'll see it has no effect.


If you're wondering where `Unitful.EnergyUnit` comes from, it is defined in `src/pkgdefaults.jl` by the [`@derived_dimension`](newunits.md#Unitful.@derived_dimension) macro. Similarly, the calls to the [`@dimension`](newunits.md#Unitful.@dimension) macro define `Unitful.LengthUnit`, `Unitful.MassUnit`, etc. None of these are exported.


Existing users of Unitful may want to call [`Unitful.promote_to_derived`](conversion.md#Unitful.promote_to_derived) after Unitful loads to give similar behavior to Unitful 0.0.4 and below. It is not called by default.

<a id='Unitful.promote_to_derived' href='#Unitful.promote_to_derived'>#</a>
**`Unitful.promote_to_derived`** &mdash; *Function*.



```
Unitful.promote_to_derived()
```

Defines promotion rules to use derived SI units in promotion for common dimensions of quantities:

  * `J` (joule) for energy
  * `N` (newton) for force
  * `W` (watt) for power
  * `Pa` (pascal) for pressure
  * `C` (coulomb) for charge
  * `V` (volt) for voltage
  * `Ω` (ohm) for resistance
  * `F` (farad) for capacitance
  * `H` (henry) for inductance
  * `Wb` (weber) for magnetic flux
  * `T` (tesla) for B-field
  * `J*s` (joule-second) for action

If you want this as default behavior (it was for versions of Unitful prior to 0.1.0), consider invoking this function in your `.juliarc.jl` file which is loaded when you open Julia. This function is not exported.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/pkgdefaults.jl#L203-L224' class='documenter-source'>source</a><br>


<a id='Fallback-promotion-rules-1'></a>

### Fallback promotion rules


The [`Unitful.preferunits`](conversion.md#Unitful.preferunits) function is used to designate fallback preferred units for each pure dimension for promotion. Such a fallback is required because you need some generic logic to take over when manipulating quantities with arbitrary dimensions.


The default behavior is to promote to a combination of the base SI units, i.e. a quantity of dimension `𝐌*𝐋^2/(𝐓^2*𝚯)` would be converted to `kg*m^2/(s^2*K)`:


```julia-repl
julia> promote(1.0u"J/K", 1.0u"g*cm^2/s^2/K")
(1.0 kg K^-1 m^2 s^-2, 1.0e-7 kg K^-1 m^2 s^-2)
```


You can however override this behavior by calling [`Unitful.preferunits`](conversion.md#Unitful.preferunits) at the start of a Julia session, specifically *before* `upreferred` *has been called or quantities have been promoted*.

<a id='Unitful.preferunits' href='#Unitful.preferunits'>#</a>
**`Unitful.preferunits`** &mdash; *Function*.



```
preferunits(u0::Units, u::Units...)
```

This function specifies the default fallback units for promotion. Units provided to this function must have a pure dimension of power 1, like 𝐋 or 𝐓 but not 𝐋/𝐓 or 𝐋^2. The function will complain if this is not the case. Additionally, the function will complain if you provide two units with the same dimension, as a courtesy to the user.

Once [`Unitful.upreferred`](@ref) has been called or quantities have been promoted, this function will appear to have no effect.

Usage example: `preferunits(u"m,s,A,K,cd,kg,mol"...)`


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L222-L234' class='documenter-source'>source</a><br>


<a id='Array-promotion-1'></a>

### Array promotion


Arrays are typed with as much specificity as possible upon creation. consider the following three cases:


```julia-repl
julia> [1.0u"m", 2.0u"m"]
2-element Array{Quantity{Float64, Dimensions:{𝐋}, Units:{m}},1}:
 1.0 m
 2.0 m

julia> [1.0u"m", 2.0u"cm"]
2-element Array{Quantity{Float64, Dimensions:{𝐋}, Units:{m}},1}:
  1.0 m
 0.02 m

julia> [1.0u"m", 2.0]
2-element Array{Unitful.Quantity{Float64,D,U} where U where D,1}:
 1.0 m
   2.0
```


In the first case, an array with a concrete type is created. Good performance should be attainable. The second case invokes promotion so that an array of concrete type can be created. The third case falls back to an abstract type, which cannot be stored efficiently and will incur a performance penalty. An additional benefit of having a concrete type is that we can dispatch on the dimensions of the array's elements:


```julia-repl
julia> f{T<:Unitful.Length}(x::AbstractArray{T}) = sum(x)
f (generic function with 1 method)

julia> f([1.0u"m", 2.0u"cm"])
1.02 m

julia> f([1.0u"g", 2.0u"cm"])
ERROR: MethodError: no method matching f(::Array{Unitful.Quantity{Float64,D,U} where U where D,1})
```


<a id='Advanced-promotion-mechanisms-1'></a>

## Advanced promotion mechanisms


There are some new types as of Unitful.jl v0.2.0 that enable some fairly sophisticated promotion logic. Three concrete subtypes of [`Unitful.Units{N,D}`](types.md#Unitful.Units) are defined: [`Unitful.FreeUnits{N,D}`](types.md#Unitful.FreeUnits), [`Unitful.ContextUnits{N,D,P}`](types.md#Unitful.ContextUnits), and [`Unitful.FixedUnits{N,D}`](types.md#Unitful.FixedUnits).


Units defined in the Unitful.jl package itself are all `Unitful.FreeUnits{N,D}` objects. The "free" in `FreeUnits` indicates that the object carries no information on its own about how it should respond during promotion. Other code in Unitful dictates that by default, quantities should promote to SI units. `FreeUnits` use the promotion mechanisms described in the above section, [Basic promotion mechanisms](conversion.md#Basic-promotion-mechanisms-1). They used to be called `Units` in prior versions of Unitful.


<a id='ContextUnits-1'></a>

### ContextUnits


Sometimes, a package may want to default to a particular behavior for promotion, in the presence of other packages that may require differing default behaviors. An example would be a CAD package for nanoscale device design: it makes more sense to promote to nanometers or microns than to meters. For this purpose we define `Unitful.ContextUnits{N,D,P}`. The `P` in this type signature should be some type `Unitful.FreeUnits{M,D}` (the dimensions must be the same). We refer to this as the "context." `ContextUnits` may be easily instantiated by e.g. `ContextUnits(nm, μm)` for a `nm` unit that will promote to `μm`. Here's an example:


```julia-repl
julia> μm = Unitful.ContextUnits(u"μm", u"μm")
μm

julia> nm = Unitful.ContextUnits(u"nm", u"μm")
nm

julia> 1.0μm + 1.0nm
1.001 μm
```


If the context does not agree, then we fall back to `FreeUnits`:


```julia-repl
julia> μm = Unitful.ContextUnits(u"μm", u"μm")
μm

julia> nm = Unitful.ContextUnits(u"nm", u"cm")
nm

julia> 1.0μm + 1.0nm
1.001e-6 m
```


Multiplying a `ContextUnits` by a `FreeUnits` yields a `ContextUnits` object, with the preferred units for the additional dimensions being determined by calling [`upreferred`](@ref) on the `FreeUnits` object:


```julia-repl
julia> mm = Unitful.ContextUnits(u"mm", u"μm")
mm

julia> isa(u"g", Unitful.FreeUnits)
true

julia> upreferred(u"g")
kg

julia> mm*u"g"
g mm

julia> isa(mm*u"g", Unitful.ContextUnits)
true

julia> upreferred(mm*u"g")
kg μm
```


<a id='FixedUnits-1'></a>

### FixedUnits


Sometimes, there may be times where it is required to disable automatic conversion between quantities with different units. For this purpose there are `Unitful.FixedUnits{N,D}`. Trying to add or compare two quantities with `FixedUnits` will throw an error, provided the units are not the same. Note that you can still add/compare a quantity with `FixedUnits` to a quantity with another kind of units; in that case, the result units (if applicable) are determined by the `FixedUnits`, overriding the preferred units from `ContextUnits` or `FreeUnits`. Multiplying `FixedUnits` with any other kind of units returns `FixedUnits`:


```julia-repl
julia> mm_fix = Unitful.FixedUnits(u"mm")
mm

julia> cm_fix = Unitful.FixedUnits(u"cm")
cm

julia> 1mm_fix+2mm_fix
3 mm

julia> 1mm_fix+2u"cm"  # u"cm" is a FreeUnits object.
21//1 mm

julia> 1mm_fix+2*Unitful.ContextUnits(u"cm", u"cm")
21//1 mm

julia> isa(mm_fix*u"cm", Unitful.FixedUnits)
true

julia> 1mm_fix+2cm_fix
ERROR: automatic conversion prohibited.
[...]

julia> 1mm_fix == 1mm_fix
true

julia> 1mm_fix == 0.1u"cm"
true

julia> 1mm_fix == 0.1cm_fix
ERROR: automatic conversion prohibited.
[...]
```


Much of this functionality is enabled by `promote_unit` definitions. These are not readily extensible by the user at this point.

<a id='Unitful.promote_unit' href='#Unitful.promote_unit'>#</a>
**`Unitful.promote_unit`** &mdash; *Function*.



```
promote_unit(::Units, ::Units...)
```

Given `Units` objects as arguments, this function returns a `Units` object appropriate for the result of promoting quantities which have these units. This function is kind of like `promote_rule`, except that it doesn't take types. It also does not return a tuple, but rather just a [`Unitful.Units`](types.md#Unitful.Units) object (or it throws an error).

Although we had used `promote_rule` for `Units` objects in prior versions of Unitful, this was always kind of a hack; it doesn't make sense to promote units directly for a variety of reasons.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/promotion.jl#L1-L11' class='documenter-source'>source</a><br>


<a id='Unit-cancellation-1'></a>

## Unit cancellation


For multiplication and division, note that powers-of-ten prefixes are significant in unit cancellation. For instance, `mV/V` is not simplified, although `V/V` is. Also, `N*m/J` is not simplified: there is currently no logic to decide whether or not units on a dimensionless quantity seem "intentional" or not.

