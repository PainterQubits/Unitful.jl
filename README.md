[![Build Status](https://travis-ci.org/ajkeller34/Unitful.jl.svg?branch=master)](https://travis-ci.org/ajkeller34/Unitful.jl)
[![codecov](https://codecov.io/gh/ajkeller34/Unitful.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ajkeller34/Unitful.jl)
# Unitful.jl

Unitful is a Julia package for physical units. Available
[here](https://github.com/ajkeller34/Unitful.jl). Inspired by:

- [SIUnits.jl](https://github.com/keno/SIUnits.jl)
- [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
- [Units.jl](https://github.com/timholy/Units.jl)

We want to support not only SI units but also any other unit system. We also
want to minimize or in some cases eliminate the run-time penalty of units.
There should be facilities for dimensional analysis. All of this should
integrate easily with the usual mathematical operations and collections that
are found in Julia base.

## Documentation

[Available here](http://ajkeller34.github.io/Unitful.jl)

## Having trouble after an update?

Occasionally, changes to Unitful require some statements in `deps/Defaults.jl`
to change. In the worst case, this can break Unitful and throw uninformative
errors. We try to limit how often this happens, but it is sometimes inevitable
in the name of progress.

To recover a usable defaults file, backup then delete the original
`deps/Defaults.jl` in the Unitful package directory, then run
`Pkg.build("Unitful")` again in a new Julia session. After the new `Defaults.jl`
file has been generated, you can merge your user-defined units back into it.

If you have ideas on how to streamline this process, please contribute at
[issue 33](https://github.com/ajkeller34/Unitful.jl/issues/33)!
