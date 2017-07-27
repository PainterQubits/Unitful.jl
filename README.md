[![Build Status](https://travis-ci.org/ajkeller34/Unitful.jl.svg?branch=master)](https://travis-ci.org/ajkeller34/Unitful.jl)
[![Coverage Status](https://coveralls.io/repos/ajkeller34/Unitful.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ajkeller34/Unitful.jl?branch=master)
[![codecov.io](http://codecov.io/github/ajkeller34/Unitful.jl/coverage.svg?branch=master)](http://codecov.io/github/ajkeller34/Unitful.jl?branch=master)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://ajkeller34.github.io/Unitful.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://ajkeller34.github.io/Unitful.jl/latest)

# Unitful.jl

Unitful is a Julia package for physical units. We want to support not only
SI units but also any other unit system. We also want to minimize or in some
cases eliminate the run-time penalty of units. There should be facilities
for dimensional analysis. All of this should integrate easily with the usual
mathematical operations and collections that are found in Julia base.

## Documentation

[Stable](http://ajkeller34.github.io/Unitful.jl/stable) and
[latest](https://ajkeller34.github.io/Unitful.jl/latest) versions available.

## Other packages in the Unitful family

- [UnitfulUS.jl](https://github.com/ajkeller34/UnitfulUS.jl): Adds U.S. customary units. Serves as an example for how to implement a units 
  package.
- [UnitfulIntegration.jl](https://github.com/ajkeller34/UnitfulIntegration.jl): Enables use of Unitful quantities with [QuadGK.jl](https://github.com/JuliaMath/QuadGK.jl). PRs for other integration packages are welcome.
- [UnitfulAngles.jl](https://github.com/yakir12/UnitfulAngles.jl): Introduces many more angular units, includes additional trigonometric functionalities, and clock-angle conversion.

## Related packages

Unitful was inspired by:

- [SIUnits.jl](https://github.com/keno/SIUnits.jl)
- [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
- [Units.jl](https://github.com/timholy/Units.jl)
