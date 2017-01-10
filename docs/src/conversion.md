```@meta
DocTestSetup = quote
    using Unitful
end
```

## Converting between units

Since `convert` in Julia already means something specific (conversion between
Julia types), we define [`uconvert`](@ref) for conversion between units. Typically
this will also involve a conversion between types, but this function takes care
of figuring out which type is appropriate for representing the desired units.

Exact conversions between units are respected where possible. If rational
arithmetic would result in an overflow, then floating-point conversion should
proceed. Use of floating-point numbers inhibits exact conversion.

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

### Temperature conversion

If the dimension of a `Quantity` is purely temperature, then conversion
respects scale offsets. For instance, converting 0°C to °F returns the expected
result, 32°F. If instead temperature appears in combination with other units,
scale offsets don't make sense and we consider temperature *intervals*.

## Promotion mechanisms

We decide the result units for addition and subtraction operations based
on looking at the types only. We can't take runtime values into account
without compromising runtime performance. If two quantities with the same units
are added or subtracted, then the result units will be the same. If two quantities
with differing units (but same dimension) are added or subtracted, then
the result units will be specified by promotion.

### Promotion rules for specific dimensions

You can specify the result units for promoting quantities of a specific dimension
once at the start of a Julia session, specifically *before* `upreferred` *has been
called or quantities have been promoted*. For example, you can specify that when promoting
two quantities with different energy units, the resulting quantities
should be in `g*cm^2/s^2`. This is accomplished by defining a `Base.promote_rule`
for the units themselves. Here's an example.

```jldoctest
julia> using Unitful

julia> Base.promote_rule{S<:Unitful.EnergyUnit, T<:Unitful.EnergyUnit}(::Type{S}, ::Type{T}) = typeof(u"g*cm^2/s^2")

julia> promote(2.0u"J", 1.0u"kg*m^2/s^2")
(2.0e7 g cm^2 s^-2,1.0e7 g cm^2 s^-2)

julia> Base.promote_rule{S<:Unitful.EnergyUnit, T<:Unitful.EnergyUnit}(::Type{S}, ::Type{T}) = typeof(u"J")

julia> promote(2.0u"J", 1.0u"kg*m^2/s^2")
(2.0e7 g cm^2 s^-2,1.0e7 g cm^2 s^-2)
```

Notice how the first definition of `Base.promote_rule` had a permanent effect.
This is true of promotion rules for types defined in Base too; try defining a
new promotion rule for `Int` and `Float64` and you'll see it has no effect.

If you're wondering where `Unitful.EnergyUnit` comes from, it is defined in
`src/pkgdefaults.jl` by the [`@derived_dimension`](@ref) macro. Similarly,
the calls to the [`@dimension`](@ref) macro define `Unitful.LengthUnit`,
`Unitful.MassUnit`, etc. None of these are exported.

Existing users of Unitful may want to call [`Unitful.promote_to_derived`](@ref)
after Unitful loads to give similar behavior to Unitful 0.0.4 and below. It is
not called by default because otherwise users who want different behavior would
have to suffer through method redefinition warnings every time.

```@docs
Unitful.promote_to_derived
```

### Fallback promotion rules

The [`Unitful.preferunits`](@ref) function is used to designate fallback
preferred units for each pure dimension for promotion. Such a fallback is
required because you need some generic logic to take over when manipulating
quantities with arbitrary dimensions.

The default behavior is to promote to a combination of the base SI units, i.e.
a quantity of dimension `𝐌*𝐋^2/(𝐓^2*𝚯)` would be converted to `kg*m^2/(s^2*K)`:

```jldoctest
julia> promote(1.0u"J/K", 1.0u"g*cm^2/s^2/K")
(1.0 kg K^-1 m^2 s^-2,1.0e-7 kg K^-1 m^2 s^-2)
```

You can however override this behavior by calling [`Unitful.preferunits`](@ref)
at the start of a Julia session, specifically *before* `upreferred` *has been
called or quantities have been promoted*.

```@docs
Unitful.preferunits
```

### Array promotion

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

## Unit cancellation

For multiplication and division, note that powers-of-ten prefixes are significant
in unit cancellation. For instance, `mV/V` is not simplified, although `V/V` is.
Also, `N*m/J` is not simplified: there is currently no logic to decide
whether or not units on a dimensionless quantity seem "intentional" or not.
