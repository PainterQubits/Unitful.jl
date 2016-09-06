


<a id='Unitful.jl-1'></a>

# Unitful.jl


A Julia package for physical units. Available [here](https://github.com/ajkeller34/Unitful.jl). Inspired by:


  * [SIUnits.jl](https://github.com/keno/SIUnits.jl)
  * [EngUnits.jl](https://github.com/dhoegh/EngUnits.jl)
  * [Units.jl](https://github.com/timholy/Units.jl)


We want to support not only SI units but also any other unit system. We also want to minimize or in some cases eliminate the run-time penalty of units. There should be facilities for dimensional analysis. All of this should integrate easily with the usual mathematical operations and collections that are found in Julia base.


<a id='Quick-start-1'></a>

## Quick start


  * This package requires Julia 0.5. Older versions will not be supported.
  * `Pkg.clone("https://github.com/ajkeller34/Unitful.jl.git")`
  * `Pkg.build("Unitful")`
  * `using Unitful`


In `deps/Defaults.jl` of the package directory, you can see what is defined by default. Feel free to edit this file to suit your needs. The Unitful package will need to be reloaded for changes to take place. To recover the "factory  defaults," delete `deps/Defaults.jl` and run `Pkg.build("Unitful")` again.


Here is a summary of the defaults file contents:


  * Base dimensions like length, mass, time, etc. are defined.
  * Derived dimensions like volume, energy, momentum, etc. are defined.
  * SI units and their power-of-ten prefixes are defined.
  * Some other units (imperial units) are defined, without power-of-ten prefixes.
  * Promotion behavior is specified.


Some unit abbreviations conflict with other definitions or syntax:


  * `inch` is used instead of `in`, since `in` conflicts with Julia syntax
  * `minute` is used instead of `min`, since `min` is a commonly used function
  * `hr` is used instead of `h`, since `h` is revered as the Planck constant


Units, dimensions, and fundamental constants are not exported from Unitful. This is to avoid proliferating symbols in your namespace unnecessarily. You can retrieve them using the [`@u_str`](manipulations.md#Unitful.@u_str) string macro for convenience, or import them from the `Unitful` package to bring them into the namespace.


<a id='Usage-examples-1'></a>

## Usage examples




```jlcon
julia> 1u"kg" == 1000u"g"             # Equivalence implies unit conversion
true

julia> !(1u"kg" === 1000u"g")         # ...and yet we can distinguish these...
true

julia> 1u"kg" === 1u"kg"              # ...and these are indistinguishable.
true
```


In the next examples we assume we have brought some units into our namespace, e.g. using `m = u"m"`, etc.


```jlcon
julia> uconvert(°C, 212°F)
100//1 °C

julia> uconvert(μm/(m*°F), 9μm/(m*°C))
5//1 °F^-1 μm m^-1

julia> mod(1hr+3minute+5s, 24s)
17//1 s
```


See `test/runtests.jl` for more usage examples.


<a id='To-do-1'></a>

## To do


  * Benchmarking needed.
  * More tests are always appreciated and necessary.
  * Specialized exceptions for dimensional mismatches, other unit-related troubles?
  * Further down the road, it could be nice to have a concrete type where the units are a value and not part of the type signature. This could be used as a fallback for promotion when arrays of mixed dimensions are created.

