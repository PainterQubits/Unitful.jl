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
        abbr(::Dimension{$x}) = $abbr
        const $s = Dimensions{(Dimension{$x}(1),)}()
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

# Convenient dictionary for mapping powers of ten to an SI prefix.
const prefixdict = Dict(
    -24 => "y",
    -21 => "z",
    -18 => "a",
    -15 => "f",
    -12 => "p",
    -9  => "n",
    -6  => "μ",     # tab-complete \mu, not option-m on a Mac!
    -3  => "m",
    -2  => "c",
    -1  => "d",
    0   => "",
    1   => "da",
    2   => "h",
    3   => "k",
    6   => "M",
    9   => "G",
    12  => "T",
    15  => "P",
    18  => "E",
    21  => "Z",
    24  => "Y"
)

"""
```
prefixed_unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name,
will define units for each possible SI power-of-ten prefix on that unit.

Example: `prefixed_unit_symbols(m, Meter)` results in nm, cm, m, km, ...
all getting defined in the calling namespace.
"""
function prefixed_unit_symbols(symb,name)
    expr = Expr(:block)

    z = Expr(:quote, name)
    for (k,v) in prefixdict
        s = Symbol(v,symb)
        u = Unit{name}(k,1//1)
        ea = quote
            const $s = Units{($u,),typeof(dimension($u))}()
        end
        push!(expr.args, ea)
    end

    # These lines allow for μ to be typed with option-m on a Mac.
    s = Symbol(:µ, symb)
    u = Unit{name}(-6,1//1)
    push!(expr.args, quote
        const $s = Units{($u,),typeof(dimension($u))}()
    end)

    expr
end

"""
```
unit_symbols(symb,name)
```

Not called directly by the user. Given a unit symbol and a unit's name,
will define units without SI power-of-ten prefixes.

Example: `unit_symbols(ft, Foot)` results in `ft` getting defined but not `kft`.
"""
function unit_symbols(symb,name)
    s = Symbol(symb)
    z = Expr(:quote, name)
    u = Unit{name}(0,1//1)
    quote
        const $s = Units{($u,),typeof(dimension($u))}()
    end
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
    if tf
        symbols = prefixed_unit_symbols(symb, name)
    else
        symbols = unit_symbols(symb, name)
    end
    output = esc(quote
        abbr(::Unit{$x}) = $abbr
        dimension(y::Unit{$x}) = $dimension^y.power
        basefactor(y::Unit{$x}) = (1.0, 1)
        $symbols
    end)
    output
end

"""
```
macro preferunit(unit)
```

This macro specifies the default unit for promotion for a given dimension,
which is inferred from the given unit.

Usage example: `@preferunit kg`
"""
macro preferunit(unit)
    dim = eval(current_module(), :(dimension($unit)))
    if length(typeof(dim).parameters[1]) > 1
        error("@prefer can only be used with a unit that has a pure ",
        "dimension, like 𝐋 or 𝐓 but not 𝐋/𝐓.")
    end
    if length(typeof(dim).parameters[1]) == 1 &&
        typeof(dim).parameters[1][1].power != 1
        error("@prefer cannot handle powers of pure dimensions except 1. ",
        "For instance, it should not be used with units of dimension 𝐋^2.")
    end
    T = typeof(typeof(dim).parameters[1][1])
    esc(quote
        dim2refunits(y::$T) = $unit^y.power
    end)
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
    inex, ex = eval(current_module(), :(basefactor(unit($equals))))
    t = eval(current_module(), :(tensfactor(unit($equals))))
    eq = eval(current_module(), :($equals/unit($equals)))
    Base.isa(eq, Base.Integer) || Base.isa(eq, Base.Rational) ?
        (ex *= eq) : (inex *= eq)
    if tf
        symbols = prefixed_unit_symbols(symb, name)
    else
        symbols = unit_symbols(symb, name)
    end
    esc(quote
        abbr(::Unit{$x}) = $abbr
        dimension(y::Unit{$x}) =
            dimension($equals)^y.power
        basefactor(y::Unit{$x}) =
            basefactorhelper($inex, $ex, $t, y.power)
        $symbols
    end)
end

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
