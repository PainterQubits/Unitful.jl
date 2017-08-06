"""
    register(unit_module::Module)
Makes the [`@u_str`](@ref) macro aware of units defined in new unit modules. By default,
Unitful is itself a registered module. Note that Main is not, so if you define new units
at the REPL, you will probably want to do `Unitful.register(Main)`.

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
"""
register(unit_module::Module) = push!(Unitful.unitmodules, unit_module)

"""
    @dimension(symb, abbr, name)
Creates new dimensions. `name` will be used like an identifier in the type
parameter for a [`Unitful.Dimension`](@ref) object. `symb` will be a symbol
defined in the namespace from which this macro is called that is bound to a
[`Unitful.Dimensions`](@ref) object. For most intents and purposes it is this
object that the user would manipulate in doing dimensional analysis. The symbol
is not exported.

This macro extends [`Unitful.abbr`](@ref) to display the new dimension in an
abbreviated format using the string `abbr`.

Type aliases are created that allow the user to dispatch on
[`Unitful.Quantity`](@ref) and [`Unitful.Units`](@ref) objects of the newly
defined dimension. The type alias for quantities is simply given by `name`,
and the type alias for units is given by `name*"Units"`, e.g. `LengthUnits`.
Note that there is also `LengthFreeUnits`, for example, which is an alias for
dispatching on `FreeUnits` with length dimensions. The aliases are not exported.

Finally, if you define new dimensions with [`@dimension`](@ref) you will need
to specify a preferred unit for that dimension with [`Unitful.preferunits`](@ref),
otherwise promotion will not work with that dimension. This is done automatically
in the [`@refunit`](@ref) macro.

Returns the `Dimensions` object to which `symb` is bound.

Usage example from `src/pkgdefaults.jl`: `@dimension 𝐋 "𝐋" Length`
"""
macro dimension(symb, abbr, name)
    s = Symbol(symb)
    x = Expr(:quote, name)
    uname = Symbol(name,"Units")
    uname_old = Symbol(name,"Unit")
    funame = Symbol(name,"FreeUnits")
    esc(quote
        Unitful.abbr(::Unitful.Dimension{$x}) = $abbr
        const $s = Unitful.Dimensions{(Unitful.Dimension{$x}(1),)}()
        const ($name){T,U} = Unitful.Quantity{T,typeof($s),U}
        const ($uname){U} = Unitful.Units{U,typeof($s)}
        const ($uname_old){U} = Unitful.Units{U,typeof($s)}
        const ($funame){U} = Unitful.FreeUnits{U,typeof($s)}
        $s
    end)
end

"""
    @derived_dimension(name, dims)
Creates type aliases to allow dispatch on [`Unitful.Quantity`](@ref) and
[`Unitful.Units`](@ref) objects of a derived dimension, like area, which is just
length squared. The type aliases are not exported.

`dims` is a [`Unitful.Dimensions`](@ref) object.

Returns `nothing`.

Usage examples:

- `@derived_dimension Area 𝐋^2` gives `Area` and `AreaUnit` type aliases
- `@derived_dimension Speed 𝐋/𝐓` gives `Speed` and `SpeedUnit` type aliases
"""
macro derived_dimension(name, dims)
    uname = Symbol(name,"Units")
    uname_old = Symbol(name,"Unit")
    funame = Symbol(name,"FreeUnits")
    esc(quote
        const ($name){T,U} = Unitful.Quantity{T,typeof($dims),U}
        const ($uname){U} = Unitful.Units{U,typeof($dims)}
        const ($uname_old){U} = Unitful.Units{U,typeof($dims)}
        const ($funame){U} = Unitful.FreeUnits{U,typeof($dims)}
        nothing
    end)
end


"""
    @refunit(symb, name, abbr, dimension, tf)
Define a reference unit, typically SI. Rather than define
conversion factors between each and every unit of a given dimension, conversion
factors are given between each unit and a reference unit, defined by this macro.

This macro extends [`Unitful.abbr`](@ref) so that the reference unit can be
displayed in an abbreviated format. If `tf == true`, this macro generates symbols
for every power of ten of the unit, using the standard SI prefixes. A `dimension`
must be given ([`Unitful.Dimensions`](@ref) object) that specifies the dimension
of the reference unit.

In principle, users can use this macro, but it probably does not make much sense
to do so. If you define a new (probably unphysical) dimension using
[`@dimension`](@ref), then this macro will be necessary. With existing dimensions,
you will almost certainly cause confusion if you use this macro. One potential
use case would be to define a unit system without reference to SI. However,
there's no explicit barrier to prevent attempting conversions between SI and this
hypothetical unit system, which could yield unexpected results.

Note that this macro will also choose the new unit (no power-of-ten prefix) as
the default unit for promotion given this dimension.

Returns the [`Unitful.FreeUnits`](@ref) object to which `symb` is bound.

Usage example: `@refunit m "m" Meter 𝐋 true`

This example, found in `src/pkgdefaults.jl`, generates `km`, `m`, `cm`, ...
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
        Unitful.preferunits($symb)
        $symb
    end)
end

"""
    @unit(symb,abbr,name,equals,tf)
Define a unit. Rather than specifying a dimension like in [`@refunit`](@ref),
`equals` should be a [`Unitful.Quantity`](@ref) equal to one of the unit being
defined. If `tf == true`, symbols will be made for each power-of-ten prefix.

Returns the [`Unitful.FreeUnits`](@ref) object to which `symb` is bound.

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
        Unitful.abbr(::Unitful.Unit{$(esc(x)),typeof(d)}) = $abbr
        if $tf
            Unitful.@prefixed_unit_symbols($(esc(symb)), $(esc(name)), d,
                Unitful.basefactor(inex, ex, eq, t, 1))
        else
            Unitful.@unit_symbols($(esc(symb)), $(esc(name)), d,
                Unitful.basefactor(inex, ex, eq, t, 1))
        end
        $(esc(symb))
    end
end

"""
    @prefixed_unit_symbols(symb,name,dimension,basefactor)
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
            const $s = Unitful.FreeUnits{($u,),typeof(Unitful.dimension($u))}()
        end)
        push!(expr.args, ea)
    end

    # These lines allow for μ to be typed with option-m on a Mac.
    s = Symbol(:µ, symb)
    u = :(Unitful.Unit{$z, typeof($dimension)}(-6,1//1))
    push!(expr.args, esc(quote
        Unitful.basefactors[$z] = $basefactor
        const $s = Unitful.FreeUnits{($u,),typeof(Unitful.dimension($u))}()
    end))

    expr
end

"""
    @unit_symbols(symb,name)
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
        const $s = Unitful.FreeUnits{($u,),typeof(Unitful.dimension($u))}()
    end)
end

"""
    preferunits(u0::Units, u::Units...)
This function specifies the default fallback units for promotion.
Units provided to this function must have a pure dimension of power 1, like 𝐋 or 𝐓
but not 𝐋/𝐓 or 𝐋^2. The function will complain if this is not the case. Additionally,
the function will complain if you provide two units with the same dimension, as a
courtesy to the user.

Once [`Unitful.upreferred`](@ref) has been called or quantities have been promoted,
this function will appear to have no effect.

Usage example: `preferunits(u"m,s,A,K,cd,kg,mol"...)`
"""
function preferunits(u0::Units, u::Units...)

    units = (u0, u...)
    dims = map(dimension, units)
    if length(union(dims)) != length(dims)
        error("preferunits received more than one unit of a given ",
        "dimension.")
    end

    for i in eachindex(units)
        unit, dim = units[i], dims[i]
        if length(typeof(dim).parameters[1]) > 1
            error("preferunits can only be used with a unit that has a pure ",
            "dimension, like 𝐋 or 𝐓 but not 𝐋/𝐓.")
        end
        if length(typeof(dim).parameters[1]) == 1 &&
            typeof(dim).parameters[1][1].power != 1
            error("preferunits cannot handle powers of pure dimensions except 1. ",
            "For instance, it should not be used with units of dimension 𝐋^2.")
        end
        y = typeof(dim).parameters[1][1]
        promotion[name(y)] = typeof(unit).parameters[1][1]
    end

    nothing
end

"""
    upreferred(x::Dimensions)
Return units which are preferred for dimensions `x`. If you are using the
factory defaults, this function will return a product of powers of base SI units
(as [`Unitful.FreeUnits`](@ref)).
"""
@generated function upreferred{D}(x::Dimensions{D})
    u = *(FreeUnits{((Unitful.promotion[name(z)]^z.power for z in D)...),()}())
    :($u)
end

"""
    upreferred(x::Number)
    upreferred(x::Quantity)
Unit-convert `x` to units which are preferred for the dimensions of `x`.
If you are using the factory defaults, this function will unit-convert to a
product of powers of base SI units. If quantity `x` has
[`Unitful.ContextUnits`](@ref)`(y,z)`, the resulting quantity will have
units `ContextUnits(z,z)`.
"""
@inline upreferred(x::Number) = x
@inline upreferred(x::Quantity) = uconvert(upreferred(unit(x)), x)

"""
    upreferred(x::Units)
Return units which are preferred for the dimensions of `x`, which may or may
not be equal to `x`, as specified by the [`preferunits`](@ref) function. If you
are using the factory defaults, this function will return a product of powers of
base SI units.
"""
@inline upreferred(x::FreeUnits) = upreferred(dimension(x))
@inline upreferred{N,D,P}(::ContextUnits{N,D,P}) = ContextUnits(P(),P())
@inline upreferred(x::FixedUnits) = x

"""
    @u_str(unit)
String macro to easily recall units, dimensions, or quantities defined in
unit modules that have been registered with [`Unitful.register`](@ref).

If the same symbol is used for a [`Unitful.Units`](@ref) object defined in
different modules, then the symbol found in the most recently registered module
will be used.

Note that what goes inside must be parsable as a valid Julia expression.
In other words, u"N m" will fail if you intended to write u"N*m".

Examples:

```jldoctest
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
"""
macro u_str(unit)
    ex = parse(unit)
    esc(replace_value(ex))
end

const allowed_funcs = [:*, :/, :^, :sqrt, :√, :+, :-, ://]
function replace_value(ex::Expr)
    if ex.head == :call
        ex.args[1] in allowed_funcs ||
            error("""$(ex.args[1]) is not a valid function call when parsing a unit.
             Only the following functions are allowed: $allowed_funcs""")
        for i=2:length(ex.args)
            if typeof(ex.args[i])==Symbol || typeof(ex.args[i])==Expr
                ex.args[i]=replace_value(ex.args[i])
            end
        end
        return ex
    elseif ex.head == :tuple
        for i=1:length(ex.args)
            if typeof(ex.args[i])==Symbol
                ex.args[i]=replace_value(ex.args[i])
            else
                error("only use symbols inside the tuple.")
            end
        end
        return ex
    else
        error("Expr head $(ex.head) must equal :call or :tuple")
    end
end

dottify(s, t, u...) = dottify(Expr(:(.), s, QuoteNode(t)), u...)
dottify(s) = s
dottify() = Main        # needed because fullname(Main) == (). TODO: How to test?

function replace_value(sym::Symbol)
    where = [isdefined(unitmodules[i], sym) for i in eachindex(unitmodules)]
    count = reduce(+, 0, where)
    if count == 0
        error("Symbol $sym could not be found in registered unit modules.")
    end

    m = unitmodules[findlast(where)]
    expr = Expr(:(.), dottify(fullname(m)...), QuoteNode(sym))
    if count > 1
        warn("Symbol $sym was found in multiple registered unit modules. ",
        "We will use the one from $m.")
    end
    return :(Unitful.ustrcheck($expr))
end

replace_value(literal::Number) = literal

ustrcheck(x::Union{Units,Dimensions}) = x
ustrcheck(x::Quantity) = x
ustrcheck(x) = error("Symbol $x is not a unit, dimension, or quantity.")

"""
    basefactor(x::Unit)
Specifies conversion factors to reference units.
It returns a tuple. The first value is any irrational part of the conversion,
and the second value is a rational component. This segregation permits exact
conversions within unit systems that have no rational conversion to the
reference units.
"""
function basefactor end

"""
    dimension(x::Unit)
Returns a [`Unitful.Dimensions`](@ref) object describing the given unit `x`.
"""
function dimension end
