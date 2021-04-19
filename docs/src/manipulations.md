```@meta
DocTestSetup = quote
    using Unitfu
end
```
# Manipulating units

## Unitfu string macro

```@docs
Unitfu.@u_str
Unitfu.register
```

## Dimension and unit inspection

We define a function [`dimension`](@ref) that turns, for example, `acre^2` or `1*acre^2`
into `ᴸ^4`. We can usually add quantities with the same dimension, regardless of specific
units (`FixedUnits` cannot be automatically converted, however). Note that dimensions cannot
be determined by powers of the units: `ft^2` is an area, but so is `ac^1` (an acre).

There is also a function [`unit`](@ref) that turns, for example, `1*acre^2` into `acre^2`.
You can then query whether the units are `FreeUnits`, `FixedUnits`, etc.

```@docs
Unitfu.unit
Unitfu.dimension
```

## Unit stripping

```@docs
Unitfu.ustrip
```

## Unit multiplication

```@docs
*(::Unitfu.Units, ::Unitfu.Units...)
*(::Unitfu.Dimensions, ::Unitfu.Dimensions...)
```
