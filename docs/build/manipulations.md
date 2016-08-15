<a id='Unitful.@u_str' href='#Unitful.@u_str'>#</a>
**`Unitful.@u_str`** &mdash; *Macro*.



```
macro u_str(unit)
```

String macro to easily recall units, dimensions, or quantities defined in the Unitful module, which does not export such things to avoid namespace pollution. For those unfamiliar with string macros, see the following example.

Example: `1.0u"m/s"` returns 1.0 m/s.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/User.jl#L178-L188' class='documenter-source'>source</a><br>

<a id='Unitful.unit' href='#Unitful.unit'>#</a>
**`Unitful.unit`** &mdash; *Function*.



```
unit{T,D,U}(x::Quantity{T,D,U})
```

Returns the units associated with a quantity, `U()`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/Unitful.jl#L45-L51' class='documenter-source'>source</a><br>


```
unit(x::Number)
```

Returns a `Unitful.Units{()}` object to indicate that ordinary numbers have no units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/Unitful.jl#L54-L61' class='documenter-source'>source</a><br>

<a id='Unitful.unitless' href='#Unitful.unitless'>#</a>
**`Unitful.unitless`** &mdash; *Function*.



```
unitless(x::Quantity)
```

Strip units from a quantity and return the numeric value.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/Unitful.jl#L27-L33' class='documenter-source'>source</a><br>


```
unitless(x::Number)
```

Returns `x`, since ordinary numbers have no units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/Unitful.jl#L36-L42' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Number}' href='#Unitful.dimension-Tuple{Number}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension(x::Number)
```

Returns a `Unitful.Dimensions{()}` object to indicate that ordinary numbers are dimensionless.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/Unitful.jl#L64-L71' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Unitful.Units{N}}' href='#Unitful.dimension-Tuple{Unitful.Units{N}}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension{N}(u::Units{N})
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object corresponding to the dimensions of the units.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/Unitful.jl#L74-L81' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Unitful.Quantity{T,D,U}}' href='#Unitful.dimension-Tuple{Unitful.Quantity{T,D,U}}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension{T,D,U}(x::Quantity{T,D,U})
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object `D()` corresponding to the dimensions of quantity `x`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/Unitful.jl#L84-L91' class='documenter-source'>source</a><br>

<a id='Base.:*-Tuple{Unitful.Unitlike,Vararg{Unitful.Unitlike,N}}' href='#Base.:*-Tuple{Unitful.Unitlike,Vararg{Unitful.Unitlike,N}}'>#</a>
**`Base.:*`** &mdash; *Method*.



```
*(a0::Unitlike, a::Unitlike...)
```

Given however many unit-like objects, multiply them together. The following applies equally well to `Dimensions` instead of `Units`.

Collect [`Unitful.Unit`](types.md#Unitful.Unit) objects from the type parameter of the [`Unitful.Units`](types.md#Unitful.Units) objects. For identical units including SI prefixes (i.e. cm ≠ m), collect powers and sort uniquely by the name of the unit. The unique sorting permits easy unit comparisons.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/9daa104a4fb14faf29e7a146ad5d7d81884a7849/src/Unitful.jl#L158-L170' class='documenter-source'>source</a><br>

