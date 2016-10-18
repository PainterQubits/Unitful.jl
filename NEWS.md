- v0.0.4
 - Be aware, breaking changes to `deps/Defaults.jl` caused by some of the following!
 - Fix [#30](https://github.com/ajkeller34/Unitful.jl/issues/33).
 - Support relevant `@fastmath` operations for `Quantity`s.
 - Implement `fma`, `atan2` for `Quantity`s.
 - Implement `cis` for dimensionless `Quantity`s.
 - Removed `DimensionedUnits` and `DimensionedQuantity` abstract types.
   They were of dubious utility, and this change shortened the promotion code
   considerably. More importantly, this change has made it possible to write
   methods like the following, without method ambiguities:
   `uconvert(e::EnergyUnit, f::Frequency) = uconvert(e, u"h"*f)`.
 - Promotion wraps usual `Number` types in dimensionless, unitless `Quantity`
   types when promoted together with dimensionful `Quantity`s.
   With `Quantity`s it is not always possible to promote to a common
   concrete type, but this way we can at least ensure that the numeric backing
   types are all promoted: (`promote(1.0u"m", 1u"N"//2, 0x08) == (1.0 m,0.5 N,8.0)`,
   where `8.0` is actually a dimensionless, unitless `Quantity`).
   The usual outer constructor for `Quantity`s (`Quantity(val::T, unit)`)
   continues to return a number of type `T` if the unit is `NoUnits`,
   since most of the time the user would prefer a `Number` type from base rather
   than a dimensionless, unitless quantity.
 - Add more units to defaults: `bar` (bar), `Torr` (torr), `atm` (atmosphere),
   `l` or `L` (liter; both symbols accepted). You will need to delete
   `deps/Defaults.jl` in the Unitful package directory to get the new units.
 - Two character encodings for `μ` in SI prefixes are now generated automatically
   (some logic moved out of defaults).
 - Moved definition of `sin`, `cos`, `tan`, `sec`, `csc`, `cot` out of
   `deps/build.jl` and into `src/Unitful.jl`.

- v0.0.3
 - Bug fix: `uconvert(°C, 0x01°C)` no longer disturbs the numeric type
 - Allow μ-prefixed units to be typed with option-m on a Mac, in addition to
   using Unicode. Previously only `μm` could be typed this way.
 - Include a `baremodule` called `SIUnits` in the factory defaults. You can
   now do `using Unitful.SIUnits` to bring all of the SI units into the calling
   namespace.
 - Added remaining SI units to the factory defaults: `sr` (steradian), `lm`
   (luminous flux), `lx` (illuminance), `Bq` (becquerel), `Gy` (gray),
   `Sv` (sievert), `kat` (katal).
 - Simplify array creation, as in `[1, 2]u"km"` [#29](https://github.com/ajkeller34/Unitful.jl/pull/29)
 - Support multiplying ranges by units, as in `(1:3)*mm` [#28](https://github.com/ajkeller34/Unitful.jl/pull/28)
 - Bug fix [#26](https://github.com/ajkeller34/Unitful.jl/issues/26)
 - Promoting `Quantity`s with different dimensions now returns quantities with
   the same numeric backing type, e.g. `Quantity{Float64}`. Ideally, this would
   also be true if you mixed unitless and unitful numbers during promotion, but
   that is not yet the case. See [#24](https://github.com/ajkeller34/Unitful.jl/issues/24)
   for motivation.


- v0.0.2
 - Bug fixes (`[1.0m, 2.0m] ./ 3` would throw a `Unitful.DimensionError()`).
Promotion still isn't perfect, but it is hard for me to see what `@inferred`
errors are real until https://github.com/JuliaLang/julia/issues/18465 is resolved.

 - Made units callable for unit conversion:
    ```
u"cm"(1u"m") == 100u"cm"//1
```
    Note that `Units` objects have no fields, so this is totally unambiguous.
Moreover, we have convenient syntax for unit conversion by function chaining:
     ```
1u"m" |> u"cm" == 100u"cm"//1
```
    Note that `uconvert` will remain supported.

- v0.0.1 - Initial release
