```@meta
DocTestSetup = quote
    using Unitful
    using Unitful:AffineError
end
```

Temperatures can be represented in two ways in Unitful: as temperature differences or
as absolute temperatures. These are distinguished by type to avoid ambiguities that could
yield erroneous or unexpected results.

## Temperature differences

Unit conversions between temperature differences are done in the usual way by multiplication
of a scale factor. Temperature differences are represented by the usual symbols for
temperatures. For example, we have:

```jldoctest
julia> uconvert(u"°C", 1u"°F")
5//9 °C
```

We can identify temperature differences using the `Unitful.RelativeTemperature` type alias:

```jldoctest
julia> 1u"°C" isa Unitful.RelativeTemperature
true
```

## Absolute temperatures

Unit conversions between absolute temperatures involve an affine transformation, that is,
a scaling plus some translation (scale offset). In Unitful, absolute temperatures are
considered to have the same dimension as temperature differences, as expected. However,
for a given temperature scale, relative and absolute temperatures are distinguished by the
type of the [`Unitful.Units`](@ref) object (and therefore the type of the
[`Unitful.Quantity`](@ref) object).

```jldoctest
julia> uconvert(u"abs°C", 32u"abs°F")
0//1 °C (affine)
```

We can identify absolute temperatures using the `Unitful.AbsoluteTemperature` type alias, e.g.:

```jldoctest
julia> is_boiling(t::Unitful.AbsoluteTemperature) = t >= 100u"abs°C"
is_boiling (generic function with 1 method)
```

Some operations are not well defined with absolute temperatures, and therefore throw an
[`Unitful.AffineError`](@ref) (please report any unexpected behavior on the GitHub issue
tracker).

```jldoctest
julia> 32u"abs°F" + 1u"abs°F"
ERROR: AffineError: an invalid operation was attempted with affine quantities: 32 °F (affine)+1 °F (affine)
[...]
```

```jldoctest
julia> 32u"abs°F" * 2
ERROR: AffineError: an invalid operation was attempted with affine quantities: (32 °F (affine))*2
[...]
```

For consistency, even temperature scales that have zero scale offset (e.g. Kelvin) have two
types of units (`K` and `absK`).

There is a general mechanism for making units that indicate quantities should unit-convert
under some affine transformation. While the usual use case is for absolute temperatures,
nothing in the implementation limits it as such. Accordingly, absolute temperatures are
considered to be [`Unitful.AffineQuantity`](@ref) objects with dimensions of temperature.
The units on "affine quantities" are [`Unitful.AffineUnits`](@ref) objects.

Making your own affine units typically requires three steps. First, define the relative unit
using the [`Unitful.@unit`](@ref) macro. Second, use [`Unitful.affineunit`](@ref) to make a
corresponding affine unit. Third, define a method of [`Unitful.affinedefaults`](@ref) to
aid in the promotion of affine quantities. As an example, this is how `°C` and `abs°C` are
implemented:

```jl
@unit °C "°C" Celsius 1K true
const abs°C = affineunit(-27315°C//100)
affinedefaults(::typeof(°C)) = abs°C
```

The preferred unit for promoting temperatures is usually `K` (when using
[`Unitful.FreeUnits`](@ref)); when promoting absolute temperatures, first `K` is returned
based on the dimensions of the quantities being promoted, then
`Unitful.affinedefaults(K)` yields `absK`.

```@docs
Unitful.AffineUnits
Unitful.AffineQuantity
Unitful.affineunit
Unitful.affinedefaults
Unitful.relativeunit
```
