# Design and implementation

## A view from 30000 ft (or 9144 m)

Like SIUnits.jl, units are part of the type signature of a quantity. From there,
the implementations diverge. Unitful.jl uses generated functions to enable more
flexibility than found in SIUnits.jl. Support is targeted to Julia 0.5+
because of some limitations in how `promote_op` is used in Julia 0.4. See
[issue #13803](https://github.com/julialang/Julia/issues/13803).

We make an immutable `UnitDatum` that stores a base unit (expressed a bits type,
either `NormalUnit` or `TemperatureUnit`), a rational exponent, and a prefix.
We don't allow arbitrary floating point exponents of units because they probably
aren't very useful. The prefixes on units (e.g. `nm` or `km`) may help to avoid
overflow issues and general ugliness.

We define the immutable singleton `UnitData{T}`, where `T` is always a tuple
of `UnitDatum` (variable number of arguments). Usually, the user interacts
only with `UnitData{T}` objects, not `UnitDatum`.

We define methods `dimension` that turn, for example, `acre^2` into `[L]^4`.
We can in principle add quantities with the same dimension
(`acre [L]^2 + ft^2 [L]^2`), provided some "promotion" rules are given (see below).
Note that dimensions cannot be determined
by powers of the units: `ft^2` is an area, but so is `acre^1`.

We define unitful *Quantities* `RealQuantity{T<:Real, Units}` and
`FloatQuantity{T<:AbstractFloat, Units}` where `Units` is
a type `UnitData{T}`. To play nicely with `FloatRange` and `LinSpace`, we need
`FloatQuantity <: AbstractFloat`; we also have `RealQuantity <: Real`.
By putting units in the type signature of a quantity,
staged functions can be used to offload
as much of the unit computation to compile-time as is possible.

## Creating new units

Just use the `@unit` macro, providing four arguments: the symbol for the unit,
how the unit is displayed, a quantity equivalent to one of the new unit, and a
`Bool` to indicate whether or not to make symbols for all SI prefixes
(as in mm, km, etc.)

Usage example:

```jl
@unit pim "π-meter" π*m false
1pim # displays as "1 π-meter"
convert(m, 1pim) # evaluates to 3.14159... m
```

You can look at `Defaults.jl` in the package to see what units are there by
default.

Note for the experts: Some care should be taken if explicitly making `UnitData` objects.
The ordering of `UnitDatum` inside a tuple matters for type comparisons. Using the
unary multiplication operator on the `UnitData` object will return a "canonically
sorted" `UnitData` object. Indeed, this is how we avoid ordering issues when
multiplying quantities together.

## Conversion and promotions

Conversions between units are rejected if the units have different dimensions.

We decide the result units for addition and subtraction operations based
on looking at the unit types only. We can't take runtime values into account
without compromising runtime performance. By default, if we
have `x (A) + y (B) = z (C)` where `x,y,z` are numbers and `A,B,C` are units,
then `C = max(1A, 1B)`. This is an arbitrary choice and can be changed in
`Defaults.jl`. For example,
`101cm + 1m = 2.01m` because `1m > 1cm`.

Although quantities could be integrated with Julia's promotion mechanisms,
we instead simply define how to add or subtract the units themselves,
and have addition of quantities rely on those definitions.
The concern is that implicit promotion operations
that were written with pure numbers in mind may give rise to surprising
behavior without returning errors. The operations on the numeric values of
quantities of course utilize Julia's promotion mechanisms.

Some of our `convert` syntax breaks Julia conventions in that the first
argument is not a type. For example, `convert(ft, 1m)` converts 1 meter to feet.
This may rub people the wrong way and could change. A neat alternative would be
to override other syntax: `3m in cm` would be succinct and intuitive.
Overriding `in` is simple, but the parsing rules aren't intended for this.
For example, `0°C in °F == 32°F` fails to evaluate, but `(0°C in °F) == 32°F`
returns `true`.

Exact conversions between units are respected where possible. If rational
arithmetic would result in an overflow, then floating-point conversion will
proceed.

## Temperature conversion

If a unit is a pure temperature unit, then conversion respects scale offsets.
For instance, converting 0°C to °F returns the expected result, 32°F.
If instead temperature appears in combination with other units,
scale offsets don't make sense and we consider temperature *intervals*.
This gives the expected behavior most of the time.

## Discussion

- If there is a need for complex numbers to have units, please implement that
and submit a PR, adding tests where appropriate.

- [SIUnits issue 18](https://github.com/Keno/SIUnits.jl/issues/18): Some discussion
regarding how to define `one(x)` and `zero(x)` for quantities with units. Right now
`one(x)` returns no units, but `zero(x)` returns units. This is consistent with
Julia documentation; `one(x)` should be multiplicative identity and `zero(x)`
should be additive identity.

## Potential improvements to Base

In writing this package I’ve noticed a few places where changes to Base could be helpful. I keep redefinitions of methods found in Base in `Redefinitions.jl`. If I receive some encouraging feedback from a Julia contributor, maybe I’ll submit a PR. In the meantime, try not to be annoyed by the redefinition warnings.

To give a flavor of the kind of changes I suggest, here is an example.
According to the documentation, `one(x)` is supposed to be the multiplicative identity for the type of x. There are several places in `base/range.jl`, for example, where `one(x)` is being used instead of `oftype(x,1)`. This distinction could be important for types with units:
`(1m) * one(1m) == 1m`, but `1m+oftype(1m, 1) == 2m`, and `1m+one(1m)` is invalid
since we cannot add unitful and unitless quantities.
