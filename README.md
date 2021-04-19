[![CI](https://github.com/PainterQubits/Unitful.jl/workflows/CI/badge.svg)](https://github.com/PainterQubits/Unitful.jl/actions?query=workflow%3ACI)
[![Coverage Status](https://coveralls.io/repos/github/PainterQubits/Unitful.jl/badge.svg?branch=master)](https://coveralls.io/github/PainterQubits/Unitful.jl?branch=master)
[![codecov.io](https://codecov.io/github/PainterQubits/Unitful.jl/coverage.svg?branch=master)](https://codecov.io/github/PainterQubits/Unitful.jl?branch=master)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://PainterQubits.github.io/Unitful.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://PainterQubits.github.io/Unitful.jl/dev)

# Unitful.jl

## About this clone / fork
We intend to keep pulling in further improvements from PainterQubits/Unitful.jl, and some of the ideas might be
accepted in Unitful as well.

This is a minor adaption of the original, affecting parsing, display and constructors / conversion only. The changes 
were previously made through type piracy in dependent packages, e.g. [MechanicalUnits.jl](https://github.com/hustf/MechanicalUnits.jl) was 
changing how types defined by Unitful were dislayed and parsed.
Type piracy tends to destroy pre-compilation, hence forking Unitful is a cleaner solution.

The changes in this fork are:
* All 'show' methods are moved into 'display.jl'
* Additional testing
* Units are printed with color
* Dimension symbols can be displayed on Windows terminals
* No space between value and unit. Useful for:
```julia
julia> import Unitful.m
julia> print([1 2]m)   # Un-decorated output can be parsed as input (copy to reproduce)
[1 2]m
julia> [1 2]m          # Decorated output (using this format as a generator is not recommended)
1×2 Array{Unitful.Quantity{Int64, ᴸ,Unitful.FreeUnits{(m,), ᴸ,nothing}},2}:
 1  2
```
* Collections (tuples, arrays, vectors) with identical elements are printed with units outside of brackets

```julia
julia> (1,2,3)m*s^-1
(1, 2, 3)m∙s⁻¹

julia> (1,2m,3)m*s^-1
(1m∙s⁻¹, 2m²∙s⁻¹, 3m∙s⁻¹)
```

* Unit conversions are more freely allowed, since an unexpected result is still a correct representation of the input quantity. 
Unexpected output from a conversion often hints towards what dimension (mass, length...) is missing before the conversion. 
We trigger such conversions by calling the wanted output unit, which may be considered dirty programming practice. We just consider it 
too useful to disallow for that reason. Type stability in functions is a separate concern to physical correctness, and can be ensured 
in other ways. Brief example, which would trigger an error in PainterQubits/Unitful:
´´´
julia> import Unitful: mg, dyn

julia> 1dyn |> mg
10mg∙m∙s⁻²
´´´

## Installing this clone / fork
If you have already installed Unitful, you may have to remove it first:
´´´
(@v1.5) pkg> rm Unitful
Updating `C:\Users\F\.julia\environments\v1.5\Project.toml`
  [1986cc42] - Unitful v1.3.0
Updating `C:\Users\F\.julia\environments\v1.5\Manifest.toml`
  [187b0558] - ConstructionBase v1.0.0
  [1986cc42] - Unitful v1.3.0
  [37e2e46d] - LinearAlgebra

(@v1.5) pkg> add https://github.com/hustf/Unitful.jl
   Updating git-repo `https://github.com/hustf/Unitful.jl`
  Resolving package versions...
Updating `C:\Users\F\.julia\environments\v1.5\Project.toml`
  [1986cc42] + Unitful v1.3.0 `https://github.com/hustf/Unitful.jl#master`
Updating `C:\Users\F\.julia\environments\v1.5\Manifest.toml`
  [187b0558] + ConstructionBase v1.0.0
  [1986cc42] + Unitful v1.3.0 `https://github.com/hustf/Unitful.jl#master`
  [37e2e46d] + LinearAlgebra

julia> using Unitful

julia>
´´´

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
- [UnitfulMoles.jl](https://github.com/rafaqz/UnitfulMoles.jl) for defining mol units of chemical elements and compounds.

### Feature additions

- [UnitfulRecipes.jl](https://github.com/jw3126/UnitfulRecipes.jl): Adds automatic labels for [Plots.jl](https://github.com/JuliaPlots/Plots.jl).
- [UnitfulIntegration.jl](https://github.com/PainterQubits/UnitfulIntegration.jl): Enables use of Unitful quantities with [QuadGK.jl](https://github.com/JuliaMath/QuadGK.jl). PRs for other integration packages are welcome.
- [UnitfulEquivalences.jl](https://github.com/sostock/UnitfulEquivalences.jl): Enables conversion between equivalent quantities of different dimensions, e.g. between energy and wavelength of a photon.
- [UnitfulLatexify.jl](https://github.com/gustaphe/UnitfulLatexify.jl): Pretty print units and quantities in LaTeX format.

## Related packages

Unitful was inspired by:

- [SIUnits.jl](https://github.com/keno/SIUnits.jl)
- [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
- [Units.jl](https://github.com/timholy/Units.jl)
