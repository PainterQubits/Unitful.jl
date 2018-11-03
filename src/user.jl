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
[`Unitful.Quantity`](@ref), [`Unitful.Level`](@ref) and [`Unitful.Units`](@ref) objects
of the newly defined dimension. The type alias for quantities or levels is simply given by
`name`, and the type alias for units is given by `name*"Units"`, e.g. `LengthUnits`.
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
    funame = Symbol(name,"FreeUnits")
    esc(quote
        Unitful.abbr(::Unitful.Dimension{$x}) = $abbr
        const global $s = Unitful.Dimensions{(Unitful.Dimension{$x}(1),)}()
        const global ($name){T,U} = Union{
            Unitful.Quantity{T,$s,U},
            Unitful.Level{L,S,Unitful.Quantity{T,$s,U}} where {L,S}}
        const global ($uname){U} = Unitful.Units{U,$s}
        const global ($funame){U} = Unitful.FreeUnits{U,$s}
        $s
    end)
end

"""
    @derived_dimension(name, dims)
Creates type aliases to allow dispatch on [`Unitful.Quantity`](@ref),
[`Unitful.Level`](@ref), and [`Unitful.Units`](@ref) objects of a derived dimension,
like area, which is just length squared. The type aliases are not exported.

`dims` is a [`Unitful.Dimensions`](@ref) object.

Returns `nothing`.

Usage examples:

- `@derived_dimension Area 𝐋^2` gives `Area` and `AreaUnit` type aliases
- `@derived_dimension Speed 𝐋/𝐓` gives `Speed` and `SpeedUnit` type aliases
"""
macro derived_dimension(name, dims)
    uname = Symbol(name,"Units")
    funame = Symbol(name,"FreeUnits")
    esc(quote
        const global ($name){T,U} = Union{
            Unitful.Quantity{T,$dims,U},
            Unitful.Level{L,S,Unitful.Quantity{T,$dims,U}} where {L,S}}
        const global ($uname){U} = Unitful.Units{U,$dims}
        const global ($funame){U} = Unitful.FreeUnits{U,$dims}
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
    expr = Expr(:block)
    n = Meta.quot(Symbol(name))

    push!(expr.args, quote
        Unitful.abbr(::Unitful.Unit{$n, $dimension}) = $abbr
    end)

    if tf
        push!(expr.args, quote
            Unitful.@prefixed_unit_symbols $symb $name $dimension (1.0, 1)
        end)
    else
        push!(expr.args, quote
            Unitful.@unit_symbols $symb $name $dimension (1.0, 1)
        end)
    end

    push!(expr.args, quote
        Unitful.preferunits($symb)
        $symb
    end)

    esc(expr)
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
    expr = Expr(:block)
    n = Meta.quot(Symbol(name))

    d = :(Unitful.dimension($equals))
    basef = :(Unitful.basefactor(Unitful.basefactor(Unitful.unit($equals))...,
                                 ($equals)/Unitful.unit($equals),
                                 Unitful.tensfactor(Unitful.unit($equals)), 1))
    push!(expr.args, quote
        Unitful.abbr(::Unitful.Unit{$n, $d}) = $abbr
    end)

    if tf
        push!(expr.args, quote
            Unitful.@prefixed_unit_symbols $symb $name $d $basef
        end)
    else
        push!(expr.args, quote
            Unitful.@unit_symbols $symb $name $d $basef
        end)
    end

    push!(expr.args, quote
        $symb
    end)

    esc(expr)
end

"""
    @affineunit(symb, abbr, offset)
Macro for easily defining affine units. `offset` gives the zero of the relative scale
in terms of an absolute scale; the scaling is the same as the absolute scale. Example:
`@affineunit °C "°C" (27315//100)K` is used internally to define degrees Celsius.
"""
macro affineunit(symb, abbr, offset)
    s = Symbol(symb)
    return esc(quote
        const global $s = Unitful.affineunit($offset)
        Base.show(io::IO, ::Unitful.genericunit($s)) = print(io, $abbr)
    end)
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
    n = Meta.quot(Symbol(name))

    for (k,v) in prefixdict
        s = Symbol(v,symb)
        u = :(Unitful.Unit{$n, $dimension}($k,1//1))
        ea = quote
            Unitful.basefactors[$n] = $basefactor
            const global $s = Unitful.FreeUnits{($u,), Unitful.dimension($u), nothing}()
        end
        push!(expr.args, ea)
    end

    # These lines allow for μ to be typed with option-m on a Mac.
    s = Symbol(:µ, symb)
    u = :(Unitful.Unit{$n, $dimension}(-6,1//1))
    push!(expr.args, quote
        Unitful.basefactors[$n] = $basefactor
        const global $s = Unitful.FreeUnits{($u,), Unitful.dimension($u), nothing}()
    end)

    esc(expr)
end

"""
    @unit_symbols(symb,name)
Not called directly by the user. Given a unit symbol and a unit's name,
will define units without SI power-of-ten prefixes.

Example: `@unit_symbols ft Foot 𝐋` results in `ft` getting defined but not `kft`.
"""
macro unit_symbols(symb,name,dimension,basefactor)
    s = Symbol(symb)
    n = Meta.quot(Symbol(name))
    u = :(Unitful.Unit{$n, $dimension}(0,1//1))
    esc(quote
        Unitful.basefactors[$n] = $basefactor
        const global $s = Unitful.FreeUnits{($u,), Unitful.dimension($u), nothing}()
    end)
end

"""
    preferunits(u0::Units, u::Units...)
This function specifies the default fallback units for promotion.
Units provided to this function must have a pure dimension of power 1, like 𝐋 or 𝐓
but not 𝐋/𝐓 or 𝐋^2. The function will complain if this is not the case. Additionally,
the function will complain if you provide two units with the same dimension, as a
courtesy to the user. Finally, you cannot use affine units such as °C with this function.

Once [`Unitful.upreferred`](@ref) has been called or quantities have been promoted,
this function will appear to have no effect.

Usage example: `preferunits(u"m,s,A,K,cd,kg,mol"...)`
"""
function preferunits(u0::Units, u::Units...)

    units = (u0, u...)
    any(x->x isa AffineUnits, units) &&
        error("cannot use `Unitful.preferunits` with affine units; try `Unitful.ContextUnits`.")

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
@generated function upreferred(x::Dimensions{D}) where {D}
    u = *(FreeUnits{((Unitful.promotion[name(z)]^z.power for z in D)...,),()}())
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
@inline upreferred(::ContextUnits{N,D,P}) where {N,D,P} = ContextUnits(P(),P())
@inline upreferred(x::FixedUnits) = x

"""
    @logscale(symb,abbr,name,base,prefactor,irp)
Define a logarithmic scale. Unlike with units, there is no special treatment for
power-of-ten prefixes (decibels and bels are defined separately). However, arbitrary
bases are possible, and computationally appropriate `log` and `exp` functions are used
in calculations when available (e.g. `log2`, `log10` for base 2 and base 10, respectively).

This macro defines a `MixedUnits` object identified by symbol `symb`. This can be used
to construct `Gain` types, e.g. `3*dB`. Additionally, two other `MixedUnits` objects are
defined, with symbols `Symbol(symb,"_rp")` and `Symbol(symb,"_p")`, e.g. `dB_rp` and `dB_p`,
respectively. These objects serve nearly the same purpose, but have extra information in
their type that indicates whether they should be considered as root-power ratios or power
ratios upon conversion to pure numbers.

This macro also defines another macro available as `@symb`. For example, `@dB` in the case
of decibels. This can be used to construct `Level` objects at parse time. Usage is like
`@dB 3V/1V`.

`prefactor` is the prefactor out in front of the logarithm for this log scale.
In all cases it is defined with respect to taking ratios of power quantities. Just divide
by two if you want to refer to root-power / field quantities instead.

`irp` (short for "is root power?") specifies whether the logarithmic scale is defined
with respect to ratios of power or root-power quantities. In short: use `false` if your scale
is decibel-like, or `true` if your scale is neper-like.

Examples:
```jldoctest
julia> using Unitful: V, W

julia> @logscale dΠ "dΠ" Decipies π 10 false
dΠ

julia> @dΠ π*V/1V
20.0 dΠ (1 V)

julia> dΠ(π*V, 1V)
20.0 dΠ (1 V)

julia> @dΠ π^2*V/1V
40.0 dΠ (1 V)

julia> @dΠ π*W/1W
10.0 dΠ (1 W)
```
"""
macro logscale(symb,abbr,name,base,prefactor,irp)
    quote
        Unitful.abbr(::Unitful.LogInfo{$(QuoteNode(name))}) = $abbr

        const global $(esc(name)) = Unitful.LogInfo{$(QuoteNode(name)), $base, $prefactor}
        Unitful.isrootpower(::Type{$(esc(name))}) = $irp

        const global $(esc(symb)) = Unitful.MixedUnits{Unitful.Gain{$(esc(name)), :?}}()
        const global $(esc(Symbol(symb,"_rp"))) = Unitful.MixedUnits{Unitful.Gain{$(esc(name)), :rp}}()
        const global $(esc(Symbol(symb,"_p"))) = Unitful.MixedUnits{Unitful.Gain{$(esc(name)), :p}}()

        macro $(esc(symb))(::Union{Real,Symbol})
            throw(ArgumentError(join(["usage: `@", $(String(symb)), " (a)/(b)`"])))
        end

        macro $(esc(symb))(expr::Expr)
            expr.args[1] != :/ &&
                throw(ArgumentError(join(["usage: `@", $(String(symb)), " (a)/(b)`"])))
            length(expr.args) != 3 &&
                throw(ArgumentError(join(["usage: `@", $(String(symb)), " (a)/(b)`"])))
            return Expr(:call, $(esc(symb)), expr.args[2], expr.args[3])
        end

        macro $(esc(symb))(expr::Expr, tf::Bool)
            expr.args[1] != :/ &&
                throw(ArgumentError(join(["usage: `@", $(String(symb)), " (a)/(b)`"])))
            length(expr.args) != 3 &&
                throw(ArgumentError(join(["usage: `@", $(String(symb)), " (a)/(b)`"])))
            return Expr(:call, $(esc(symb)), expr.args[2], expr.args[3], tf)
        end

        function (::$(esc(:typeof))($(esc(symb))))(num::Number, den::Number)
            dimension(num) != dimension(den) && throw(DimensionError(num,den))
            dimension(num) == NoDims &&
                throw(ArgumentError(string("to use with dimensionless numbers, pass a ",
                    "final `Bool` argument: true if the ratio is a root-power ratio, ",
                    "false otherwise.")))
            return Level{$(esc(name)), den}(num)
        end

        function (::$(esc(:typeof))($(esc(symb))))(num::Number, den::Number, irp::Bool)
            dimension(num) != dimension(den) && throw(DimensionError(num,den))
            dimension(num) != NoDims &&
                throw(ArgumentError(string("when passing a final Bool argument, ",
                    "this can only be used with dimensionless numbers.")))
            T = ifelse(irp, RootPowerRatio, PowerRatio)
            return Level{$(esc(name)), T(den)}(num)
        end

        function (::$(esc(:typeof))($(esc(symb))))(num::Number, den::Units)
            $(esc(symb))(num, 1*den)
        end

        function (::$(esc(:typeof))($(esc(symb))))(num::Number, den::Units, irp::Bool)
            $(esc(symb))(num, 1*den, irp)
        end

        $(esc(symb))
    end
end

"""
    @logunit(symb, abbr, logscale, reflevel)
Defines a logarithmic unit. For examples see `src/pkgdefaults.jl`.
"""
macro logunit(symb, abbr, logscale, reflevel)
    quote
        Unitful.abbr(::Unitful.Level{$(esc(logscale)), $(esc(reflevel))}) = $abbr
        const global $(esc(symb)) =
            Unitful.MixedUnits{Unitful.Level{$(esc(logscale)), $(esc(reflevel))}}()
    end
end

"""
    affineunit(x::Quantity)
Returns a [`Unitful.Units`](@ref) object that can be used to construct affine quantities.
Primarily, this is for relative temperatures (as opposed to absolute temperatures,
which transform as usual under unit conversion). To use this function, pass the scale offset,
e.g. `affineunit(273.15K)` yields a Celsius unit.
"""
affineunit(x::Quantity{T,D,FreeUnits{N,D,nothing}}) where {N,D,T} =
    FreeUnits{N,D,Affine{-ustrip(x)}}()

"""
    @u_str(unit)
String macro to easily recall units, dimensions, or quantities defined in
unit modules that have been registered with [`Unitful.register`](@ref).

If the same symbol is used for a [`Unitful.Units`](@ref) object defined in
different modules, then the symbol found in the most recently registered module
will be used.

Note that what goes inside must be parsable as a valid Julia expression.
In other words, u"N m" will fail if you intended to write u"N*m".

Since `@u_str` dynamically looks through registered modules, it does not play well with
precompilation. You shouldn't use this macro in a precompiled module.

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
    ex = Meta.parse(unit)
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

function replace_value(sym::Symbol)
    f = m->(isdefined(m,sym) && ustrcheck_bool(getfield(m, sym)))
    inds = findall(f, unitmodules)
    isempty(inds) &&
        error("Symbol $sym could not be found in registered unit modules.")

    m = unitmodules[inds[end]]
    u = getfield(m, sym)

    any(u != u1 for u1 in getfield.(unitmodules[inds[1:(end-1)]], sym)) &&
        @warn(string("Symbol $sym was found in multiple registered unit modules. ",
         "We will use the one from $m."))
    return u
end

replace_value(literal::Number) = literal

ustrcheck_bool(::Number) = true
ustrcheck_bool(::MixedUnits) = true
ustrcheck_bool(::Units) = true
ustrcheck_bool(::Dimensions) = true
ustrcheck_bool(::Quantity) = true
ustrcheck_bool(::Any) = false

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
