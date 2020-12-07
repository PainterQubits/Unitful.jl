"""
`abbr(x)` provides abbreviations for units or dimensions. Since a method should
always be defined for each unit and dimension type, absence of a method for a
specific unit or dimension type is likely an error. Consequently, we return ❓
for generic arguments to flag unexpected behavior.
"""
abbr(x) = "❓"     # Indicate missing abbreviations

"""
    prefix(x::Unit)
Returns a string representing the SI prefix for the power-of-ten held by
this particular unit.
"""
function prefix(x::Unit)
    if haskey(prefixdict, tens(x))
        return prefixdict[tens(x)]
    else
        error("Invalid power-of-ten prefix.")
    end
end

function show(io::IO, x::Unit{N,D}) where {N,D}
    show(io, FreeUnits{(x,), D, nothing}())
end

abstract type BracketStyle end

struct NoBrackets <: BracketStyle end
print_opening_bracket(io::IO, ::NoBrackets) = nothing
print_closing_bracket(io::IO, ::NoBrackets) = nothing

struct RoundBrackets <: BracketStyle end
print_opening_bracket(io::IO, ::RoundBrackets) = print(io, '(')
print_closing_bracket(io::IO, ::RoundBrackets) = print(io, ')')

struct SquareBrackets <: BracketStyle end
print_opening_bracket(io::IO, ::SquareBrackets) = print(io, '[')
print_closing_bracket(io::IO, ::SquareBrackets) = print(io, ']')

print_opening_bracket(io::IO, x) = print_opening_bracket(io, BracketStyle(x))
print_closing_bracket(io::IO, x) = print_closing_bracket(io, BracketStyle(x))

"""
    BracketStyle(x)
    BracketStyle(typeof(x))

`BracketStyle` specifies whether the numeric value of a `Quantity` is printed in brackets
(and what kind of brackets). Three styles are defined:

* `NoBrackets()`: this is the default, for example used for real numbers: `1.2 m`
* `RoundBrackets()`: used for complex numbers: `(2.5 + 1.0im) V`
* `SquareBrackets()`: used for [`Level`](@ref)/[`Gain`](@ref): `[3 dB] Hz^-1`
"""
BracketStyle(x) = BracketStyle(typeof(x))
BracketStyle(::Type) = NoBrackets()
BracketStyle(::Type{<:Complex}) = RoundBrackets()

"""
    showval(io::IO, x::Number, brackets::Bool=true)

Show the numeric value `x` of a quantity. Depending on the type of `x`, the value may be
enclosed in brackets (see [`BracketStyle`](@ref)). If `brackets` is set to `false`, the
brackets are not printed.
"""
function showval(io::IO, x::Number, brackets::Bool=true)
    brackets && print_opening_bracket(io, x)
    show(io, x)
    brackets && print_closing_bracket(io, x)
end

function showval(io::IO, mime::MIME, x::Number, brackets::Bool=true)
    brackets && print_opening_bracket(io, x)
    show(io, mime, x)
    brackets && print_closing_bracket(io, x)
end

# Space between numerical value and unit should always be included
# except for angular degress, minutes and seconds (° ′ ″)
# See SI 9th edition, section 5.4.3; "Formatting the value of a quantity"
# https://www.bipm.org/utils/common/pdf/si-brochure/SI-Brochure-9.pdf
has_unit_spacing(u) = true
has_unit_spacing(u::Units{(Unit{:Degree, NoDims}(0, 1//1),), NoDims}) = false

"""
    show(io::IO, x::Quantity)
Show a unitful quantity by calling [`showval`](@ref) on the numeric value, appending a
space, and then calling `show` on a units object `U()`.
"""
function show(io::IO, x::Quantity)
    if isunitless(unit(x))
        showval(io, x.val, false)
    else
        showval(io, x.val, true)
        has_unit_spacing(unit(x)) && print(io, ' ')
        show(io, unit(x))
    end
end

function show(io::IO, mime::MIME"text/plain", x::Quantity)
    if isunitless(unit(x))
        showval(io, mime, x.val, false)
    else
        showval(io, mime, x.val, true)
        has_unit_spacing(unit(x)) && print(io, ' ')
        show(io, mime, unit(x))
    end
end

function show(io::IO, r::Union{StepRange{T},StepRangeLen{T}}) where T<:Quantity
    a,s,b = first(r), step(r), last(r)
    U = unit(a)
    print(io, '(')
    if ustrip(U, s) == 1
        show(io, ustrip(U, a):ustrip(U, b))
    else
        show(io, ustrip(U, a):ustrip(U, s):ustrip(U, b))
    end
    print(io, ')')
    has_unit_spacing(U) && print(io,' ')
    show(io, U)
end

function show(io::IO, x::typeof(NoDims))
    print(io, "NoDims")
end

"""
    show(io::IO, x::Unitlike)
Call [`Unitful.showrep`](@ref) on each object in the tuple that is the type
variable of a [`Unitful.Units`](@ref) or [`Unitful.Dimensions`](@ref) object.
"""
function show(io::IO, x::Unitlike)
    showoperators = get(io, :showoperators, false)
    first = ""
    sep = showoperators ? "*" : " "
    foreach(sortexp(typeof(x).parameters[1])) do y
        print(io,first)
        showrep(io,y)
        first = sep
    end
    nothing
end

"""
    sortexp(xs)
Sort units to show positive exponents first.
"""
function sortexp(xs)
    vcat([x for x in xs if power(x) >= 0],
        [x for x in xs if power(x) < 0])
end

"""
    showrep(io::IO, x::Unit)
Show the unit, prefixing with any decimal prefix and appending the exponent as
formatted by [`Unitful.superscript`](@ref).
"""
function showrep(io::IO, x::Unit)
    print(io, prefix(x))
    print(io, abbr(x))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x))))
    nothing
end

"""
    showrep(io::IO, x::Dimension)
Show the dimension, appending any exponent as formatted by
[`Unitful.superscript`](@ref).
"""
function showrep(io::IO, x::Dimension)
    print(io, abbr(x))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x))))
end

"""
    superscript(i::Rational)
Prints exponents.
"""
function superscript(i::Rational)
    v = @eval get(ENV, "UNITFUL_FANCY_EXPONENTS", $(Sys.isapple() ? "true" : "false"))
    t = tryparse(Bool, lowercase(v))
    k = (t === nothing) ? false : t
    if k
        return i.den == 1 ? superscript(i.num) : string(superscript(i.num), '\u141F', superscript(i.den))
    else
        i.den == 1 ? "^" * string(i.num) : "^" * replace(string(i), "//" => "/")
    end
end

# Taken from SIUnits.jl
superscript(i::Integer) = map(repr(i)) do c
    c == '-' ? '\u207b' :
    c == '1' ? '\u00b9' :
    c == '2' ? '\u00b2' :
    c == '3' ? '\u00b3' :
    c == '4' ? '\u2074' :
    c == '5' ? '\u2075' :
    c == '6' ? '\u2076' :
    c == '7' ? '\u2077' :
    c == '8' ? '\u2078' :
    c == '9' ? '\u2079' :
    c == '0' ? '\u2070' :
    error("unexpected character")
end

"""
    latexify(x::Quantity)
    latexify(x::FreeUnits)
    latexify(x::Unit)
Return a LaTeXString representation of `x`. Accepts keyword argument
`unitformat=:mathrm` or `:siunitx`, which selects between the more basic
`3\\;\\mathrm{m}` or `\\SI{3}{\\meter}` (which requires the siunitx package to
render).
"""
latexify(::Quantity)

@latexrecipe function f(p::T;unitformat=:mathrm) where T <: Unit
    pref = latexprefixdict[unitformat,tens(p)]
    pow = power(p)
    if unitformat == :mathrm
        env --> :inline
        unitname = abbr(p)
        if pow == 1//1
            expo = ""
        else
            expo = "^{$(latexify(pow;env=:raw))}"
        end
        return LaTeXString("\\mathrm{$pref$unitname}$expo")
    end
    env --> :raw
    unitname = "\\$(lowercase(String(name(p))))"
    per = pow<0 ? "\\per" : ""
    pow = abs(pow)
    expo = pow==1//1 ? "" : "\\tothe{$(latexify(pow;env=:raw))}"
    return LaTeXString("$per$pref$unitname$expo")
end

function listunits(::T;unitformat) where T <: FreeUnits
    return prod(latexify.(sortexp(T.parameters[1]);unitformat,env=:raw))
end

@latexrecipe function f(u::T;unitformat=:mathrm) where T <: FreeUnits
    if unitformat == :mathrm
        env --> :inline
        return LaTeXString(listunits(u;unitformat))
    end
    env --> :raw
    return LaTeXString("\\si{$(listunits(u;unitformat))}")
end

@latexrecipe function f(q::T;unitformat=:mathrm) where T <: Quantity
    if unitformat == :mathrm
        env --> :inline
        fmt --> FancyNumberFormatter()
        return LaTeXString("$(
                              latexify(q.val,env=:raw)
                             )\\;$(
                                   listunits(unit(q);unitformat)
                                  )")
    end
    env --> :raw
    return LaTeXString("\\SI{$(
                               latexify(q.val,env=:raw)
                              )}{$(
                                   listunits(unit(q);unitformat)
                                  )}")
end


