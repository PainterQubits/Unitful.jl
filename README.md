[![Build Status](https://travis-ci.org/PainterQubits/Unitful.jl.svg?branch=master)](https://travis-ci.org/PainterQubits/Unitful.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/d0usn4eqx23uownr?svg=true)](https://ci.appveyor.com/project/ajkeller34/unitful-jl-1w7vc)
[![Coverage Status](https://coveralls.io/repos/github/PainterQubits/Unitful.jl/badge.svg?branch=master)](https://coveralls.io/github/PainterQubits/Unitful.jl?branch=master)
[![codecov.io](https://codecov.io/github/PainterQubits/Unitful.jl/coverage.svg?branch=master)](https://codecov.io/github/PainterQubits/Unitful.jl?branch=master)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://PainterQubits.github.io/Unitful.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://PainterQubits.github.io/Unitful.jl/dev)

# Unitful.jl

## About this clone / fork
We intend to keep pulling in further improvements from Unitful, and some of these changes might be
accepted in Unitful as well.

This is a minor adaption of the original. The changes were previously made
through type piracy in dependent packages, i.e. changing how types defined by Unitful were dislayed and used. 
Type piracy tends to destroy pre-compilation and is bad for you.

A more directly useful implementation of this clone is 'MechanicalUnits.jl'. To use MechanicalUnits (or other 
Unitful-dependant packages): 'pkg.instantiate' will read 'Manifest.toml', which points to this clone.

The changes are:
* All 'show' methods are moved into 'display.jl'
* Additional testing
* Units are printed with color
* Dimension symbols can be displayed on Windows terminals
* No space between value and unit.
```julia
julia> import Unitful.m
julia> print([1 2]m)   # Un-decorated output can be parsed as input (copy to reproduce)
[1 2]m
julia> [1 2]m          # Decorated output (using this format as a generator is not recommended)
1×2 Array{Unitful.Quantity{Int64, ᴸ,Unitful.FreeUnits{(m,), ᴸ,nothing}},2}:
 1  2
```
* '*' == '∙', also allowed in input:

```julia
julia> import Unitful: m, s, kg, ∙

julia> push!(ENV, "UNITFUL_FANCY_EXPONENTS" => true)

julia> 0.5m∙s/kg
0.5m∙s∙kg⁻¹      # The 'fancy exponents' can not be parsed as input. This is implemented in 'MechanicalUnits'
```

* Tuples, NTuples, mixed collections:
```julia
julia> (1,2,3)m*s^-1
(1, 2, 3)m∙s⁻¹

julia> (1,2m,3)m*s^-1
(1m∙s⁻¹, 2m²∙s⁻¹, 3m∙s⁻¹)
```

* Conversions are leniently allowed, as the result is only another representation of the same quanity and
thus always correct. In deed, unexpected output from a conversion often hints towards what's gone wrong.
```
julia> import Unitful: μm, GPa, MPa

julia> ϵ = 0.002 |> μm/m  # Strain is a unitless quantity, yet this is common:
2000.0μm∙m⁻¹

julia> σ = ϵ * 206GPa |> MPa  # Hooke's law, Young's modulus
412.00000000000006MPa
```



## Unitful.jl
Unitful is a Julia package for physical units. We want to support not only
SI units but also any other unit system. We also want to minimize or in some
cases eliminate the run-time penalty of units. There should be facilities
for dimensional analysis. All of this should integrate easily with the usual
mathematical operations and collections that are found in Julia base.

## Documentation

[Stable](http://PainterQubits.github.io/Unitful.jl/stable) and
[latest](https://PainterQubits.github.io/Unitful.jl/latest) versions available.

## Other packages in the Unitful family

### Units packages

- [UnitfulUS.jl](https://github.com/PainterQubits/UnitfulUS.jl): U.S. customary units. Serves as an example for how to implement a units
  package.
- [UnitfulAstro.jl](https://github.com/mweastwood/UnitfulAstro.jl): Astronomical units.
- [UnitfulAngles.jl](https://github.com/yakir12/UnitfulAngles.jl): More angular units, additional trigonometric functionalities, and clock-angle conversion.
- [UnitfulAtomic.jl](https://github.com/sostock/UnitfulAtomic.jl): Easy conversion from and to atomic units.
- [PowerSystemsUnits.jl](https://github.com/invenia/PowerSystemsUnits.jl): Common units for dealing with power systems.

### Feature additions

- [UnitfulRecipes.jl](https://github.com/jw3126/UnitfulRecipes.jl): Adds automatic labels for [Plots.jl](https://github.com/JuliaPlots/Plots.jl).
- [UnitfulIntegration.jl](https://github.com/PainterQubits/UnitfulIntegration.jl): Enables use of Unitful quantities with [QuadGK.jl](https://github.com/JuliaMath/QuadGK.jl). PRs for other integration packages are welcome.

### Unregistered packages

- [UnitfulMoles.jl](https://github.com/rafaqz/UnitfulMoles.jl) for defining mol units of chemical elements and compounds.

## Related packages

Unitful was inspired by:

- [SIUnits.jl](https://github.com/keno/SIUnits.jl)
- [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
- [Units.jl](https://github.com/timholy/Units.jl)
