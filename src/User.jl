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

Finally, type aliases are created that allow the user to dispatch on
[`Unitful.Quantity`](@ref) and [`Unitful.Units`](@ref) objects of the newly
defined dimension. The type alias for quantities is simply given by `name`,
and the type alias for units is given by `name*"Unit"`, e.g. `LengthUnit`.

Usage example: `@dimension 𝐋 "L" Length` (see `src/Defaults.jl`.)
"""
macro dimension(symb, abbr, name)
    s = Symbol(symb)
    x = Expr(:quote, name)
    uname = Symbol(name,"Unit")
    esc(quote
        Unitful.abbr(::Unitful.Dimension{$x}) = $abbr
        const $s = Unitful.Dimensions{(Unitful.Dimension{$x}(1),)}()
        typealias $(name){T,U} Quantity{T,typeof($s),U}
        typealias $(uname){U} Units{U,typeof($s)}
    end)
end

"""
```
macro derived_dimension(name, dims)
```

Creates type aliases to allow dispatch on [`Unitful.Quantity`](@ref) and
[`Unitful.Units`](@ref) objects of a derived dimension, like area, which is just
length squared. The type aliases are not exported.

`dims` is a [`Unitful.Dimensions`](@ref) object.

Usage examples:

- `@derived_dimension Area 𝐋^2` gives `Area` and `AreaUnit` type aliases
- `@derived_dimension Speed 𝐋/𝐓` gives `Speed` and `SpeedUnit` type aliases
"""
macro derived_dimension(name, dims)
    uname = Symbol(name,"Unit")
    esc(quote
        typealias ($name){T,U} Quantity{T,typeof($dims),U}
        typealias ($uname){U} Units{U,typeof($dims)}
    end)
end


"""
```
macro refunit(symb, name, abbr, dimension, tf)
```

Define a reference unit, typically SI. Rather than define
conversion factors between each and every unit of a given dimension, conversion
factors are given between each unit and a reference unit, defined by this macro.

This macro extends [`Unitful.abbr`](@ref) so that the reference unit can be
displayed in an abbreviated format. If `tf == true`, this macro generates symbols
for every power of ten of the unit, using the standard SI prefixes. A `dimension`
must be given ([`Unitful.Dimensions`](@ref) object) that specifies the dimension
of the reference unit.

Usage example: `@refunit m "m" Meter 𝐋 true`

This example will generate `km`, `m`, `cm`, ...
"""
macro refunit(symb, abbr, name, dimension, tf)
    x = Expr(:quote, name)
    esc(quote
        Unitful.abbr(::Unitful.Unit{$x,typeof($dimension)}) = $abbr
        if $tf
            Unitful.@prefixed_unit_symbols $symb $name $dimension (1.0, 1)
        else
            Unitful.@unit_symbols $symb $name $dimension (1.0, 1)
        end
    end)
end

"""
```
macro preferunit(unit)
```

This macro specifies the default unit for promotion for a given dimension,
which is inferred from the given unit. All invocations of this macro must
occur before promotion is done, or before [`Unitful.upreferred`](@ref) is called.

Usage example: `@preferunit kg`
"""
macro preferunit(unit)
    quote
        dim = dimension($unit)
        if length(typeof(dim).parameters[1]) > 1
            error("@prefer can only be used with a unit that has a pure ",
            "dimension, like 𝐋 or 𝐓 but not 𝐋/𝐓.")
        end
        if length(typeof(dim).parameters[1]) == 1 &&
            typeof(dim).parameters[1][1].power != 1
            error("@prefer cannot handle powers of pure dimensions except 1. ",
            "For instance, it should not be used with units of dimension 𝐋^2.")
        end
        Unitful.dim2refunits(y::typeof(typeof(dim).parameters[1][1])) =
            $unit^y.power
    end
end

# Generated to force a concrete result type.
@generated function dim2refunits(x::Dimensions)
    dim = x.parameters[1]
    y = mapreduce(dim2refunits, *, NoUnits, dim)
    :($y)
end

"""
```
upreferred(x::Number)
```

Unit-convert `x` to units which are preferred for the dimensions of `x`,
as specified by the [`@preferunit`](@ref) macro. If you are using the factory
defaults in `deps/Defaults.jl`, this function will unit-convert to a product of
powers of base SI units.
"""
upreferred(x::Number) = uconvert(dim2refunits(dimension(x)), x)

"""
```
upreferred(x::Units)
```

Return units which are preferred for the dimensions of `x`, which may or may
not be equal to `x`, as specified by the [`@preferunit`](@ref) macro. If you are
using the factory defaults in `deps/Defaults.jl`, this function will return a
product of powers of base SI units.
"""
upreferred(x::Units) = dim2refunits(dimension(x))

"""
```
upreferred(x::Dimensions)
```

Return units which are preferred for dimensions `x`. If you are
using the factory defaults in `deps/Defaults.jl`, this function will return a
product of powers of base SI units.
"""
upreferred(x::Dimensions) = dim2refunits(x)

"""
```
macro unit(symb,abbr,name,equals,tf)
```

Define a unit. Rather than specifying a dimension like in [`@refunit`](@ref),
`equals` should be a [`Unitful.Quantity`](@ref) equal to one of the unit being
defined. If `tf == true`, symbols will be made for each power-of-ten prefix.

Usage example: `@unit mi "mi" Mile (201168//125)*m false`

This example will *not* generate `kmi` (kilomiles).
"""
macro unit(symb,abbr,name,equals,tf)
    # name is a symbol
    # abbr is a string
    x = Expr(:quote, name)
    quote
        d = Unitful.dimension($(esc(equals)))
        inex, ex = Unitful.basefactor(Unitful.unit($(esc(equals))))
        t = Unitful.tensfactor(Unitful.unit($(esc(equals))))
        eq = ($(esc(equals)))/Unitful.unit($(esc(equals)))
        Base.isa(eq, Base.Integer) || Base.isa(eq, Base.Rational) ?
             (ex *= eq) : (inex *= eq)
        Unitful.abbr(::Unitful.Unit{$(esc(x)),typeof(d)}) = $abbr
        if $tf
            Unitful.@prefixed_unit_symbols($(esc(symb)), $(esc(name)), d,
                Unitful.basefactor(inex, ex, t, 1))
        else
            Unitful.@unit_symbols($(esc(symb)), $(esc(name)), d,
                Unitful.basefactor(inex, ex, t, 1))
        end
    end
end

"""
```
macro prefixed_unit_symbols(symb,name,dimension,basefactor)
```

Not called directly by the user. Given a unit symbol and a unit's name,
will define units for each possible SI power-of-ten prefix on that unit.

Example: `@prefixed_unit_symbols m Meter 𝐋 (1.0,1)` results in nm, cm, m, km, ...
all getting defined in the calling namespace.
"""
macro prefixed_unit_symbols(symb,name,dimension,basefactor)
    expr = Expr(:block)

    z = Expr(:quote, name)
    for (k,v) in prefixdict
        s = Symbol(v,symb)
        u = :(Unitful.Unit{$z, typeof($dimension)}($k,1//1))
        ea = esc(quote
            Unitful.basefactors[$z] = $basefactor
            const $s = Unitful.Units{($u,),typeof(dimension($u))}()
        end)
        push!(expr.args, ea)
    end

    # These lines allow for μ to be typed with option-m on a Mac.
    s = Symbol(:µ, symb)
    u = :(Unitful.Unit{$z, typeof($dimension)}(-6,1//1))
    push!(expr.args, esc(quote
        Unitful.basefactors[$z] = $basefactor
        const $s = Unitful.Units{($u,),typeof(dimension($u))}()
    end))

    expr
end

"""
```
macro unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name,
will define units without SI power-of-ten prefixes.

Example: `@unit_symbols ft Foot 𝐋` results in `ft` getting defined but not `kft`.
"""
macro unit_symbols(symb,name,dimension,basefactor)
    s = Symbol(symb)
    z = Expr(:quote, name)
    u = :(Unitful.Unit{$z,typeof($dimension)}(0,1//1))
    esc(quote
        Unitful.basefactors[$z] = $basefactor
        const $s = Unitful.Units{($u,),typeof(dimension($u))}()
    end)
end

"""
```
macro u_str(unit)
```

String macro to easily recall units, dimensions, or quantities defined in the
Unitful module, which does not export such things to avoid namespace pollution.
Note that for now, what goes inside must be parsable as a valid Julia expression.
In other words, u"N m" will fail if you intended to write u"N*m".

Examples:

```jldoctest
julia> 1.0u"m/s"
1.0 m s^-1

julia> 1.0u"N*m"
1.0 m N

julia> typeof(1.0u"m/s")
Quantity{Float64, Dimensions:{𝐋 𝐓^-1}, Units:{m s^-1}}

julia> u"ħ"
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
