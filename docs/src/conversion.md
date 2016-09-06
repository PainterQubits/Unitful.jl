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

## Basic conversion and promotion mechanisms

We decide the result units for addition and subtraction operations based
on looking at the types only. We can't take runtime values into account
without compromising runtime performance. By default, if we have
`x (A) + y (B) = z (C)` where `x,y,z` are numbers and `A,B,C` are units,
then `C = max(1A, 1B)`. This is an arbitrary choice and can be changed at the
end of `deps/Defaults.jl`. For example, `101cm + 1m = 2.01m` because `1m > 1cm`.

Exact conversions between units are respected where possible. If rational
arithmetic would result in an overflow, then floating-point conversion should
proceed. File an issue if this does not work properly.

For dimensionless quantities, `uconvert` can be used to strip the units without
losing power-of-ten information:

```jldoctest
julia> uconvert(Unitful.NoUnits, 1.0u"μm/m")
1.0e-6

julia> uconvert(Unitful.NoUnits, 1.0u"m")
ERROR: Dimensional mismatch.
```

## Array promotion

Arrays are typed with as much specificity as possible upon creation. consider
the following three cases:

```jldoctest
julia> [1.0u"m", 2.0u"m"]
2-element Array{Unitful.Quantity{Float64,Unitful.Dimensions{(𝐋,)},Unitful.Units{(m,),Unitful.Dimensions{(𝐋,)}}},1}:
 1.0 m
 2.0 m

julia> [1.0u"m", 2.0u"cm"]
2-element Array{Unitful.Quantity{Float64,Unitful.Dimensions{(𝐋,)},Unitful.Units{(m,),Unitful.Dimensions{(𝐋,)}}},1}:
  1.0 m
 0.02 m

julia> [1.0u"m", 2.0]
2-element Array{Number,1}:
 1.0 m
     2.0
```

In the first case, an array with a concrete type can be created. Good
performance should be attainable. The second and third cases fall back to
increasingly abstract types, which cannot be stored efficiently and will
incur a performance penalty. The second case at least provides enough information
to permit dispatch on the dimensions of the array's elements:

```jldoctest
julia> f{T<:Unitful.Length}(x::AbstractArray{T}) = sum(x)
f (generic function with 1 method)

julia> f([1.0u"m", 2.0u"cm"])
1.02 m

julia> f([1.0u"g", 2.0u"cm"])
ERROR: MethodError: no method matching f(::Array{Number,1})
```

## Temperature conversion

If the dimension of a `Quantity` is purely temperature, then conversion
respects scale offsets. For instance, converting 0°C to °F returns the expected
result, 32°F. If instead temperature appears in combination with other units,
scale offsets don't make sense and we consider temperature *intervals*.
