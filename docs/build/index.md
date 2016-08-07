
<a id='Unitful.jl-1'></a>

# Unitful.jl


A Julia package for physical units. Available [here](https://github.com/ajkeller34/Unitful.jl). Inspired by Keno Fischer's very clever package [SIUnits.jl](https://github.com/keno/SIUnits.jl).


We want to support not only SI units but also any other unit system. We also want to minimize or in some cases eliminate the run-time penalty of units. There should be facilities for dimensional analysis. All of this should integrate easily with the usual mathematical operations and collections that are found in Julia base.


<a id='Features-1'></a>

## Features


  * Dispatch on dimensions: `radius(x::Area) = sqrt(x/π)`, etc.
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
Unitful.defaults()
```


By default, SI units and their power-of-ten prefixes are given. Other units are exported but not power-of-ten prefixes.


  * `m`, `km`, `cm`, etc. are exported.
  * `nft` for nano-foot is not exported.


Some unit abbreviations conflict with Julia definitions or syntax:


  * `inch` is used instead of `in`
  * `minute` is used instead of `min`


<a id='Usage-examples-1'></a>

### Usage examples


```jl

# The following are true:
1kg == 1000g                    # Equivalence implies unit conversion
!(1kg === 1000g)                # ...and yet we can distinguish these...
1kg === 1kg                     # ...and these are indistinguishable.

# Also true:
unit(convert(°C, 212°F)) === °C
unitless(convert(°C, 212°F)) == 100
# Note: use the \approx tab-completion. Sometimes ≈ is needed if there are tiny
# floating-point errors (see to-do list note, regarding exact conversions)

# Also true:
convert(µm/(m*°F), 9µm/(m*°C)) ≈ 5µm/(m*°F)
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

