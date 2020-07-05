```@meta
DocTestSetup = quote
    using Unitful
    using Unitful:AffineError
end
```
# Temperature scales

Temperatures require some care. Temperature scales like `K` and `Ra` are thermodynamic
temperature scales, with zero on the scale corresponding to absolute zero. Unit conversions
between thermodynamic or absolute temperatures are done by multiplying conversion factors,
as usual. Also in common use are temperature scales like `°C` or `°F`, which are defined
relative to arbitrary offsets. For example, in the case of `°C`, zero on the scale is the
freezing point of water, not absolute zero. To convert between relative temperature scales,
an affine transformation is required. Absolute and relative temperatures can be
distinguished by type to avoid ambiguities that could yield erroneous or unexpected results.
On relative temperature scales, problems can arise because e.g. `0°C + 0°C` could mean `0°C`
or `273.15°C`, depending on whether the operands are variously interpreted as temperature
differences or as absolute temperatures. On thermodynamic temperature scales, there is no
ambiguity.

## Temperatures on absolute scales

Unit conversions between temperatures on absolute scales like Kelvin or Rankine are done in
the usual way by multiplication of a scale factor. For example, we have:

```jldoctest
julia> uconvert(u"K", 1u"Ra")
5//9 K
```

We can identify absolute temperatures using the `Unitful.AbsoluteScaleTemperature` type
alias:

```jldoctest
julia> 1u"K" isa Unitful.AbsoluteScaleTemperature
true
```

## Temperatures on relative scales

Unit conversions between temperatures on relative scales like Celsius or Fahrenheit involve
an affine transformation, that is, a scaling plus some translation (scale offset). In
Unitful, relative scale temperatures are considered to have the same dimension as absolute
scale temperatures, as expected. However, temperatures on relative and absolute scales are
distinguished by the type of the [`Unitful.Units`](@ref) object (and therefore the type of
the [`Unitful.Quantity`](@ref) object).

```jldoctest
julia> uconvert(u"°C", 32u"°F")
0//1 °C
```

We can identify relative scale temperatures using the `Unitful.RelativeScaleTemperature`
type alias, e.g.:

```jldoctest
julia> 1u"°C" isa Unitful.RelativeScaleTemperature
true
```

Some operations are not well defined with relative scale temperatures, and therefore throw
an `Unitful.AffineError` (please report any unexpected behavior on the GitHub issue
tracker).

```jldoctest
julia> 32u"°F" + 1u"°F"
ERROR: AffineError: an invalid operation was attempted with affine quantities: 32 °F + 1 °F
[...]

julia> 32u"°F" * 2
ERROR: AffineError: an invalid operation was attempted with affine quantities: 32 °F*2
[...]
```

There is a general mechanism for making units that indicate quantities should unit-convert
under some affine transformation. While the usual use case is for relative scale
temperatures, nothing in the implementation limits it as such. Accordingly, relative scale
temperatures are considered to be [`Unitful.AffineQuantity`](@ref) objects with dimensions
of temperature. The units on "affine quantities" are [`Unitful.AffineUnits`](@ref) objects.

Making your own affine units typically requires two steps. First, define the absolute unit
using the [`Unitful.@unit`](@ref) macro. Second, use the [`Unitful.@affineunit`](@ref) macro
to make a corresponding affine unit. As an example, this is how `Ra` and `°F` are
implemented:

```julia
@unit Ra "Ra" Rankine (5//9)*K false
@affineunit °F "°F" (45967//100)Ra
```

The preferred unit for promoting temperatures is usually `K` when using
[`Unitful.FreeUnits`](@ref).

```@docs
Unitful.AffineUnits
Unitful.AffineQuantity
Unitful.ScalarUnits
Unitful.ScalarQuantity
Unitful.absoluteunit
```
