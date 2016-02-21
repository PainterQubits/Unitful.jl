# Unitful.jl

A Julia package for physical units. Available
[here](https://github.com/ajkeller34/Unitful.jl). Inspired by Keno Fischer's
very clever package [SIUnits.jl](https://github.com/keno/SIUnits.jl).

We want to support not only SI units but also any other unit system. We also
want to minimize or in some cases eliminate the run-time penalty of units.
There should be facilities for dimensional analysis.
All of this should integrate easily with the usual mathematical operations
and collections that are found in Julia base.

## Features

- Support for rational exponents. Good for power spectral density, etc.
- “Sticky units”: by default, no implicit conversions in multiplication or division
    - We allow for implicit conversions in addition and subtraction
- Some built-in dimensional analysis
- Support for various `Range` types, including `LinSpace`

## Quick start

### Installation

+ Use a recent nightly build of Julia 0.5.

+ `Pkg.clone("https://github.com/ajkeller34/Unitful.jl.git")`

### In Julia

```jl
using Unitful
```

*Cautiously disregard the several warnings about overwriting methods in Base,
which are expected.*

By default, SI units and their power-of-ten prefixes are exported. Other units
are exported but not power-of-ten prefixes.

- `m`, `km`, `cm`, etc. are exported.
- `nft` for nano-foot is not exported.

Some unit abbreviations conflict with Julia definitions or syntax:

- `inch` is used instead of `in`
- `minute` is used instead of `min`

### Usage examples

```jl

# The following are true:
1kg == 1000g                    # Equivalence implies unit conversion
!(1kg === 1000g)                # ...and yet we can distinguish these...
1kg === 1kg                     # ...and these are indistinguishable.

# Also true:
unit(convert(°C, 212°F)) === °C
unitless(convert(°C, 212°F)) ≈ 100
# Note: use the \approx tab-completion. Sometimes ≈ is needed if there are tiny
# floating-point errors (see to-do list note, regarding exact conversions)

# Also true:
convert(µm/(m*°F), 9µm/(m*°C)) ≈ 5µm/(m*°F)
mod(1h+3minute+5s, 24s) == 17s

linspace(1m, 100m, 20)
# 20-element LinSpace{Unitful.FloatQuantity{Float64,Unitful.UnitData{(m,)}}}:
# 1.0 m, 6.21053 m, ...
```

See `test/runtests.jl` for more usage examples.

## Testing this package

There are of course subtleties in getting this all to work. To test that
changes to either Julia or Unitful haven't given rise to undesirable behavior,
run the test suite in Julia:
```jl
cd(Pkg.dir("Unitful"))
include("test/runtests.jl")
```

## To do

- Clean up how units/quantities are displayed.
I'm waiting on `show`, `print`, etc.
to be cleaned up before I work on this myself (see [issue #14052](https://github.com/JuliaLang/julia/issues/14052) and others).

- ~Respect exact conversions: Right now if we convert 12 inches to feet the result
is unnecessarily floating-point based. In whole or part this is because of the method
`basefactor(x::UnitDatum)`: right now there is an explicit floating point
conversion.~ 

- Clean up sin(degrees), etc. (not done nicely)

- Add more units (easy pull request for someone interested)

- Benchmarking needed!

- More tests would be nice

- Add support for uncertainties? For quantities with uncertainty, `isapprox`
becomes a loaded / ambiguous name.
