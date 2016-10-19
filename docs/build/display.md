<a id='Unitful.abbr' href='#Unitful.abbr'>#</a>
**`Unitful.abbr`** &mdash; *Function*.



`abbr(x)` provides abbreviations for units or dimensions. Since a method should always be defined for each unit and dimension type, absence of a method for a specific unit or dimension type is likely an error. Consequently, we return ❓ for generic arguments to flag unexpected behavior.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f73bc51dd8c5dd9f645fd55c96e4fdc4ed14858e/src/Display.jl#L26-L31' class='documenter-source'>source</a><br>

<a id='Unitful.prefix' href='#Unitful.prefix'>#</a>
**`Unitful.prefix`** &mdash; *Function*.



```
prefix(x::Unit)
```

Returns a string representing the SI prefix for the power-of-ten held by this particular unit.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f73bc51dd8c5dd9f645fd55c96e4fdc4ed14858e/src/Display.jl#L34-L41' class='documenter-source'>source</a><br>

<a id='Base.show-Tuple{IO,Unitful.Quantity}' href='#Base.show-Tuple{IO,Unitful.Quantity}'>#</a>
**`Base.show`** &mdash; *Method*.



```
show(io::IO, x::Quantity)
```

Show a unitful quantity by calling `show` on the numeric value, appending a space, and then calling `show` on a units object `U()`.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f73bc51dd8c5dd9f645fd55c96e4fdc4ed14858e/src/Display.jl#L50-L57' class='documenter-source'>source</a><br>

<a id='Base.show-Tuple{IO,Type{Unitful.Quantity{T,D,U}}}' href='#Base.show-Tuple{IO,Type{Unitful.Quantity{T,D,U}}}'>#</a>
**`Base.show`** &mdash; *Method*.



```
show{T,D,U}(io::IO, ::Type{Quantity{T,D,U}})
```

Show the type of a unitful quantity in a succinct way. Otherwise, array summaries are nearly unreadable.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f73bc51dd8c5dd9f645fd55c96e4fdc4ed14858e/src/Display.jl#L67-L74' class='documenter-source'>source</a><br>

<a id='Base.show-Tuple{IO,Unitful.Unitlike}' href='#Base.show-Tuple{IO,Unitful.Unitlike}'>#</a>
**`Base.show`** &mdash; *Method*.



```
show(io::IO,x::Unitlike)
```

Call [`Unitful.showrep`](display.md#Unitful.showrep-Tuple{IO,Unitful.Unit}) on each object in the tuple that is the type variable of a [`Unitful.Units`](types.md#Unitful.Units) or [`Unitful.Dimensions`](types.md#Unitful.Dimensions) object.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f73bc51dd8c5dd9f645fd55c96e4fdc4ed14858e/src/Display.jl#L82-L89' class='documenter-source'>source</a><br>

<a id='Unitful.showrep-Tuple{IO,Unitful.Unit}' href='#Unitful.showrep-Tuple{IO,Unitful.Unit}'>#</a>
**`Unitful.showrep`** &mdash; *Method*.



```
showrep(io::IO, x::Unit)
```

Show the unit, prefixing with any decimal prefix and appending the exponent as formatted by [`Unitful.superscript`](display.md#Unitful.superscript).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f73bc51dd8c5dd9f645fd55c96e4fdc4ed14858e/src/Display.jl#L101-L108' class='documenter-source'>source</a><br>

<a id='Unitful.showrep-Tuple{IO,Unitful.Dimension}' href='#Unitful.showrep-Tuple{IO,Unitful.Dimension}'>#</a>
**`Unitful.showrep`** &mdash; *Method*.



```
showrep(io::IO, x::Dimension)
```

Show the dimension, appending any exponent as formatted by [`Unitful.superscript`](display.md#Unitful.superscript).


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f73bc51dd8c5dd9f645fd55c96e4fdc4ed14858e/src/Display.jl#L116-L123' class='documenter-source'>source</a><br>

<a id='Unitful.superscript' href='#Unitful.superscript'>#</a>
**`Unitful.superscript`** &mdash; *Function*.



```
superscript(i::Rational)
```

Prints exponents.


<a target='_blank' href='https://github.com/ajkeller34/Unitful.jl/tree/f73bc51dd8c5dd9f645fd55c96e4fdc4ed14858e/src/Display.jl#L129-L135' class='documenter-source'>source</a><br>

