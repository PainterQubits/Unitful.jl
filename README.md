[![Build Status](https://travis-ci.org/ajkeller34/Unitful.jl.svg?branch=master)](https://travis-ci.org/ajkeller34/Unitful.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/eo2upsvc9k4gd6bk?svg=true)](https://ci.appveyor.com/project/ajkeller34/unitful-jl)
[![Coverage Status](https://coveralls.io/repos/github/ajkeller34/Unitful.jl/badge.svg?branch=master)](https://coveralls.io/github/ajkeller34/Unitful.jl?branch=master)
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

### Units packages

- [UnitfulUS.jl](https://github.com/ajkeller34/UnitfulUS.jl): U.S. customary units. Serves as an example for how to implement a units 
  package.
- [UnitfulAstro.jl](https://github.com/mweastwood/UnitfulAstro.jl): Astronomical units.
- [UnitfulAngles.jl](https://github.com/yakir12/UnitfulAngles.jl): More angular units, additional trigonometric functionalities, and clock-angle conversion.

### Feature additions

- [UnitfulIntegration.jl](https://github.com/ajkeller34/UnitfulIntegration.jl): Enables use of Unitful quantities with [QuadGK.jl](https://github.com/JuliaMath/QuadGK.jl). PRs for other integration packages are welcome.

## Related packages

Unitful was inspired by:

- [SIUnits.jl](https://github.com/keno/SIUnits.jl)
- [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
- [Units.jl](https://github.com/timholy/Units.jl)
