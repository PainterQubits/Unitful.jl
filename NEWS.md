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
