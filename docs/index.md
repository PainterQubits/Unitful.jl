Unitful.jl
============

A [Julia](http://julialang.org) package for using units. Available
[here](https://github.com/ajkeller34/Unitful.jl). Inspired by Keno Fischer's
package [SIUnits.jl](https://github.com/keno/SIUnits.jl).

Installation
------------

+ Use a recent nightly build of Julia 0.5. In 0.4, `promote_op` is not used
extensively enough for common array operations to work properly with units.

+ `Pkg.clone("www.github.com/ajkeller34/Unitful.jl.git")`

Quick start
-----------

```jl
using Unitful
```

By default, SI units and their power-of-ten prefixes are exported. Imperial units
are exported but not power-of-ten prefixes.

- `m`, `km`, `cm`, etc. are exported.
- `nft` for nano-foot is not exported.

Some unit abbreviations conflict with Julia definitions or syntax:

- `inch` is used instead of `in`
- `minute` is used instead of `min`

Testing this package
--------------------

There are of course subtleties in getting this all to work. To test that
changes to either Julia or Unitful haven't given rise to undesirable behavior,
run the test suite in Julia:
```jl
cd(Pkg.dir("Unitful"))
include("test/runtests.jl")
```
