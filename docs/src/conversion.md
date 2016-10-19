```@meta
DocTestSetup = quote
    using Unitful
end
```

## Converting between units

Since `convert` in Julia already means something specific (conversion between
Julia types), we define `uconvert` for conversion between units. Typically
this will also involve a conversion between types, but this function takes care
of figuring out which type is appropriate for representing the desired units.

```@docs
uconvert
```

Since objects are callable, we can also make [`Unitful.Units`](@ref) callable
with a `Number` as an argument, for a unit conversion shorthand:

```jldoctest
julia> u"cm"(1u"m")
100//1 cm
```

This syntax is a little confusing, but becomes appealing with the function
chaining operator `|>`:

```jldoctest
julia> 1u"m" |> u"cm"
100//1 cm
```

Note that since [`Unitful.Units`](@ref) objects have no fields, we don't have
to worry about ambiguity with constructor calls. This way of converting units
results in behavior identical to calling [`uconvert`](@ref).

### Dimensionless quantities

For dimensionless quantities, `uconvert` can be used to strip the units without
losing power-of-ten information:

```jldoctest
julia> uconvert(Unitful.NoUnits, 1.0u"μm/m")
1.0e-6

julia> uconvert(Unitful.NoUnits, 1.0u"m")
ERROR: Unitful.DimensionError()
```

You can also directly convert to a subtype of `Real` or `Complex`:

```jldoctest
julia> Float64(1.0u"μm/m")
1.0e-6
```

## Basic conversion and promotion mechanisms

Exact conversions between units are respected where possible. If rational
arithmetic would result in an overflow, then floating-point conversion should
proceed. Use of floating-point numbers inhibits exact conversion.

We decide the result units for addition and subtraction operations based
on looking at the types only. We can't take runtime values into account
without compromising runtime performance. If two quantities with the same units
are added or subtracted, then the result units will be the same. If two quantities
with differing units (but same dimension) are added or subtracted, then
the result units will be specified by promotion. The
[`Unitful.@preferunit`](@ref) macro is used in `deps/Defaults.jl` to designate
preferred units for each pure dimension for promotion. Adding two masses with
different units will give a result in `kg`. Adding two velocities with different
units will give `m/s`, and so on. You can special case for "mixed" dimensions,
e.g. such that the preferred units of energy are `J`. The behaviors can be
changed in `deps/Defaults.jl`.

For multiplication and division, note that powers-of-ten prefixes are significant
in unit cancellation. For instance, `mV/V` is not simplified, although `V/V` is.
Also, `N*m/J` is not simplified: there is currently no logic to decide
whether or not units on a dimensionless quantity seem "intentional" or not.

## Array promotion

Arrays are typed with as much specificity as possible upon creation. consider
the following three cases:

```jldoctest
julia> [1.0u"m", 2.0u"m"]
2-element Array{Quantity{Float64, Dimensions:{𝐋}, Units:{m}},1}:
 1.0 m
 2.0 m

julia> [1.0u"m", 2.0u"cm"]
2-element Array{Quantity{Float64, Dimensions:{𝐋}, Units:{m}},1}:
  1.0 m
 0.02 m

julia> [1.0u"m", 2.0]
2-element Array{Unitful.Quantity{Float64,D,U},1}:
 1.0 m
   2.0
```

In the first case, an array with a concrete type is created. Good
performance should be attainable. The second case invokes promotion so that an
array of concrete type can be created. The third case falls back to an abstract
type, which cannot be stored efficiently and will incur a performance penalty.
An additional benefit of having a concrete type is that we can dispatch on the
dimensions of the array's elements:

```jldoctest
julia> f{T<:Unitful.Length}(x::AbstractArray{T}) = sum(x)
f (generic function with 1 method)

julia> f([1.0u"m", 2.0u"cm"])
1.02 m

julia> f([1.0u"g", 2.0u"cm"])
ERROR: MethodError: no method matching f(::Array{Unitful.Quantity{Float64,D,U},1})
```

## Temperature conversion

If the dimension of a `Quantity` is purely temperature, then conversion
respects scale offsets. For instance, converting 0°C to °F returns the expected
result, 32°F. If instead temperature appears in combination with other units,
scale offsets don't make sense and we consider temperature *intervals*.
