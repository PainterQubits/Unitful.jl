
<a id='Unitful.jl-1'></a>

# Unitful.jl


A Julia package for physical units. Available [here](https://github.com/ajkeller34/Unitful.jl). Inspired by:


  * [SIUnits.jl](https://github.com/keno/SIUnits.jl)
  * [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
  * [Units.jl](https://github.com/timholy/Units.jl)


We want to support not only SI units but also any other unit system. We also want to minimize or in some cases eliminate the run-time penalty of units. There should be facilities for dimensional analysis. All of this should integrate easily with the usual mathematical operations and collections that are found in Julia base.


<a id='Features-1'></a>

## Features


  * Dispatch on dimensions: `radius(x::Unitful.Area) = sqrt(x/π)`, etc.
  * Support for rational exponents. Good for power spectral density, etc.
  * Exact conversions are respected by using Rationals.
  * Can make new units using the `@unit` macro without digging through the code.
  * “Sticky units”: by default, no implicit conversions in multiplication or division   - We allow for implicit conversions in addition and subtraction
  * Some built-in dimensional analysis


<a id='Quick-start-1'></a>

## Quick start


<a id='Installation-1'></a>

### Installation


  * This package requires Julia 0.5. Older versions will not be supported.
  * `Pkg.clone("https://github.com/ajkeller34/Unitful.jl.git")`


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


Some unit abbreviations conflict with Julia definitions or syntax:


  * `inch` is used instead of `in`
  * `minute` is used instead of `min`


Units, dimensions, and fundamental constants are not exported from Unitful. This is to avoid proliferating symbols in your namespace unnecessarily. You can retrieve them using the [`@u_str`](manipulations.md#Unitful.@u_str) string macro for convenience.


<a id='Usage-examples-1'></a>

### Usage examples


```jl

1u"kg" == 1000u"g"                    # Equivalence implies unit conversion
!(1u"kg" === 1000u"g")                # ...and yet we can distinguish these...
1u"kg" === 1u"kg"                     # ...and these are indistinguishable.

# In the next examples let's bring some units into our namespace:

°C = u"°C"
°F = u"°F"
μm = u"μm"
m = u"m"
h = u"h"
minute = u"minute"
s = u"s"

# Also true:
unit(convert(°C, 212°F)) === °C
unitless(convert(°C, 212°F)) == 100
# Note: use the \approx tab-completion. Sometimes ≈ is needed if there are tiny
# floating-point errors (see to-do list note, regarding exact conversions)

# Also true:
convert(μm/(m*°F), 9μm/(m*°C)) ≈ 5μm/(m*°F)
mod(1h+3minute+5s, 24s) == 17s
```


See `test/runtests.jl` for more usage examples.


<a id='Gotchas-1'></a>

### Gotchas


One inch is exactly equal to 2.54 cm. However, in Julia, the floating-point 2.54 is not equal to the Rational 254//100. As a consequence, `1inch != 2.54cm`, because Unitful respects exact conversions and 1 inch is really 254//100 cm. To test for equivalence, instead use `≈` (backslash approx tab-completion).


The above applies generically to any pair of units, not just inches and centimeters.


<a id='To-do-1'></a>

## To do


  * Clean up how units/quantities are displayed.
  * Clean up `sin(degrees)`, etc. (not done nicely)
  * Benchmarking needed.
  * More tests are always appreciated and necessary.
  * Add support for uncertainties? For quantities with uncertainty, `isapprox` becomes a loaded / ambiguous name.

