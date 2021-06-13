[![CI](https://github.com/hustf/Unitfu.jl/workflows/CI/badge.svg)](https://github.com/hustf/Unitfu.jl/actions?query=workflow%3ACI)
[![Coverage Status](https://coveralls.io/repos/github/hustf/Unitfu.jl/badge.svg?branch=master)](https://coveralls.io/github/hustf/Unitfu.jl?branch=master)
[![codecov.io](https://codecov.io/github/hustf/Unitfu.jl/coverage.svg?branch=master)](https://codecov.io/github/hustf/Unitfu.jl?branch=master)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://hustf.github.io/Unitfu.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://hustf.github.io/Unitfu.jl/dev)

# Unitfu.jl

## About this clone / fork
We intend to keep pulling in further improvements from [PainterQubits/Unitful.jl](https://github.com/PainterQubits/Unitful.jl), and suggest improvements to Unitful.jl as well. Hopefully, in future, Unitful.jl's core functionality may be separated into a separate package, reducing the motivation for forks like this.

This is a minor adaption of the original, affecting parsing, display and constructors / conversion only. The changes
were previously made through type piracy in dependent packages, e.g. [MechanicalUnits.jl](https://github.com/hustf/MechanicalUnits.jl) was
changing how types defined by Unitful were dislayed and parsed.
Type piracy tends to destroy pre-compilation, hence forking Unitful is a cleaner solution.

The changes in this fork are:

* 'show' methods are moved into 'display.jl'
* 'fancy exponents' is the default behavior on all operating systems (apple and windows on versions previous to 1.8)
* Dimension symbols ( ᴸ for Length, also ᵀ, ᴺ, ᶿ ) can be displayed in Windows terminals. Unitful's (𝐋 for Length, 𝐓, 𝐍, 𝚯) are problematic.
* Units are printed with color and in a form that can be [parsed by Julia](https://docs.julialang.org/en/v1/base/io-network/#Text-I/O). Fancy superscripts and the unit separator, ∙ are exported by [MechanicalUnits.jl](https://github.com/hustf/MechanicalSketch.jl)
* Collections (tuples, arrays, vectors) with identical elements are printed with units outside of brackets, without redundant type information:

```julia
  julia> a = [1 2 3; 4 5 6]m/s
  2×3 Matrix{Quantity{Int64,  ᴸ∙ ᵀ⁻¹, FreeUnits{(m, s⁻¹),  ᴸ∙ ᵀ⁻¹, nothing}}}:
  1  2  3
  4  5  6

  julia> println(a)
  [1 2 3; 4 5 6]m∙s⁻¹

  julia> 25s * [1 2 3; 4 5 6]m∙s⁻¹
  2×3 Matrix{Quantity{Int64,  ᴸ, FreeUnits{(m,),  ᴸ, nothing}}}:
    25   50   75
  100  125  150

  julia> ans .|> cm
  2×3 Matrix{Quantity{Int64,  ᴸ, FreeUnits{(cm,),  ᴸ, nothing}}}:
    2500   5000   7500
  10000  12500  15000
```

* Quantities are considered as the immutable object, while unit conversions are leniently allowed. Converting `1kg∙m` to `mm` will result in `1000kg∙mm` and not an error. This is useful because unexpected output often hints towards what dimension (mass, length...) is missing before the conversion. For use in packages, use `strict_uconvert' instead.

Brief example, which would trigger an error in [PainterQubits/Unitful](https://github.com/PainterQubits/Unitful.jl/blob/master/src/display.jl):
```julia
julia> import Unitful: mg, dyn

julia> 1dyn |> mg
10mg∙m∙s⁻²
```
* `strict_uconvert(u, x)` is used where Unitful.jl uses `convert(u, x)` in place of quantity promotion.

## Installing this clone / fork
This fork is registered in [M8](https://github.com/hustf/M8).

```julia
(@v1.6) pkg> registry add https://github.com/hustf/M8
     Cloning registry from "https://github.com/hustf/M8"

(@v1.6) pkg> add Unitfu

julia> using Unitfu
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
