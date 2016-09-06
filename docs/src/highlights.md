```@meta
DocTestSetup = quote
    using Unitful
end
```

## Dispatch on dimensions

Consider the following toy example, converting from voltage or power ratios to decibels:

```jldoctest
julia> dB(num::Unitful.Voltage, den::Unitful.Voltage) = 20*log10(num/den)
 dB (generic function with 1 method)

julia> dB(num::Unitful.Power, den::Unitful.Power) = 10*log10(num/den)
 dB (generic function with 2 methods)

julia> dB(1u"mV", 1u"V")
-60.0

julia> dB(1u"mW", 1u"W")
-30.0
```

### Dimensions in a type definition

It may be tempting to specify the dimensions of a quantity in a type definition, e.g.

```
type Person
    height::Unitful.Length
    mass::Unitful.Mass
end
```

However, these are abstract types. If performance is important, it may be better
just to pick a concrete `Quantity` type:

```
type Person
    height::typeof(1.0u"m")
    mass::typeof(1.0u"kg")
end
```

You can still create a `Person` as `Person(5u"ft"+10u"inch", 75u"kg")`; the
unit conversion happens automatically.

## Making new units and dimensions

You can make new units using the [`@unit`](@ref) macro on the fly:

```jldoctest
julia> @unit c "c" SpeedOfLight 299792458u"m/s" false
c
```

## Arrays

Arrays can hold quantities with different units, different dimensions, even
mixed with unitless numbers. Doing so will suffer a performance penalty compared
with the fast performance attainable with an array of concrete type
(e.g. as resulting from `[1.0u"m", 2.0u"m", 3.0u"m"]`). However, it could be useful
in toy calculations for
[general relativity](https://en.wikipedia.org/wiki/Metric_tensor_(general_relativity)):

```
julia> @unit c "c" SpeedOfLight 299792458u"m/s" false
c

julia> Diagonal([-1.0c^2, 1.0, 1.0, 1.0])
4×4 Diagonal{Number}:
 -1.0 c^2   ⋅    ⋅    ⋅
       ⋅   1.0   ⋅    ⋅
       ⋅    ⋅   1.0   ⋅
       ⋅    ⋅    ⋅   1.0
```

## Units may have rational exponents

```
julia> 1.0u"V/sqrt(Hz)"
1.0 Hz^-1/2 V
```

## Exact conversions are respected by using `Rational`s where possible.

```
julia> uconvert(u"ft",1u"inch")
1//12 ft
```

## Sticky units

Although `1.0 J` and `1.0 N m` are equivalent quantities,
they are represented distinctly, so further manipulations on `1.0 J` can leave
the `J` intact. Furthermore, units are only canceled out if they are exactly
the same, including power-of-ten prefixes. `1.0 mV/V` is possible.
