

<a id='Unitful.@u_str' href='#Unitful.@u_str'>#</a>
**`Unitful.@u_str`** &mdash; *Macro*.



```
macro u_str(unit)
```

String macro to easily recall units, dimensions, or quantities defined in the Unitful module, which does not export such things to avoid namespace pollution.

Examples:

```julia
1.0u"m/s"
# output
1.0 m s^-1
```

```julia
typeof(1.0u"m/s")
# output
Unitful.Quantity{Float64,Unitful.Dimensions{(𝐋,𝐓^-1)},Unitful.Units{(m,s^-1)}}
```

```julia
u"ħ"
# output
1.0545718001391127e-34 J s
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/User.jl#L182-L207' class='documenter-source'>source</a><br>

<a id='Unitful.unit' href='#Unitful.unit'>#</a>
**`Unitful.unit`** &mdash; *Function*.



```
unit{T,D,U}(x::Quantity{T,D,U})
```

Returns the units associated with a quantity, `U()`.

Examples:

```jlcon
julia> unit(1.0u"m") == u"m"
true

julia> typeof(u"m")
Unitful.Units{(m,)}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Unitful.jl#L28-L44' class='documenter-source'>source</a><br>


```
unit(x::Number)
```

Returns a `Unitful.Units{()}` object to indicate that ordinary numbers have no units. The unit is displayed as an empty string.

Examples:

```jlcon
julia> typeof(unit(1.0))
Unitful.Units{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Unitful.jl#L47-L61' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Number}' href='#Unitful.dimension-Tuple{Number}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension(x::Number)
```

Returns a `Unitful.Dimensions{()}` object to indicate that ordinary numbers are dimensionless. The dimension is displayed as an empty string.

Examples:

```jlcon
julia> typeof(dimension(1.0))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Unitful.jl#L64-L78' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Unitful.Units{N}}' href='#Unitful.dimension-Tuple{Unitful.Units{N}}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension{N}(u::Units{N})
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object corresponding to the dimensions of the units. For a dimensionless combination of units, a `Unitful.Dimensions{()}` object is returned.

Examples:

```jlcon
julia> dimension(u"m")
𝐋

julia> typeof(dimension(u"m"))
Unitful.Dimensions{(𝐋,)}

julia> typeof(dimension(u"m/km"))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Unitful.jl#L81-L102' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Unitful.Quantity{T,D,U}}' href='#Unitful.dimension-Tuple{Unitful.Quantity{T,D,U}}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension{T,D,U}(x::Quantity{T,D,U})
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object `D()` corresponding to the dimensions of quantity `x`. For a dimensionless [`Unitful.Quantity`](types.md#Unitful.Quantity), a `Unitful.Dimensions{()}` object is returned.

Examples:

```jlcon
julia> dimension(1.0u"m")
𝐋

julia> typeof(dimension(1.0u"m/μm"))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Unitful.jl#L106-L124' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{AbstractArray{T<:Unitful.Units,N}}' href='#Unitful.dimension-Tuple{AbstractArray{T<:Unitful.Units,N}}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension{T<:Units}(x::AbstractArray{T})
```

Just calls `map(dimension, x)`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Unitful.jl#L136-L142' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{AbstractArray{T<:Unitful.AbstractQuantity,N}}' href='#Unitful.dimension-Tuple{AbstractArray{T<:Unitful.AbstractQuantity,N}}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension{T<:AbstractQuantity}(x::AbstractArray{T})
```

Just calls `map(dimension, x)`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Unitful.jl#L127-L133' class='documenter-source'>source</a><br>

<a id='Base.:*-Tuple{Unitful.Unitlike,Vararg{Unitful.Unitlike,N}}' href='#Base.:*-Tuple{Unitful.Unitlike,Vararg{Unitful.Unitlike,N}}'>#</a>
**`Base.:*`** &mdash; *Method*.



```
*(a0::Unitlike, a::Unitlike...)
```

Given however many unit-like objects, multiply them together. Both [`Unitful.Dimensions`](types.md#Unitful.Dimensions) and [`Unitful.Units`](types.md#Unitful.Units) objects are considered to be `Unitlike` in the sense that you can multiply them, divide them, and collect powers. This function will fail if there is an attempt to multiply a unit by a dimension or vice versa.

Collect [`Unitful.Unit`](types.md#Unitful.Unit) objects from the type parameter of the [`Unitful.Units`](types.md#Unitful.Units) objects. For identical units including SI prefixes (i.e. cm ≠ m), collect powers and sort uniquely by the name of the `Unit`. The unique sorting permits easy unit comparisons.

Examples:

```jlcon
julia> u"kg*m/s^2"
kg m s^-2

julia> u"m/s*kg/s"
kg m s^-2

julia> typeof(u"kg*m/s^2")
Unitful.Units{(kg,m,s^-2)}

julia> typeof(u"m/s*kg/s") == typeof(u"kg*m/s^2")
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/c59bdb11355e215802e9746e8f67e07164437cce/src/Unitful.jl#L215-L246' class='documenter-source'>source</a><br>

