#=========================================#
# Extension for Unitful.jl + Latexify.jl, #
# based on UnitfulLatexify.jl by          #
# David Gustavsson (@gustaphe)            #
#=========================================#
module LatexifyUnitfulExt

using Unitful:
    Unitful,
    Unit,
    Units,
    AbstractQuantity,
    AffineUnits,
    AffineQuantity,
    power,
    abbr,
    name,
    tens,
    sortexp,
    unit,
    NoDims,
    ustrip,
    @u_str,
    genericunit,
    has_unit_spacing
using Latexify:
    Latexify,
    @latexrecipe,
    latexify,
    _latexarray,
    FancyNumberFormatter,
    latexraw
using Latexify.LaTeXStrings:
    LaTeXString

import Latexify.latexify
import Base.(:*)

"""
prefixes are listed in this dictionary
`(unitformat::Symbol, pow::Integer) => prefix::String`
"""
const prefixes = begin
    Dict(
        (:mathrm, -24) => "y",
        (:mathrm, -21) => "z",
        (:mathrm, -18) => "a",
        (:mathrm, -15) => "f",
        (:mathrm, -12) => "p",
        (:mathrm, -9) => "n",
        (:mathrm, -6) => "\\mu{}",
        (:mathrm, -3) => "m",
        (:mathrm, -2) => "c",
        (:mathrm, -1) => "d",
        (:mathrm, 0) => "",
        (:mathrm, 1) => "D",
        (:mathrm, 2) => "h",
        (:mathrm, 3) => "k",
        (:mathrm, 6) => "M",
        (:mathrm, 9) => "G",
        (:mathrm, 12) => "T",
        (:mathrm, 15) => "P",
        (:mathrm, 18) => "E",
        (:mathrm, 21) => "Z",
        (:mathrm, 24) => "Y",
        (:siunitx, -24) => "\\yocto",
        (:siunitx, -21) => "\\zepto",
        (:siunitx, -18) => "\\atto",
        (:siunitx, -15) => "\\femto",
        (:siunitx, -12) => "\\pico",
        (:siunitx, -9) => "\\nano",
        (:siunitx, -6) => "\\micro",
        (:siunitx, -3) => "\\milli",
        (:siunitx, -2) => "\\centi",
        (:siunitx, -1) => "\\deci",
        (:siunitx, 0) => "",
        (:siunitx, 1) => "\\deka",
        (:siunitx, 2) => "\\hecto",
        (:siunitx, 3) => "\\kilo",
        (:siunitx, 6) => "\\mega",
        (:siunitx, 9) => "\\giga",
        (:siunitx, 12) => "\\tera",
        (:siunitx, 15) => "\\peta",
        (:siunitx, 18) => "\\exa",
        (:siunitx, 21) => "\\zetta",
        (:siunitx, 24) => "\\yotta",
        (:siunitxsimple, -24) => "y",
        (:siunitxsimple, -21) => "z",
        (:siunitxsimple, -18) => "a",
        (:siunitxsimple, -15) => "f",
        (:siunitxsimple, -12) => "p",
        (:siunitxsimple, -9) => "n",
        (:siunitxsimple, -6) => "\\u",
        (:siunitxsimple, -3) => "m",
        (:siunitxsimple, -2) => "c",
        (:siunitxsimple, -1) => "d",
        (:siunitxsimple, 0) => "",
        (:siunitxsimple, 1) => "D",
        (:siunitxsimple, 2) => "h",
        (:siunitxsimple, 3) => "k",
        (:siunitxsimple, 6) => "M",
        (:siunitxsimple, 9) => "G",
        (:siunitxsimple, 12) => "T",
        (:siunitxsimple, 15) => "P",
        (:siunitxsimple, 18) => "E",
        (:siunitxsimple, 21) => "Z",
        (:siunitxsimple, 24) => "Y",
    )
end

""""
`unitnames`

Unit names generally follow a simple scheme, but there are exceptions, listed in this
dictionary: `(unitformat::Symbol, name::Symbol) => unitname::String`
"""
const unitnames = begin
    Dict(
        (:mathrm, :Percent) => "\\%",
        (:siunitxsimple, :Percent) => "\\%",
        (:mathrm, :Degree) => "^{\\circ}",
        (:siunitxsimple, :Degree) => "\\degree",
        (:siunitx, :eV) => "\\electronvolt",
        (:mathrm, :Ohm) => "\\Omega",
        (:mathrm, :Celsius) => "^\\circ C",
        (:siunitx, :Celsius) => "\\celsius",
        (:siunitxsimple, :Celsius) => "\\celsius",
        (:mathrm, :Fahrenheit) => "^\\circ F",
        (:siunitx, :Fahrenheit) => "\\fahrenheit",
        (:siunitxsimple, :Fahrenheit) => "\\fahrenheit",
        (:siunitxsimple, :Angstrom) => "\\angstrom",
        (:mathrm, :Angstrom) => "\\AA",
        (:mathrm, :DoubleTurn) => "\\S",
        (:mathrm, :Turn) => "\\tau",
        (:mathrm, :HalfTurn) => "\\pi",
        (:mathrm, :Quadrant) => "\\frac{\\pi}{2}",
        (:mathrm, :Sextant) => "\\frac{\\pi}{3}",
        (:mathrm, :Octant) => "\\frac{\\pi}{4}",
        (:mathrm, :ClockPosition) => "\\frac{\\pi}{12}",
        (:mathrm, :HourAngle) => "\\frac{\\pi}{24}",
        (:mathrm, :CompassPoint) => "\\frac{\\pi}{32}",
        (:mathrm, :Hexacontade) => "\\frac{\\pi}{60}",
        (:mathrm, :BinaryRadian) => "\\frac{\\pi}{256}",
        (:mathrm, :DiameterPart) => "\\oslash", # This is slightly wrong
        (:mathrm, :Gradian) => "^g",
        (:mathrm, :Arcminute) => "'",
        (:mathrm, :Arcsecond) => "''",
        (:mathrm, :ArcsecondShort) => "''",
    )
end

function getunitname(p::T, unitformat) where {T<:Unit}
    unitname = get(unitnames, (unitformat, name(p)), nothing)
    isnothing(unitname) || return unitname
    if unitformat === :siunitx
        return "\\$(lowercase(String(name(p))))"
    end
    return abbr(p)
end
function listunits(::T) where {T<:Units}
    return sortexp(T.parameters[1])
end
"""
```julia
intersperse(t, delim)
```
Create a vector whose elements alternate between the elements of `t` and `delim`, analogous
to `join` for strings.

# Example
```julia
julia> intersperse((1, 2, 3, 4), :a)
[1, :a, 2, :a, 3, :a, 4]
```
"""
function intersperse(t::T, delim::U) where {T,U}
    iszero(length(t)) && return ()
    L = length(t) * 2 - 1
    out = Vector{Union{typeof.(t)...,U}}(undef, L)
    out[1:2:L] .= t
    out[2:2:L] .= delim
    return out
end

@latexrecipe function f(p::T; unitformat=:mathrm) where {T<:Unit}
    prefix = prefixes[(unitformat, tens(p))]
    pow = power(p)
    unitname = getunitname(p, unitformat)
    if unitformat === :mathrm
        env --> :inline
        if pow == 1//1
            expo = ""
        else
            expo = "^{$(latexify(pow; kwargs..., fmt="%g", env=:raw))}"
        end
        return LaTeXString("\\mathrm{$prefix$unitname}$expo")
    end
    env --> :raw
    if unitformat === :siunitx
        per = pow < 0 ? "\\per" : ""
        pow = abs(pow)
        expo = pow == 1//1 ? "" : "\\tothe{$(latexify(pow; kwargs..., fmt="%g", env=:raw))}"
    else
        per = ""
        expo = pow == 1//1 ? "" : "^{$(latexify(pow; kwargs..., fmt="%g", env=:raw))}"
    end
    return LaTeXString("$per$prefix$unitname$expo")
end

@latexrecipe function f(
    u::T; unitformat=:mathrm, permode=:power, siunitxlegacy=false
) where {T<:Units}
    if unitformat === :mathrm
        env --> :inline
        return Expr(:latexifymerge, NakedUnits(u))
    end
    env --> :raw
    siunitxlegacy && return Expr(:latexifymerge, "\\si{", NakedUnits(u), "}")
    return Expr(:latexifymerge, "\\unit{", NakedUnits(u), "}")
end

@latexrecipe function f(
    q::T; unitformat=:mathrm, siunitxlegacy=false
) where {T<:AbstractQuantity}
    if unitformat === :mathrm
        env --> :inline
        fmt --> FancyNumberFormatter()
        return Expr(
            :latexifymerge,
            q.val,
            has_unit_spacing(unit(q)) ? "\\;" : nothing,
            NakedUnits(unit(q)),
        )
    end
    env --> :raw
    siunitxlegacy &&
        return Expr(:latexifymerge, "\\SI{", q.val, "}{", NakedUnits(unit(q)), "}")
    return Expr(:latexifymerge, "\\qty{", q.val, "}{", NakedUnits(unit(q)), "}")
end

struct NakedUnits
    u::Units
end

@latexrecipe function f(u::T; unitformat=:mathrm, permode=:power) where {T<:NakedUnits}
    unitlist = listunits(u.u)
    if unitformat in (:siunitx, :siunitxsimple) || permode === :power
        return Expr(:latexifymerge, intersperse(unitlist, delimiters[unitformat])...)
    end

    numunits = [x for x in unitlist if power(x) >= 0]
    denunits = [typeof(x)(tens(x), -power(x)) for x in unitlist if power(x) < 0]

    numerator = intersperse(numunits, delimiters[unitformat])
    if iszero(length(denunits))
        return Expr(:latexifymerge, numerator...)
    end
    if iszero(length(numunits))
        numerator = [1]
    end
    denominator = intersperse(denunits, delimiters[unitformat])

    if permode === :slash
        return Expr(:latexifymerge, numerator..., "\\,/\\,", denominator...)
    end
    if permode === :frac
        return Expr(:latexifymerge, "\\frac{", numerator..., "}{", denominator..., "}")
    end
    return error("permode $permode undefined.")
end

const delimiters = Dict{Symbol,String}(
    :mathrm => "\\,", :siunitx => "", :siunitxsimple => "."
)

@latexrecipe function f(p::T; unitformat=:mathrm) where {T<:Unit{:One,NoDims}}
    return ""
end

@latexrecipe function f(
    p::T; unitformat=:mathrm
) where {T<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}}
    return ""
end

@latexrecipe function f(
    q::T; unitformat=:mathrm
) where {T<:AbstractQuantity{<:Number,NoDims,<:Units{(),NoDims,nothing}}}
    if unitformat === :mathrm
        env --> :inline
        fmt --> FancyNumberFormatter()
        return ustrip(q)
    end
    env --> :raw
    return Expr(:latexifymerge, "\\num{", ustrip(q), "}")
end

@latexrecipe function f(
    q::T; unitformat=:mathrm
) where {
    T<:AbstractQuantity{<:Number,NoDims,<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}}
}
    if unitformat === :mathrm
        env --> :inline
        fmt --> FancyNumberFormatter()
        return ustrip(q)
    end
    env --> :raw
    return Expr(:latexifymerge, "\\num{", ustrip(q), "}")
end

@latexrecipe function f( # Array{Quantity{U}}
    a::AbstractArray{<:AbstractQuantity{N,D,U}};
    unitformat=:mathrm,
) where {N<:Number,D,U}
    # Array of quantities with the same unit
    env --> :equation
    return Expr(
        :latexifymerge,
        ustrip.(a) * u"One",
        has_unit_spacing(first(a)) ? "\\;" : "",
        unit(first(a)),
    )
end

@latexrecipe function f( # Array{Quantity{One}
    a::T;
    unitformat=:mathrm,
) where {
    T<:AbstractArray{<:AbstractQuantity{N,D,U}}
} where {N<:Number,D,U<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}}
    env --> :equation
    if unitformat in (:siunitx, :siunitxsimple)
        return latexify.(a; kwargs..., unitformat=unitformat, env=:raw)
    end
    return ustrip.(a)
end

@latexrecipe function f( # Range{Quantity{U}}
    r::AbstractRange{<:AbstractQuantity{N,D,U}};
    unitformat=:mathrm,
) where {N<:Number,D,U}
    if unitformat in (:siunitx, :siunitxsimple)
        env --> :raw
        return Expr(
            :latexifymerge,
            "\\qtyrange{",
            r.start.val,
            "}{",
            r.stop.val,
            "}{",
            NakedUnits(unit(r.start)),
            "}",
        )
    end
    return collect(r)
end

@latexrecipe function f( # Range{Quantity{One}}
    r::T;
    unitformat=:mathrm,
) where {
    T<:AbstractRange{<:AbstractQuantity{N,D,U}}
} where {N<:Number,D,U<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}}
    if unitformat in (:siunitx, :siunitxsimple)
        env --> :raw
        return Expr(:latexifymerge, "\\numrange{", r.start.val, "}{", r.stop.val, "}")
    end
    return ustrip.(r)
end

@latexrecipe function f( # Tuple{Quantity{U}}
    l::Tuple{T,Vararg{T}};
    unitformat=:mathrm,
) where {T<:AbstractQuantity{N,D,U}} where {N<:Number,D,U}
    if unitformat in (:siunitx, :siunitxsimple)
        env --> :raw
        return Expr(
            :latexifymerge,
            "\\qtylist{",
            intersperse(ustrip.(l), ";")...,
            "}{",
            NakedUnits(unit(first(l))),
            "}",
        )
    end
    return collect(l)
end

@latexrecipe function f( # Tuple{Quantity{One}}
    l::Tuple{T,Vararg{T}};
    unitformat=:mathrm,
) where {
    T<:AbstractQuantity{N,D,U}
} where {N<:Number,D,U<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}}
    if unitformat in (:siunitx, :siunitxsimple)
        env --> :raw
        return Expr(:latexifymerge, "\\numlist{", intersperse(ustrip.(l), ";")..., "}")
    end
    return ustrip.(l)
end

@latexrecipe function f(u::T; unitformat=:mathrm) where {T<:AffineUnits}
    if u == Unitful.°C
        unitname = :Celsius
    elseif u == Unitful.°F
        unitname = :Fahrenheit
    else
        # If it's not celsius or farenheit, let it do the default thing
        return genericunit(u)
    end
    if unitformat === :mathrm
        env --> :inline
        return LaTeXString(unitnames[(unitformat, unitname)])
    end
    env --> :raw
    return Expr(:latexifymerge, "\\unit{", unitnames[(unitformat, unitname)], "}")
end

@latexrecipe function f(q::T; unitformat=:mathrm) where {T<:AffineQuantity}
    u = unit(q)
    if u == Unitful.°C
        unitname = :Celsius
    elseif u == Unitful.°F
        unitname = :Fahrenheit
    else
        # If it's not celsius or farenheit, let it do the default thing
        return genericunit(u)
    end
    if unitformat === :mathrm
        env --> :inline
        fmt --> FancyNumberFormatter()
        return Expr(
            :latexifymerge, q.val, "\\;\\mathrm{", unitnames[(unitformat, unitname)], "}"
        )
    end
    env --> :raw
    return Expr(
        :latexifymerge, "\\qty{", q.val, "}{", unitnames[(unitformat, unitname)], "}"
    )
end

@latexrecipe function f(l::AbstractString, u::Units; labelformat=:slash)
    labelformat === :slash && return Expr(:latexifymerge, l, "\\;\\left/\\;", u, "\\right.")
    labelformat === :square && return Expr(:latexifymerge, l, "\\;\\left[", u, "\\right]")
    labelformat === :round && return Expr(:latexifymerge, l, "\\;\\left(", u, "\\right)")
    labelformat === :frac && return Expr(:latexifymerge, "\\frac{", l, "}{", u, "}")
end

end
