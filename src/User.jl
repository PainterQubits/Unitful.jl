"""
```
macro dimension(symb, abbr, name)
```

Creates new dimensions. `name` will be used like an identifier in the type
parameter for a [`Unitful.Dimension`](@ref) object. `symb` will be a symbol
defined in the namespace from which this macro is called that is bound to a
[`Unitful.Dimensions`](@ref) object. For most intents and purposes it is this
object that the user would manipulate in doing dimensional analysis. The symbol
is exported.

This macro extends [`Unitful.abbr`](@ref) to display the new dimension in an
abbreviated format using the string `abbr`.

Finally, a type alias is created that allows to dispatch on
[`Unitful.Quantity`](@ref) objects of the newly defined dimension. The type alias
symbol is given by `name`.

Usage example: `@dimension 𝐋 "L" Length` (see `src/Defaults.jl`.)
"""
macro dimension(symb, abbr, name)
    s = Symbol(symb)
    x = Expr(:quote, name)
    esc(quote
        Unitful.abbr(::Unitful.Dimension{$x}) = $abbr
        const $s = Unitful.Dimensions{(Unitful.Dimension{$x}(1),)}()
        export $s
        typealias $(name){T,U}
            Quantity{T,Unitful.Dimensions{(Unitful.Dimension{$x}(1),)},U}
        export $(name)
    end)
end

"""
```
macro derived_dimension(symb, dims)
```

Creates type aliases to allow dispatch on [`Unitful.Quantity`](@ref) objects
of a derived dimension, like area, which is just length squared. The type
aliases are exported. `symb` is the name of the derived dimension and `dims`
is a [`Unitful.Dimensions`](@ref) object.

Usage examples:

- `@derived_dimension Area 𝐋^2`
- `@derived_dimension Speed 𝐋/𝐓`
"""
macro derived_dimension(symb, dims)
    esc(quote
        typealias ($symb){T,U}
            Quantity{T,typeof($dims),U}
        export $(symb)
    end)
end


"""
```
macro refunit(symb, name, abbr, dimension)
```

Define a reference unit, typically SI. Rather than define
conversion factors between each and every unit of a given dimension, conversion
factors are given between each unit and a reference unit, defined by this macro.

This macro extends [`Unitful.abbr`](@ref) so that the reference unit can be
displayed in an abbreviated format. It also generates symbols for every power
of ten of the unit, using the standard SI prefixes. A `dimension` must be given
([`Unitful.Dimensions`](@ref) object) that specifies the dimension of the
reference unit.

Usage example: `@refunit m "m" Meter 𝐋`

This will generate `km`, `m`, `cm`, ...
"""
macro refunit(symb, abbr, name, dimension)
    x = Expr(:quote, name)
    esc(quote
        Unitful.abbr(::Unitful.Unit{$x}) = $abbr
        Unitful.dimension(y::Unitful.Unit{$x}) = $dimension^y.power
        Unitful.basefactor(::Unitful.Unit{$x}) = (1.0, 1)
        Unitful.@prefixed_unit_symbols $symb $name
    end)
end

"""
```
macro unit(symb,abbr,name,equals,tf)
```

Define a unit. Rather than specifying a dimension like in [`@refunit`](@ref),
`equals` should be a [`Unitful.Quantity`](@ref) equal to one of the unit being
defined. The last argument `tf::Bool` should be `true` if symbols should be
made for each power-of-ten prefix, otherwise `false`.

Usage example: `@unit mi "mi" Mile (201168//125)*m false`

This will *not* generate `kmi` (kilomiles).
"""
macro unit(symb,abbr,name,equals,tf)
    # name is a symbol
    # abbr is a string
    x = Expr(:quote, name)
    quote
        inex, ex = Unitful.basefactor(Unitful.unit($(esc(equals))))
        eq = Unitful.unitless($(esc(equals)))
        Base.isa(eq, Base.Integer) || Base.isa(eq, Base.Rational) ?
             (ex *= eq) : (inex *= eq)
        Unitful.abbr(::Unitful.Unit{$(esc(x))}) = $abbr
        Unitful.dimension(y::Unitful.Unit{$(esc(x))}) =
            Unitful.dimension($(esc(equals)))^y.power
        Unitful.basefactor(y::Unitful.Unit{$(esc(x))}) =
            Unitful.basefactorhelper(inex, ex, y.power)
        if $tf
            Unitful.@prefixed_unit_symbols $(esc(symb)) $(esc(name))
        else
            Unitful.@unit_symbols $(esc(symb)) $(esc(name))
        end
    end
end

"""
```
macro prefixed_unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name,
will define and export units for each possible SI power-of-ten prefix on that
unit.

Example: `@prefixed_unit_symbols m Meter` results in nm, cm, m, km, ...
all getting defined and exported in the calling namespace.
"""
macro prefixed_unit_symbols(symb,name)
    expr = Expr(:block)

    z = Expr(:quote, name)
    for (k,v) in prefixdict
        s = Symbol(v,symb)
        ea = esc(quote
            const $s = Unitful.Units{(Unitful.Unit{$z}($k,1//1),)}()
            export $s
        end)
        push!(expr.args, ea)
    end

    expr
end

"""
```
macro unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name,
will define and export units without SI power-of-ten prefixes.

Example: `@unit_symbols ft Foot` results in `ft` getting defined but not `kft`.
"""
macro unit_symbols(symb,name)
    s = Symbol(symb)
    z = Expr(:quote, name)
    esc(quote
        const $s = Unitful.Units{(Unitful.Unit{$z}(0,1//1),)}()
        export $s
    end)
end

"""
```
defaults()
```

Includes the file `src/Defaults.jl` from the Unitful package. This results in
common units and dimensions being generated in the `Main` module.
"""
defaults() = include(joinpath(Pkg.dir("Unitful"),"src","Defaults.jl"))

"""
```
basefactor(x::Unit)
```

Specifies conversion factors to reference units.
It returns a tuple. The first value is any irrational part of the conversion,
and the second value is a rational component. This segregation permits exact
conversions within unit systems that have no rational conversion to the
reference units.
"""
function basefactor end

"""
```
dimension(x::Unit)
```

Returns a [`Unitful.Dimensions`](@ref) object describing the given unit `x`.
"""
function dimension end
