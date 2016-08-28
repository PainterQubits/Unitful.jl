


<a id='Unitful.jl-1'></a>

# Unitful.jl


A Julia package for physical units. Available [here](https://github.com/ajkeller34/Unitful.jl). Inspired by:


  * [SIUnits.jl](https://github.com/keno/SIUnits.jl)
  * [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
  * [Units.jl](https://github.com/timholy/Units.jl)


We want to support not only SI units but also any other unit system. We also want to minimize or in some cases eliminate the run-time penalty of units. There should be facilities for dimensional analysis. All of this should integrate easily with the usual mathematical operations and collections that are found in Julia base.


<a id='Features-1'></a>

## Features


  * Can dispatch on dimensions. Consider the following conversion from voltage or power ratios to decibels (for given ratio `num/den`):


```
Unitful.dB(num::Unitful.Voltage, den::Unitful.Voltage) = 20*log10(num/den)
Unitful.dB(num::Unitful.Power, den::Unitful.Power) = 10*log10(num/den)
```


```jlcon
julia> Unitful.dB(1u"mV", 1u"V")
-60.0
julia> Unitful.dB(1u"mW", 1u"W")
-30.0
```


  * Units may have rational exponents.
  * Arrays can hold quantities with different units or even different dimensions. This is done efficiently using the [`Unitful.AbstractQuantity{T}`](types.md#Unitful.AbstractQuantity) type.
  * Exact conversions are respected by using `Rational`s where possible.
  * Can make new units using the `@unit` macro without digging through the code.
  * Units are sticky. Although `1.0 J` and `1.0 N m` are equivalent quantities, they are represented distinctly, so further manipulations on `1.0 J` can leave the `J` intact. Furthermore, units are only canceled out if they are exactly the same, including power-of-ten prefixes. `1.0 mV/V` is possible.
  * Some built-in dimensional analysis.


<a id='Quick-start-1'></a>

## Quick start


<a id='Installation-1'></a>

### Installation


  * This package requires Julia 0.5. Older versions will not be supported.
  * `Pkg.clone("https://github.com/ajkeller34/Unitful.jl.git")`
  * `Pkg.build("Unitful")`


<a id='In-Julia-1'></a>

### In Julia


First load the package:


```jl
using Unitful
```


If you encounter errors you may want to try `Pkg.build("Unitful")`.


In `deps/Defaults.jl` of the package directory, you see what is defined by default. Feel free to edit this file to suit your needs. The Unitful package will need to be reloaded for changes to take place.


Here is a summary of the defaults:


  * SI units and their power-of-ten prefixes are defined.
  * Some other units (imperial units) are defined, without power-of-ten prefixes.
  * Dimensions are also defined.


Some unit abbreviations conflict with other definitions or syntax:


  * `inch` is used instead of `in`, since `in` conflicts with Julia syntax
  * `minute` is used instead of `min`, since `min` is a commonly used function
  * `hr` is used instead of `h`, since `h` is revered as the Planck constant


<a id='Usage-examples-1'></a>

### Usage examples


Units, dimensions, and fundamental constants are not exported from Unitful. This is to avoid proliferating symbols in your namespace unnecessarily. You can retrieve them using the [`@u_str`](manipulations.md#Unitful.@u_str) string macro for convenience, or import them from the `Unitful` package to bring them into the namespace.




```jlcon
julia> 1u"kg" == 1000u"g"             # Equivalence implies unit conversion
true

julia> !(1u"kg" === 1000u"g")         # ...and yet we can distinguish these...
true

julia> 1u"kg" === 1u"kg"              # ...and these are indistinguishable.
true
```


In the next examples we assume we have brought some units into our namespace, e.g. using `m = u"m"`, etc.


```jlcon
julia> uconvert(°C, 212°F)
100//1 °C

julia> uconvert(μm/(m*°F), 9μm/(m*°C))
5//1 °F^-1 μm m^-1

julia> mod(1hr+3minute+5s, 24s)
17//1 s
```


See `test/runtests.jl` for more usage examples.


<a id='To-do-1'></a>

## To do


  * Clean up how units/quantities are displayed.
  * Clean up `sin(degrees)`, etc. (not done nicely)
  * Benchmarking needed.
  * More tests are always appreciated and necessary.
  * Add support for uncertainties? For quantities with uncertainty, `isapprox` becomes a loaded / ambiguous name.

