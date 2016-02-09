Unitful.jl
============

A Julia package for physical units. Available
[here](https://github.com/ajkeller34/Unitful.jl). Inspired by Keno Fischer's
very clever package [SIUnits.jl](https://github.com/keno/SIUnits.jl).

We want to support not only SI units but also any other unit system. We also
want to minimize or in some cases eliminate the run-time penalty of units.
There should be facilities for dimensional analysis.
All of this should integrate easily with the usual mathematical operations
and collections that are found in Julia base.

Features
---

- Support for rational exponents. Good for power spectral density, etc.
- “Sticky units”: by default, no implicit conversions in multiplication or division
    - We allow for implicit conversions in addition and subtraction
- Some built-in dimensional analysis
- Support for various `Range` types, including `LinSpace`

Quick start
-----------

### Installation

+ Use a recent nightly build of Julia 0.5.

+ `Pkg.clone("www.github.com/ajkeller34/Unitful.jl.git")`

### In Julia

```jl
using Unitful
```

Thoughtfully disregard the warnings about overwriting methods in Base.

By default, SI units and their power-of-ten prefixes are exported. Other units
are exported but not power-of-ten prefixes.

- `m`, `km`, `cm`, etc. are exported.
- `nft` for nano-foot is not exported.

Some unit abbreviations conflict with Julia definitions or syntax:

- `inch` is used instead of `in`
- `minute` is used instead of `min`

See `test/runtests.jl` for some usage examples.

Testing this package
--------------------

There are of course subtleties in getting this all to work. To test that
changes to either Julia or Unitful haven't given rise to undesirable behavior,
run the test suite in Julia:
```jl
cd(Pkg.dir("Unitful"))
include("test/runtests.jl")
```
