```@meta
DocTestSetup = quote
    using Unitful
end
```
# Unitful.jl

A Julia package for physical units. Available
[here](https://github.com/ajkeller34/Unitful.jl). Inspired by:

- [SIUnits.jl](https://github.com/keno/SIUnits.jl)
- [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
- [Units.jl](https://github.com/timholy/Units.jl)

We want to support not only SI units but also any other unit system. We also
want to minimize or in some cases eliminate the run-time penalty of units.
There should be facilities for dimensional analysis. All of this should
integrate easily with the usual mathematical operations and collections
that are found in Julia base.

## Features

- Can dispatch on the dimensions of a quantity. Consider the following
  toy example, converting from voltage or power ratios to decibels
  and assuming a 50 Ohm load:

```jldoctest
julia> dB(num::Unitful.Voltage, den::Unitful.Voltage) = 20*log10(num/den)
 dB (generic function with 1 method)

julia> dB(num::Unitful.Power, den::Unitful.Power) = 10*log10(num/den)
 dB (generic function with 2 methods)

julia> dB(1u"mV", 1u"V")
-60.0

julia> dB(1u"mW", 1u"W")
-30.0
```

- Can specify the dimensions of a quantity in a type definition, while still
  maintaining information about the size of the fields in the type:

```
type Person
    height::Unitful.Length{Float64}
    mass::Unitful.Mass{Float64}
end
```
- Can make new units using the [`@unit`](@ref) macro without digging through the code.
- Arrays can hold quantities with different units, different dimensions, even
  mixed with unitless numbers.
  This is done efficiently using the [`Unitful.AbstractQuantity{T}`](@ref) type,
  and could be useful in [general relativity](https://en.wikipedia.org/wiki/Metric_tensor_(general_relativity)):

```
julia> @unit c "c" SpeedOfLight 299792458u"m/s" false
c

julia> Diagonal([-1.0c^2, 1.0, 1.0, 1.0])
4×4 Diagonal{Unitful.AbstractQuantity{Float64}}:
 -1.0 c^2   ⋅    ⋅    ⋅
       ⋅   1.0   ⋅    ⋅
       ⋅    ⋅   1.0   ⋅
       ⋅    ⋅    ⋅   1.0
```

- Units may have rational exponents.
- Exact conversions are respected by using `Rational`s where possible.
- Units are sticky. Although `1.0 J` and `1.0 N m` are equivalent quantities,
  they are represented distinctly, so further manipulations on `1.0 J` can leave
  the `J` intact. Furthermore, units are only canceled out if they are exactly
  the same, including power-of-ten prefixes. `1.0 mV/V` is possible.
- Some built-in dimensional analysis.

## Quick start

### Installation

+ This package requires Julia 0.5. Older versions will not be supported.
+ `Pkg.clone("https://github.com/ajkeller34/Unitful.jl.git")`
+ `Pkg.build("Unitful")`

### In Julia

First load the package:

```jl
using Unitful
```

If you encounter errors you may want to try `Pkg.build("Unitful")`.

In `deps/Defaults.jl` of the package directory, you see what is defined by
default. Feel free to edit this file to suit your needs. The Unitful package
will need to be reloaded for changes to take place.

Here is a summary of the defaults:

- SI units and their power-of-ten prefixes are defined.
- Some other units (imperial units) are defined, without power-of-ten prefixes.
- Dimensions are also defined.

Some unit abbreviations conflict with other definitions or syntax:

- `inch` is used instead of `in`, since `in` conflicts with Julia syntax
- `minute` is used instead of `min`, since `min` is a commonly used function
- `hr` is used instead of `h`, since `h` is revered as the Planck constant

### Usage examples

Units, dimensions, and fundamental constants are not exported from Unitful.
This is to avoid proliferating symbols in your namespace unnecessarily. You can
retrieve them using the [`@u_str`](@ref) string macro for convenience, or
import them from the `Unitful` package to bring them into the namespace.

```@meta
DocTestSetup = quote
    using Unitful
    °C = Unitful.°C
    °F = Unitful.°F
    μm = Unitful.μm
    m = Unitful.m
    hr = Unitful.hr
    minute = Unitful.minute
    s = Unitful.s
end
```

```jldoctest
julia> 1u"kg" == 1000u"g"             # Equivalence implies unit conversion
true

julia> !(1u"kg" === 1000u"g")         # ...and yet we can distinguish these...
true

julia> 1u"kg" === 1u"kg"              # ...and these are indistinguishable.
true
```

In the next examples we assume we have brought some units into our namespace,
e.g. using `m = u"m"`, etc.

```jldoctest
julia> uconvert(°C, 212°F)
100//1 °C

julia> uconvert(μm/(m*°F), 9μm/(m*°C))
5//1 °F^-1 μm m^-1

julia> mod(1hr+3minute+5s, 24s)
17//1 s
```

See `test/runtests.jl` for more usage examples.

## To do

- Clean up how units/quantities are displayed.

- Clean up `sin(degrees)`, etc. (not done nicely)

- Benchmarking needed.

- More tests are always appreciated and necessary.

- Add support for uncertainties? For quantities with uncertainty, `isapprox`
  becomes a loaded / ambiguous name.
