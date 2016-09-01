[![Build Status](https://travis-ci.org/ajkeller34/Unitful.jl.svg?branch=master)](https://travis-ci.org/ajkeller34/Unitful.jl)

# Unitful.jl

**This package has recently undergone major changes. Existing users
are advised to read the documentation. Unitful will be published
and tagged shortly after Julia 0.5.0 is released.**

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

Ranges are not well supported at the moment. This will improve in the future.

## Documentation

Available [here](http://ajkeller34.github.io/Unitful.jl).

Tested on:

```
Julia Version 0.5.0-rc3+0
Commit e6f843b (2016-08-22 23:43 UTC)
Platform Info:
  System: Darwin (x86_64-apple-darwin13.4.0)
  CPU: Intel(R) Core(TM) i7-4870HQ CPU @ 2.50GHz
  WORD_SIZE: 64
  BLAS: libopenblas (USE64BITINT DYNAMIC_ARCH NO_AFFINITY Haswell)
  LAPACK: libopenblas64_
  LIBM: libopenlibm
  LLVM: libLLVM-3.7.1 (ORCJIT, haswell)
```
