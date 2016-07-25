# Unitful.jl

Unitful is a Julia package for physical units. Available
[here](https://github.com/ajkeller34/Unitful.jl). Inspired by Keno Fischer's
very clever package [SIUnits.jl](https://github.com/keno/SIUnits.jl).

We want to support not only SI units but also any other unit system. We also
want to minimize or in some cases eliminate the run-time penalty of units.
There should be facilities for dimensional analysis.
All of this should integrate easily with the usual mathematical operations
and collections that are found in Julia base.

*Ranges are not supported at the moment.* This will improve in the future.

## Documentation

Available [here](http://ajkeller34.github.io/Unitful.jl).

Tested on:

```
Julia Version 0.5.0-pre+5651
Commit 17c34e7* (2016-07-23 19:42 UTC)
Platform Info:
  System: Darwin (x86_64-apple-darwin13.4.0)
  CPU: Intel(R) Core(TM) i7-4870HQ CPU @ 2.50GHz
  WORD_SIZE: 64
  BLAS: libopenblas (USE64BITINT DYNAMIC_ARCH NO_AFFINITY Haswell)
  LAPACK: libopenblas64_
  LIBM: libopenlibm
  LLVM: libLLVM-3.7.1 (ORCJIT, haswell)
```
