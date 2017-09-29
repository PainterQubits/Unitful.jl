


<a id='Unitful-string-macro-1'></a>

## Unitful string macro

<a id='Unitful.@u_str' href='#Unitful.@u_str'>#</a>
**`Unitful.@u_str`** &mdash; *Macro*.



```
@u_str(unit)
```

String macro to easily recall units, dimensions, or quantities defined in unit modules that have been registered with [`Unitful.register`](manipulations.md#Unitful.register).

If the same symbol is used for a [`Unitful.Units`](types.md#Unitful.Units) object defined in different modules, then the symbol found in the most recently registered module will be used.

Note that what goes inside must be parsable as a valid Julia expression. In other words, u"N m" will fail if you intended to write u"N*m".

Examples:

```julia-repl
julia> 1.0u"m/s"
1.0 m s^-1

julia> 1.0u"N*m"
1.0 m N

julia> u"m,kg,s"
(m, kg, s)

julia> typeof(1.0u"m/s")
Quantity{Float64, Dimensions:{𝐋 𝐓^-1}, Units:{m s^-1}}

julia> u"ħ"
1.0545718001391127e-34 J s
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L296-L326' class='documenter-source'>source</a><br>

<a id='Unitful.register' href='#Unitful.register'>#</a>
**`Unitful.register`** &mdash; *Function*.



```
register(unit_module::Module)
```

Makes the [`@u_str`](manipulations.md#Unitful.@u_str) macro aware of units defined in new unit modules. By default, Unitful is itself a registered module. Note that Main is not, so if you define new units at the REPL, you will probably want to do `Unitful.register(Main)`.

Example:

```jl
# somewhere in a custom units package...
module MyUnitsPackage
using Unitful

function __init__()
    ...
    Unitful.register(MyUnitsPackage)
end
end #module
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/user.jl#L1-L19' class='documenter-source'>source</a><br>


<a id='Dimension-and-unit-inspection-1'></a>

## Dimension and unit inspection


We define a function [`dimension`](manipulations.md#Unitful.dimension-Tuple{Number}) that turns, for example, `acre^2` or `1*acre^2` into `𝐋^4`. We can usually add quantities with the same dimension, regardless of specific units (`FixedUnits` cannot be automatically converted, however). Note that dimensions cannot be determined by powers of the units: `ft^2` is an area, but so is `ac^1` (an acre).


There is also a function [`unit`](manipulations.md#Unitful.unit) that turns, for example, `1*acre^2` into `acre^2`. You can then query whether the units are `FreeUnits`, `FixedUnits`, etc.

<a id='Unitful.unit' href='#Unitful.unit'>#</a>
**`Unitful.unit`** &mdash; *Function*.



```
unit(x::Quantity{T,D,U}) where {T,D,U}
unit(x::Type{Quantity{T,D,U}}) where {T,D,U}
```

Returns the units associated with a `Quantity` or `Quantity` type.

Examples:

```julia-repl
julia> unit(1.0u"m") == u"m"
true

julia> unit(typeof(1.0u"m")) == u"m"
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L72-L86' class='documenter-source'>source</a><br>


```
unit(x::Number)
```

Returns a `Unitful.Units{(), Dimensions{()}}` object to indicate that ordinary numbers have no units. This is a singleton, which we export as `NoUnits`. The unit is displayed as an empty string.

Examples:

```julia-repl
julia> typeof(unit(1.0))
Unitful.FreeUnits{(),Unitful.Dimensions{()}}

julia> typeof(unit(Float64))
Unitful.FreeUnits{(),Unitful.Dimensions{()}}

julia> unit(1.0) == NoUnits
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L91-L109' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Tuple{Number}' href='#Unitful.dimension-Tuple{Number}'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension(x::Number)
dimension(x::Type{T}) where {T<:Number}
```

Returns a `Unitful.Dimensions{()}` object to indicate that ordinary numbers are dimensionless. This is a singleton, which we export as `NoDims`. The dimension is displayed as an empty string.

Examples:

```julia-repl
julia> typeof(dimension(1.0))
Unitful.Dimensions{()}
julia> typeof(dimension(Float64))
Unitful.Dimensions{()}
julia> dimension(1.0) == NoDims
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L113-L130' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Union{Tuple{D}, Tuple{Unitful.Units{U,D}}, Tuple{U}} where D where U' href='#Unitful.dimension-Union{Tuple{D}, Tuple{Unitful.Units{U,D}}, Tuple{U}} where D where U'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension(u::Units{U,D}) where {U,D}
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object corresponding to the dimensions of the units, `D()`. For a dimensionless combination of units, a `Unitful.Dimensions{()}` object is returned.

Examples:

```julia-repl
julia> dimension(u"m")
𝐋

julia> typeof(dimension(u"m"))
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}

julia> typeof(dimension(u"m/km"))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L134-L152' class='documenter-source'>source</a><br>


```
dimension(x::Quantity{T,D}) where {T,D}
dimension(::Type{Quantity{T,D,U}}) where {T,D,U}
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object `D()` corresponding to the dimensions of quantity `x`. For a dimensionless [`Unitful.Quantity`](types.md#Unitful.Quantity), a `Unitful.Dimensions{()}` object is returned.

Examples:

```julia-repl
julia> dimension(1.0u"m")
𝐋

julia> typeof(dimension(1.0u"m/μm"))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L155-L171' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Union{Tuple{D}, Tuple{T}, Tuple{Unitful.Quantity{T,D,U}}, Tuple{U}} where U where D where T' href='#Unitful.dimension-Union{Tuple{D}, Tuple{T}, Tuple{Unitful.Quantity{T,D,U}}, Tuple{U}} where U where D where T'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension(u::Units{U,D}) where {U,D}
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object corresponding to the dimensions of the units, `D()`. For a dimensionless combination of units, a `Unitful.Dimensions{()}` object is returned.

Examples:

```julia-repl
julia> dimension(u"m")
𝐋

julia> typeof(dimension(u"m"))
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}

julia> typeof(dimension(u"m/km"))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L134-L152' class='documenter-source'>source</a><br>


```
dimension(x::Quantity{T,D}) where {T,D}
dimension(::Type{Quantity{T,D,U}}) where {T,D,U}
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object `D()` corresponding to the dimensions of quantity `x`. For a dimensionless [`Unitful.Quantity`](types.md#Unitful.Quantity), a `Unitful.Dimensions{()}` object is returned.

Examples:

```julia-repl
julia> dimension(1.0u"m")
𝐋

julia> typeof(dimension(1.0u"m/μm"))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L155-L171' class='documenter-source'>source</a><br>

<a id='Unitful.dimension-Union{Tuple{AbstractArray{T,N} where N}, Tuple{T}} where T<:Unitful.Units' href='#Unitful.dimension-Union{Tuple{AbstractArray{T,N} where N}, Tuple{T}} where T<:Unitful.Units'>#</a>
**`Unitful.dimension`** &mdash; *Method*.



```
dimension(u::Units{U,D}) where {U,D}
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object corresponding to the dimensions of the units, `D()`. For a dimensionless combination of units, a `Unitful.Dimensions{()}` object is returned.

Examples:

```julia-repl
julia> dimension(u"m")
𝐋

julia> typeof(dimension(u"m"))
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}

julia> typeof(dimension(u"m/km"))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L134-L152' class='documenter-source'>source</a><br>


```
dimension(x::Quantity{T,D}) where {T,D}
dimension(::Type{Quantity{T,D,U}}) where {T,D,U}
```

Returns a [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object `D()` corresponding to the dimensions of quantity `x`. For a dimensionless [`Unitful.Quantity`](types.md#Unitful.Quantity), a `Unitful.Dimensions{()}` object is returned.

Examples:

```julia-repl
julia> dimension(1.0u"m")
𝐋

julia> typeof(dimension(1.0u"m/μm"))
Unitful.Dimensions{()}
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L155-L171' class='documenter-source'>source</a><br>


<a id='Unit-stripping-1'></a>

## Unit stripping

<a id='Unitful.ustrip' href='#Unitful.ustrip'>#</a>
**`Unitful.ustrip`** &mdash; *Function*.



```
ustrip(x::Number)
ustrip(x::Quantity)
```

Returns the number out in front of any units. The value of `x` may differ from the number out front of the units in the case of dimensionless quantities, e.g. `1m/mm != 1`. See [`uconvert`](conversion.md#Unitful.uconvert) and the example below. Because the units are removed, information may be lost and this should be used with some care.

This function is mainly intended for compatibility with packages that don't know how to handle quantities.

```julia-repl
julia> ustrip(2u"μm/m") == 2
true

julia> uconvert(NoUnits, 2u"μm/m") == 2//1000000
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L8-L26' class='documenter-source'>source</a><br>


```
ustrip(x::Array{Q}) where {Q <: Quantity}
```

Strip units from an `Array` by reinterpreting to type `T`. The resulting `Array` is a not a copy, but rather a unit-stripped view into array `x`. Because the units are removed, information may be lost and this should be used with some care.

This function is provided primarily for compatibility purposes; you could pass the result to PyPlot, for example.

```julia-repl
julia> a = [1u"m", 2u"m"]
2-element Array{Quantity{Int64, Dimensions:{𝐋}, Units:{m}},1}:
 1 m
 2 m

julia> b = ustrip(a)
2-element Array{Int64,1}:
 1
 2

julia> a[1] = 3u"m"; b
2-element Array{Int64,1}:
 3
 2
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L30-L55' class='documenter-source'>source</a><br>


```
ustrip(A::Diagonal)
ustrip(A::Bidiagonal)
ustrip(A::Tridiagonal)
ustrip(A::SymTridiagonal)
```

Strip units from various kinds of matrices by calling `ustrip` on the underlying vectors.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/utils.jl#L60-L66' class='documenter-source'>source</a><br>


<a id='Unit-multiplication-1'></a>

## Unit multiplication

<a id='Base.:*-Tuple{Unitful.Units,Vararg{Unitful.Units,N} where N}' href='#Base.:*-Tuple{Unitful.Units,Vararg{Unitful.Units,N} where N}'>#</a>
**`Base.:*`** &mdash; *Method*.



```
*(a0::Units, a::Units...)
```

Given however many units, multiply them together. This is actually handled by a few different methods, since we have `FreeUnits`, `ContextUnits`, and `FixedUnits`.

Collect [`Unitful.Unit`](types.md#Unitful.Unit) objects from the type parameter of the [`Unitful.Units`](types.md#Unitful.Units) objects. For identical units including SI prefixes (i.e. cm ≠ m), collect powers and sort uniquely by the name of the `Unit`. The unique sorting permits easy unit comparisons.

Examples:

```julia-repl
julia> u"kg*m/s^2"
kg m s^-2

julia> u"m/s*kg/s"
kg m s^-2

julia> typeof(u"m/s*kg/s") == typeof(u"kg*m/s^2")
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/units.jl#L60-L85' class='documenter-source'>source</a><br>

<a id='Base.:*-Tuple{Unitful.Dimensions,Vararg{Unitful.Dimensions,N} where N}' href='#Base.:*-Tuple{Unitful.Dimensions,Vararg{Unitful.Dimensions,N} where N}'>#</a>
**`Base.:*`** &mdash; *Method*.



```
*(a0::Dimensions, a::Dimensions...)
```

Given however many dimensions, multiply them together.

Collect [`Unitful.Dimension`](types.md#Unitful.Dimension) objects from the type parameter of the [`Unitful.Dimensions`](types.md#Unitful.Dimensions) objects. For identical dimensions, collect powers and sort uniquely by the name of the `Dimension`.

Examples:

```julia-repl
julia> u"𝐌*𝐋/𝐓^2"
𝐋 𝐌 𝐓^-2

julia> u"𝐋*𝐌/𝐓^2"
𝐋 𝐌 𝐓^-2

julia> typeof(u"𝐋*𝐌/𝐓^2") == typeof(u"𝐌*𝐋/𝐓^2")
true
```


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/36aa3a56bb77b57fbcf36ad89a3d779e0584dea2/src/dimensions.jl#L1-L21' class='documenter-source'>source</a><br>

