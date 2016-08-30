


<a id='Converting-between-units-1'></a>

## Converting between units


Since `convert` in Julia already means something specific (conversion between Julia types), we define `uconvert` for conversion between units. Typically this will also involve a conversion between types, but this function takes care of figuring out which type is appropriate for representing the desired units.

<a id='Unitful.uconvert' href='#Unitful.uconvert'>#</a>
**`Unitful.uconvert`** &mdash; *Function*.



```
uconvert{T,D,U}(a::Units, x::Quantity{T,D,U})
```

Convert a [`Unitful.Quantity`](types.md#Unitful.Quantity) to different units. The conversion will fail if the target units `a` have a different dimension than the dimension of the quantity `x`. You can use this method to switch between equivalent representations of the same unit, like `N m` and `J`.

Example:

```jlcon
julia> uconvert(u"hr",3602u"s")
1801//1800 hr
julia> uconvert(u"J",1.0u"N*m")
1.0 J
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L1-L19' class='documenter-source'>source</a><br>


```
uconvert{T,U}(a::Units, x::Quantity{T,Dimensions{(Dimension{:Temperature}(1),)},U})
```

In this method, we are special-casing temperature conversion to respect scale offsets, if they do not appear in combination with other dimensions.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L32-L39' class='documenter-source'>source</a><br>


<a id='Conversion-and-promotion-mechanisms-1'></a>

## Conversion and promotion mechanisms


We decide the result units for addition and subtraction operations based on looking at the types only. We can't take runtime values into account without compromising runtime performance. By default, if we have `x (A) + y (B) = z (C)` where `x,y,z` are numbers and `A,B,C` are units, then `C = max(1A, 1B)`. This is an arbitrary choice and can be changed at the end of `deps/Defaults.jl`. For example, `101cm + 1m = 2.01m` because `1m > 1cm`.


Ultimately we hope to have this package play nicely with Julia's promotion mechanisms. A concern is that implicit promotion operations that were written with pure numbers in mind may give rise to surprising behavior without returning errors. We of course utilize Julia's promotion mechanisms for the numeric backing: adding an integer with units to a float with units produces the expected result.


```jlcon
julia> 1.0u"m"+1u"m"
2.0 m
```


Exact conversions between units are respected where possible. If rational arithmetic would result in an overflow, then floating-point conversion should proceed.


For dimensionless quantities, the usual `convert` methods can be used to strip the units without losing power-of-ten information:


```jlcon
julia> convert(Float64, 1.0u"μm/m")
1.0e-6

julia> convert(Complex{Float64}, 1.0u"μm/m")
1.0e-6 + 0.0im

julia> convert(Float64, 1.0u"m")
ERROR: Cannot convert a dimensionful quantity to a pure number.
```

<a id='Base.convert-Tuple{Type{Unitful.Quantity{T,D,U}},Unitful.Quantity}' href='#Base.convert-Tuple{Type{Unitful.Quantity{T,D,U}},Unitful.Quantity}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert{T,D,U}(::Type{Quantity{T,D,U}}, y::Quantity)
```

Direct type conversion using `convert` is permissible provided conversion is between two quantities of the same dimension.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L114-L121' class='documenter-source'>source</a><br>

<a id='Base.convert-Tuple{Type{Unitful.Quantity{T,Unitful.Dimensions{()},Unitful.Units{()}}},Unitful.Quantity}' href='#Base.convert-Tuple{Type{Unitful.Quantity{T,Unitful.Dimensions{()},Unitful.Units{()}}},Unitful.Quantity}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert{T}(::Type{UnitlessQuantity{T}}, x::Quantity)
```

Attempt conversion of `x` to a [`Unitful.UnitlessQuantity`](types.md#Unitful.UnitlessQuantity) type.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L134-L140' class='documenter-source'>source</a><br>

<a id='Base.convert-Tuple{Type{Unitful.Quantity{T,Unitful.Dimensions{()},Unitful.Units{()}}},Number}' href='#Base.convert-Tuple{Type{Unitful.Quantity{T,Unitful.Dimensions{()},Unitful.Units{()}}},Number}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert{T}(::Type{Quantity{T}}, x::Number)
```

Convert `x` to a [`Unitful.UnitlessQuantity`](types.md#Unitful.UnitlessQuantity) type.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L149-L155' class='documenter-source'>source</a><br>

<a id='Base.convert-Tuple{Type{Unitful.AbstractQuantity{T}},Unitful.Quantity}' href='#Base.convert-Tuple{Type{Unitful.AbstractQuantity{T}},Unitful.Quantity}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert{T}(::Type{AbstractQuantity{T}}, x::Quantity)
```

Converts the numeric backing type of `x` to type `T`. Units of `x` remain unchanged.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L159-L166' class='documenter-source'>source</a><br>

<a id='Base.convert-Tuple{Type{Unitful.AbstractQuantity{S}},Unitful.Quantity{T,Unitful.Dimensions{()},U}}' href='#Base.convert-Tuple{Type{Unitful.AbstractQuantity{S}},Unitful.Quantity{T,Unitful.Dimensions{()},U}}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert{S,T,U}(::Type{AbstractQuantity{S}}, x::DimensionlessQuantity{T,U})
```

Converts the numeric backing type of [`Unitful.DimensionlessQuantity`](types.md#Unitful.DimensionlessQuantity) `x` to type `T`. Units of `x` remain unchanged.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L170-L177' class='documenter-source'>source</a><br>

<a id='Base.convert-Tuple{Type{Unitful.AbstractQuantity{T}},Number}' href='#Base.convert-Tuple{Type{Unitful.AbstractQuantity{T}},Number}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert{T}(::Type{AbstractQuantity{T}}, x::Number)
```

Converts `x` to type `T` and then makes a [`Unitful.UnitlessQuantity`](types.md#Unitful.UnitlessQuantity) object.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L181-L188' class='documenter-source'>source</a><br>

<a id='Base.convert-Tuple{Type{Unitful.AbstractQuantity},Unitful.Quantity}' href='#Base.convert-Tuple{Type{Unitful.AbstractQuantity},Unitful.Quantity}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert(::Type{AbstractQuantity}, x::Quantity) = x
```

Pass through the `Quantity` `x`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L192-L198' class='documenter-source'>source</a><br>

<a id='Base.convert-Tuple{Type{Unitful.AbstractQuantity},Number}' href='#Base.convert-Tuple{Type{Unitful.AbstractQuantity},Number}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert(::Type{AbstractQuantity}, x::Number)
```

Convert `x` to a [`Unitful.UnitlessQuantity`](types.md#Unitful.UnitlessQuantity).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L201-L207' class='documenter-source'>source</a><br>

<a id='Base.convert-Tuple{Type{N<:Number},Unitful.Quantity}' href='#Base.convert-Tuple{Type{N<:Number},Unitful.Quantity}'>#</a>
**`Base.convert`** &mdash; *Method*.



```
convert{N<:Number}(::Type{N}, y::Quantity)
```

Convert a dimensionless `Quantity` `y` to type `N<:Number`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Conversion.jl#L211-L217' class='documenter-source'>source</a><br>


<a id='Temperature-conversion-1'></a>

## Temperature conversion


If the dimension of a `Quantity` is purely temperature, then conversion respects scale offsets. For instance, converting 0°C to °F returns the expected result, 32°F. If instead temperature appears in combination with other units, scale offsets don't make sense and we consider temperature *intervals*.

