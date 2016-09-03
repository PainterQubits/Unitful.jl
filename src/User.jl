"""
```
macro dimension(symb, abbr, name)
```

Creates new dimensions. `name` will be used like an identifier in the type
parameter for a [`Unitful.Dimension`](@ref) object. `symb` will be a symbol
defined in the namespace from which this macro is called that is bound to a
[`Unitful.Dimensions`](@ref) object. For most intents and purposes it is this
object that the user would manipulate in doing dimensional analysis. The symbol
is not exported.

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
    uname = Symbol(name,"Unit")
    esc(quote
        Unitful.abbr(::Unitful.Dimension{$x}) = $abbr
        const $s = Unitful.Dimensions{(Unitful.Dimension{$x}(1),)}()
        typealias $(name) DimensionedQuantity{typeof($s)}
        typealias $(uname) DimensionedUnits{typeof($s)}
    end)
end

"""
```
macro derived_dimension(symb, dims)
```

Creates type aliases to allow dispatch on [`Unitful.Quantity`](@ref) objects
of a derived dimension, like area, which is just length squared. The type
aliases are not exported. `symb` is the name of the derived dimension and `dims`
is a [`Unitful.Dimensions`](@ref) object.

Usage examples:

- `@derived_dimension Area 𝐋^2`
- `@derived_dimension Speed 𝐋/𝐓`
"""
macro derived_dimension(name, dims)
    uname = Symbol(name,"Unit")
    esc(quote
        typealias ($name) DimensionedQuantity{typeof($dims)}
        typealias ($uname) DimensionedUnits{typeof($dims)}
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

Usage example: `@refunit m "m" Meter 𝐋 true`

This will generate `km`, `m`, `cm`, ...
"""
macro refunit(symb, abbr, name, dimension, tf)
    x = Expr(:quote, name)
    esc(quote
        Unitful.abbr(::Unitful.Unit{$x}) = $abbr
        Unitful.dimension(y::Unitful.Unit{$x}) = $dimension^y.power
        Unitful.basefactor(y::Unitful.Unit{$x}) = (1.0, 1)
        if $tf
            Unitful.@prefixed_unit_symbols $symb $name
        else
            Unitful.@unit_symbols $symb $name
        end
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
        t = Unitful.tensfactor(Unitful.unit($(esc(equals))))
        eq = ($(esc(equals)))/Unitful.unit($(esc(equals)))
        Base.isa(eq, Base.Integer) || Base.isa(eq, Base.Rational) ?
             (ex *= eq) : (inex *= eq)
        Unitful.abbr(::Unitful.Unit{$(esc(x))}) = $abbr
        Unitful.dimension(y::Unitful.Unit{$(esc(x))}) =
            Unitful.dimension($(esc(equals)))^y.power
        Unitful.basefactor(y::Unitful.Unit{$(esc(x))}) =
            Unitful.basefactorhelper(inex, ex, t, y.power)
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
will define units for each possible SI power-of-ten prefix on that unit.

Example: `@prefixed_unit_symbols m Meter` results in nm, cm, m, km, ...
all getting defined in the calling namespace.
"""
macro prefixed_unit_symbols(symb,name)
    expr = Expr(:block)

    z = Expr(:quote, name)
    for (k,v) in prefixdict
        s = Symbol(v,symb)
        u = Unitful.Unit{name}(k,1//1)
        ea = esc(quote
            const $s = Unitful.Units{($u,),typeof(dimension($u))}()
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
will define units without SI power-of-ten prefixes.

Example: `@unit_symbols ft Foot` results in `ft` getting defined but not `kft`.
"""
macro unit_symbols(symb,name)
    s = Symbol(symb)
    z = Expr(:quote, name)
    u = Unitful.Unit{name}(0,1//1)
    esc(quote
        const $s = Unitful.Units{($u,),typeof(dimension($u))}()
    end)
end

"""
```
defaults()
```

Includes the file `deps/Defaults.jl` from the Unitful package. This results in
common units and dimensions being generated in the `Unitful` module.
"""
function defaults()
    defpath = joinpath(Pkg.dir("Unitful"),"deps","Defaults.jl")
    include(defpath)
end

"""
```
macro u_str(unit)
```

String macro to easily recall units, dimensions, or quantities defined in the
Unitful module, which does not export such things to avoid namespace pollution.

Examples:

```jldoctest
1.0u"m/s"
# output
1.0 m s^-1
```
```jldoctest
typeof(1.0u"m/s")
# output
Unitful.Quantity{Float64,Unitful.Dimensions{(𝐋,𝐓^-1)},Unitful.Units{(m,s^-1)}}
```
```jldoctest
u"ħ"
# output
1.0545718001391127e-34 J s
```
"""
macro u_str(unit)
    ex = parse(unit)
    replace_value(ex)
end

const allowed_funcs = [:*, :/, :^, :sqrt, :√, :+, :-, ://]
function replace_value(ex::Expr)
    ex.head != :call && error("$(ex.head) != :call")
    ex.args[1] in allowed_funcs ||
        error("""$(ex.args[1]) is not a valid function call when parsing a unit.
         Only the following functions are allowed: $allowed_funcs""")
    for i=2:length(ex.args)
        if typeof(ex.args[i])==Symbol || typeof(ex.args[i])==Expr
            ex.args[i]=replace_value(ex.args[i])
        end
    end
    ex
end

replace_value(sym::Symbol) = :(ustrcheck($sym))
ustrcheck(x::Unitlike) = x
ustrcheck(x::Quantity) = x
ustrcheck(x) = error("Unexpected symbol in unit macro.")

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
