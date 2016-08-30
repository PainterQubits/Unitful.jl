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

## Conversion and promotion mechanisms

We decide the result units for addition and subtraction operations based
on looking at the types only. We can't take runtime values into account
without compromising runtime performance. By default, if we have
`x (A) + y (B) = z (C)` where `x,y,z` are numbers and `A,B,C` are units,
then `C = max(1A, 1B)`. This is an arbitrary choice and can be changed at the
end of `deps/Defaults.jl`. For example, `101cm + 1m = 2.01m` because `1m > 1cm`.

Ultimately we hope to have this package play nicely with Julia's promotion mechanisms.
A concern is that implicit promotion operations that were written with
pure numbers in mind may give rise to surprising behavior without returning errors.
We of course utilize Julia's promotion mechanisms for the numeric backing:
adding an integer with units to a float with units produces the expected result.

```jldoctest
julia> 1.0u"m"+1u"m"
2.0 m
```

Exact conversions between units are respected where possible. If rational
arithmetic would result in an overflow, then floating-point conversion should
proceed.

For dimensionless quantities, the usual `convert` methods can be
used to strip the units without losing power-of-ten information:

```jldoctest
julia> convert(Float64, 1.0u"μm/m")
1.0e-6

julia> convert(Complex{Float64}, 1.0u"μm/m")
1.0e-6 + 0.0im

julia> convert(Float64, 1.0u"m")
ERROR: Cannot convert a dimensionful quantity to a pure number.
```

```@docs
convert{T,D,U}(::Type{Quantity{T,D,U}}, ::Quantity)
convert{T}(::Type{UnitlessQuantity{T}}, ::Quantity)
convert{T}(::Type{UnitlessQuantity{T}}, ::Number)
convert{T}(::Type{AbstractQuantity{T}}, ::Quantity)
convert{S}(::Type{AbstractQuantity{S}}, ::DimensionlessQuantity)
convert{T}(::Type{AbstractQuantity{T}}, ::Number)
convert(::Type{AbstractQuantity}, ::Quantity)
convert(::Type{AbstractQuantity}, ::Number)
convert{N<:Number,S,T}(::Type{N}, ::Quantity)
```

## Temperature conversion

If the dimension of a `Quantity` is purely temperature, then conversion
respects scale offsets. For instance, converting 0°C to °F returns the expected
result, 32°F. If instead temperature appears in combination with other units,
scale offsets don't make sense and we consider temperature *intervals*.
