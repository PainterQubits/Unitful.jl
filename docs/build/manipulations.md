<a id='Unitful.@u_str' href='#Unitful.@u_str'>#</a>
**`Unitful.@u_str`** &mdash; *Macro*.



```
macro u_str(unit)
```

String macro to easily recall units, dimensions, or quantities defined in the Unitful module, which does not export such things to avoid namespace pollution. For those unfamiliar with string macros, see the following example.

Example: `1.0u"m/s"` returns 1.0 m/s.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/06d4a308cfa504ba08b937a778bd9ada4930fab4/src/User.jl#L178-L188' class='documenter-source'>source</a><br>

<a id='Unitful.unit' href='#Unitful.unit'>#</a>
**`Unitful.unit`** &mdash; *Function*.



```
unit{T,D,U}(x::Quantity{T,D,U})
```

Returns the units associated with a quantity, `U()`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/06d4a308cfa504ba08b937a778bd9ada4930fab4/src/Unitful.jl#L27-L33' class='documenter-source'>source</a><br>


```
unit(x::Number)
```

Returns a `Unitful.Units{()}` object to indicate that ordinary numbers have no units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/06d4a308cfa504ba08b937a778bd9ada4930fab4/src/Unitful.jl#L36-L43' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Number}' href='#Unitful.dimension-Tuple{Number}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension(x::Number)
```

Returns a `Unitful.Dimensions{()}` object to indicate that ordinary numbers are dimensionless.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/06d4a308cfa504ba08b937a778bd9ada4930fab4/src/Unitful.jl#L46-L53' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Unitful.Units{N}}' href='#Unitful.dimension-Tuple{Unitful.Units{N}}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension{N}(u::Units{N})
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object corresponding to the dimensions of the units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/06d4a308cfa504ba08b937a778bd9ada4930fab4/src/Unitful.jl#L56-L63' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Unitful.Quantity{T,D,U}}' href='#Unitful.dimension-Tuple{Unitful.Quantity{T,D,U}}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension{T,D,U}(x::Quantity{T,D,U})
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object `D()` corresponding to the dimensions of quantity `x`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/06d4a308cfa504ba08b937a778bd9ada4930fab4/src/Unitful.jl#L66-L73' class='documenter-source'>source</a><br>

<a id='Base.:*-Tuple{Unitful.Unitlike,Vararg{Unitful.Unitlike,N}}' href='#Base.:*-Tuple{Unitful.Unitlike,Vararg{Unitful.Unitlike,N}}'>#</a>
**`Base.:*`** &mdash; *Method*.



```
*(a0::Unitlike, a::Unitlike...)
```

Given however many unit-like objects, multiply them together. The following applies equally well to `Dimensions` instead of `Units`.

Collect [`Unitful.Unit`](types.md#Unitful.Unit) objects from the type parameter of the [`Unitful.Units`](types.md#Unitful.Units) objects. For identical units including SI prefixes (i.e. cm ≠ m), collect powers and sort uniquely by the name of the unit. The unique sorting permits easy unit comparisons.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/06d4a308cfa504ba08b937a778bd9ada4930fab4/src/Unitful.jl#L140-L152' class='documenter-source'>source</a><br>

