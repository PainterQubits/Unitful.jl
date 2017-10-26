- v0.5.0
  - Add `dBΩ` and `dBS` to permit working with impedances and admittances in dB. These are
    used in the Touchstone format and in microwave measurements.
  - Implement `angle` for `Quantity{<:Complex}`.
  - Implement `float` for `Gain`, `Level`.
  - Replace `fieldratio` and `rootpowerratio` with `uconvertrp`.
    - Permits unit conversion between `NoUnits` and `dB`, etc. by presuming unitless ratios
      are of root-power quantities (hence the `rp` after `uconvert`).
    - `uconvertrp` has generic fallbacks and can be used as a drop-in replacement for
      `uconvert` otherwise.
  - Likewise, replace `powerratio` with `uconvertp` for ratios of power quantities.
  - Introduce `convertrp` and `convertp`. These are like `convert` but they make
    similar assumptions about unitless ratios being of power or root-power quantities,
    respectively.
  - Implement more division operations for `Gain`s (accidental omissions)
- v0.4.0
  - Introduce logarithmic quantities (experimental!)
  - Update syntax for Julia 0.6 and reorganize code for clarity.
  - Redefine `ustrip(x::Quantity) = ustrip(x.val)`. In most cases, this is unlikely to
    affect user code. The generic fallback `ustrip(x::Number)` remains unchanged.
  - `isapprox(1.0u"m",5)` returns `false` instead of throwing a `DimensionError`,
    in keeping with the behavior of an equality check (`==`).
  - Display of some units has changed to match their symbols [#104](https://github.com/ajkeller34/Unitful.jl/issues/104).
  - Don't export `cd` from Unitful.DefaultSymbols in order to avoid conflicts [#102](https://github.com/ajkeller34/Unitful.jl/issues/102).
  - Deprecated `dimension(x::AbstractArray{T}) where T<:Number`, use broadcasting instead.
  - Deprecated `dimension(x::AbstractArray{T}) where T<:Units`, use broadcasting instead.
  - Deprecated `ustrip(A::AbstractArray{T}) where T<:Number`, use broadcasting instead.
  - Deprecated `ustrip(A::AbstractArray{T}) where T<:Quantity`, use broadcasting instead.
- v0.3.0
  - Require Julia 0.6
  - Adds overloads for `rand` and `ones` [#96](https://github.com/ajkeller34/Unitful.jl/issues/96).
  - Improve symbol resolution in `u_str` macro [#98](https://github.com/ajkeller34/Unitful.jl/pull/98).
  - More work is done inside the `u_str` macro, such that the macro returns units, dimensions,
    numbers (quantities), or tuples rather than expressions.
- v0.2.6
  - Fix and close [#52](https://github.com/ajkeller34/Unitful.jl/issues/52).
  - Implement `Base.rtoldefault` for Quantity types
    (needed for AxisArrays [#52](https://github.com/JuliaArrays/AxisArrays.jl/pull/52)).
- v0.2.5
  - Fix and close [#79](https://github.com/ajkeller34/Unitful.jl/issues/79).
  - Add support for `round(T, ::DimensionlessQuantity)` where `T <: Integer`
    (also `floor`, `ceil`, `trunc`) [#90](https://github.com/ajkeller34/Unitful.jl/pull/90).
- v0.2.4
  - Bug fix: avoid four-argument `promote_type`
  - Bug fix: define method for `*(::Base.TwicePrecision, ::Quantity)`
  - Bug fix: definition of Bohr magneton had `e` instead of `q`
- v0.2.3
  - Dimensionful quantities are no longer accepted for `floor`, `ceil`, `trunc`, `round`,
    `isinteger`. The choice of units can yield physically different results.
    The functions are defined for dimensionless quantities, and return unitless numbers.
    Closes [#78](https://github.com/ajkeller34/Unitful.jl/issues/78).
  - Added `gn`, a constant quantity for the gravitational acceleration on earth
    [#75](https://github.com/ajkeller34/Unitful.jl/pull/75).
  - Added `ge`, the gravitational acceleration on earth as a unit
    [#75](https://github.com/ajkeller34/Unitful.jl/pull/75).
  - Added `lbf`, pounds-force unit
    [#75](https://github.com/ajkeller34/Unitful.jl/pull/75).
- v0.2.2
  - Fixed a bug in promotion involving `ContextUnits` where the promotion context might
    not be properly retained.
- v0.2.1
  - Fixed `isapprox` bug [#74](https://github.com/ajkeller34/Unitful.jl/pull/74).
  - Added `DimensionlessQuantity` methods for `exp`, `exp10`, `exp2`, `expm1`, `log1p`,
    `log2` [#71](https://github.com/ajkeller34/Unitful.jl/pull/71).
- v0.2.0
  - `Units{N,D}` is now an abstract type. Different concrete types for units give different
   behavior under conversion and promotion. The currently implemented concrete types are:
    - `FreeUnits{N,D}`: these give the typical behavior from prior versions of Unitful.
      Units defined in Unitful.jl and reachable by the `u_str` macro are all `FreeUnits`.
    - `ContextUnits{N,D,P}`, where P is some type `FreeUnits{M,D}`: these enable
      context-specific promotion rules, e.g. if units are defined in different packages.
    - `FixedUnits{N,D}`: these inhibit automatic conversion of quantities with different units.
  - `LengthUnit`, `EnergyUnit`, etc. are renamed to `LengthUnits`, `EnergyUnits`, etc. for
    consistency (they are related more to `Units` objects than `Unit` objects). You can
    still use the old names for now, but please switch over to using `...Units` instead
    of `...Unit` in this release as the old names will be removed in a future release.
  - `c` is now a unit, to permit converting mass into `MeV/c^2`, for example. `c0` is
    still a quantity equal to the speed of light in vacuum, in units of `m/s`
    [#67](https://github.com/ajkeller34/Unitful.jl/issues/67).
- v0.1.5
  - Patch for Julia PR [#20889](https://github.com/JuliaLang/julia/pull/20889), which
    changes how lowering is done for exponentiation of integer literals.
  - Bug fix to enable registering Main as a module for `u_str` (fixes
    [#61](https://github.com/ajkeller34/Unitful.jl/issues/61)).
  - Implement readable message for `DimensionError`
    [#62](https://github.com/ajkeller34/Unitful.jl/pull/62).
- v0.1.4
  - Critical bug fix owing to `mod_fast` changes.
- v0.1.3
  - Fix symmetry of `==` [#56](https://github.com/ajkeller34/Unitful.jl/issues/56).
  - Using `@refunit` will implicitly specify the ref. unit as the default for promotion.
    This will not change behavior for most people; it just ensures promotion won't
    fail for quantities with user-defined dimensions.
  - Remove `mod_fast` in anticipation of Julia PR [#20859](https://github.com/JuliaLang/julia/pull/20859).
  - Allow tolerance args for `isapprox` [#57](https://github.com/ajkeller34/Unitful.jl/pull/57)
- v0.1.2
  - On Julia 0.6, exponentiation by a literal is now type stable for integers.
- v0.1.1
  - Fixed a macro hygiene issue that prevented `@dimension` and `@derived_dimension`
   from working properly if Compat was not imported in the calling namespace.
- v0.1.0
  - Julia 0.6 compatibility.
  - On Julia 0.6, exponentiation by a literal is now type stable for
    common integer powers: -3, -2, -1, 0, 1, 2, 3.
  - Added missing methods for dot operators `.<` and `.<=` (Julia 0.5, fix
    [#55](https://github.com/ajkeller34/Unitful.jl/issues/55)).
  - Fix [#45](https://github.com/ajkeller34/Unitful.jl/issues/45). Ranges should
    work as expected on Julia 0.6. On Julia 0.5, [Ranges.jl](https://github.com/JuliaArrays/Ranges.jl)
    is used to make ranges work as well as possible given limitations in Base.
  - Fix [#33](https://github.com/ajkeller34/Unitful.jl/issues/33),
    [#42](https://github.com/ajkeller34/Unitful.jl/issues/42),
    and [#50](https://github.com/ajkeller34/Unitful.jl/issues/50).
    `deps/Defaults.jl` is dead. Long live `deps/Defaults.jl`. To define your own
    units, dimensions, and so on, you should now put them in a module, or ideally
    a package so that others can use the definitions too. You can override default
    promotion rules immediately after loading Unitful and dependent packages; this
    will generate method overwrite warnings on Julia 0.5 but not on 0.6.
  - `@u_str` macro has been improved. It can now traverse separate unit packages,
    as well as return tuples of `Units` objects.
  - `@preferunit` has been replaced with a function `preferunits`.
  - Added some methods for `ustrip`.
  - Implement `typemin`, `typemax`, `cbrt` for `Quantity`s.
  - Added matrix inversion for `StridedMatrix{T<:Quantity}`.
  - Added `istriu`, `istril` for `AbstractMatrix{T<:Quantity}`.
  - The `Unitful.SIUnits` module has been renamed to `Unitful.DefaultSymbols`.
  - Add `lb`, `oz`, `dr`, `gr` to Unitful (international Avoirdupois mass units).
- v0.0.4
  - Be aware, breaking changes to `deps/Defaults.jl` caused by some of the following!
  - Fix [#40](https://github.com/ajkeller34/Unitful.jl/issues/40).
  - Fix [#30](https://github.com/ajkeller34/Unitful.jl/issues/30).
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
  - Made units callable for unit conversion: `u"cm"(1u"m") == 100u"cm"//1`.
    Note that `Units` objects have no fields, so this is totally unambiguous.
    Moreover, we have convenient syntax for unit conversion by function chaining:
    `1u"m" |> u"cm" == 100u"cm"//1`. Note that `uconvert` will remain supported.
- v0.0.1 - Initial release
