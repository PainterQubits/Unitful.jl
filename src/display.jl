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

const docstring_for_fancy_exponents_kwarg = "- `fancy_exponents::Bool`. By default, this is `true` on macOS and false otherwise."

function get_fancy_exponents_env()
    v = get(ENV, "UNITFUL_FANCY_EXPONENTS", Sys.isapple() ? "true" : "false")
    t = tryparse(Bool, lowercase(v))
    fancy_exponents = (t === nothing) ? false : t
    return fancy_exponents
end

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

function show(io::IO, x::Unit{N,D}; fancy_exponents::Bool = get_fancy_exponents_env()) where {N,D}
    show(io, FreeUnits{(x,), D, nothing}(); fancy_exponents = fancy_exponents)
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
    showval(io::IO, x::Number, brackets::Bool=true; kwargs...)

Show the numeric value `x` of a quantity. Depending on the type of `x`, the value may be
enclosed in brackets (see [`BracketStyle`](@ref)). If `brackets` is set to `false`, the
brackets are not printed.

# Optional keyword arguments
$(docstring_for_fancy_exponents_kwarg)
"""
function showval(io::IO, x::Number, brackets::Bool=true; fancy_exponents::Bool = get_fancy_exponents_env())
    brackets && print_opening_bracket(io, x)
    show(io, x)
    brackets && print_closing_bracket(io, x)
end

function showval(io::IO, mime::MIME, x::Number, brackets::Bool=true; fancy_exponents::Bool = get_fancy_exponents_env())
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
    show(io::IO, x::Quantity; kwargs...)
Show a unitful quantity by calling [`showval`](@ref) on the numeric value, appending a
space, and then calling `show` on a units object `U()`.

# Optional keyword arguments
$(docstring_for_fancy_exponents_kwarg)
"""
function show(io::IO, x::Quantity; fancy_exponents::Bool = get_fancy_exponents_env())
    if isunitless(unit(x))
        showval(io, x.val, false; fancy_exponents = fancy_exponents)
    else
        showval(io, x.val, true; fancy_exponents = fancy_exponents)
        has_unit_spacing(unit(x)) && print(io, ' ')
        show(io, unit(x); fancy_exponents = fancy_exponents)
    end
end

function show(io::IO, mime::MIME"text/plain", x::Quantity; fancy_exponents::Bool = get_fancy_exponents_env())
    if isunitless(unit(x))
        showval(io, mime, x.val, false; fancy_exponents = fancy_exponents)
    else
        showval(io, mime, x.val, true; fancy_exponents = fancy_exponents)
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
    show(io::IO, x::Unitlike; kwargs...)
Call [`Unitful.showrep`](@ref) on each object in the tuple that is the type
variable of a [`Unitful.Units`](@ref) or [`Unitful.Dimensions`](@ref) object.

# Optional keyword arguments
$(docstring_for_fancy_exponents_kwarg)
"""
function show(io::IO, x::Unitlike; fancy_exponents::Bool = get_fancy_exponents_env())
    showoperators = get(io, :showoperators, false)
    first = ""
    sep = showoperators ? "*" : " "
    foreach(sortexp(typeof(x).parameters[1])) do y
        print(io,first)
        showrep(io, y; fancy_exponents = fancy_exponents)
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
    showrep(io::IO, x::Unit; kwargs...)
Show the unit, prefixing with any decimal prefix and appending the exponent as
formatted by [`Unitful.superscript`](@ref).

# Optional keyword arguments
$(docstring_for_fancy_exponents_kwarg)
"""
function showrep(io::IO, x::Unit; fancy_exponents::Bool = get_fancy_exponents_env())
    print(io, prefix(x))
    print(io, abbr(x))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x); fancy_exponents = fancy_exponents)))
    nothing
end

"""
    showrep(io::IO, x::Dimension; kwargs...)
Show the dimension, appending any exponent as formatted by
[`Unitful.superscript`](@ref).

# Optional keyword arguments
$(docstring_for_fancy_exponents_kwarg)
"""
function showrep(io::IO, x::Dimension; fancy_exponents::Bool = get_fancy_exponents_env())
    print(io, abbr(x))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x); fancy_exponents = fancy_exponents)))
end

"""
    superscript(i::Rational; kwargs...)
Prints exponents.

# Optional keyword arguments
$(docstring_for_fancy_exponents_kwarg)
"""
function superscript(i::Rational; fancy_exponents::Bool = get_fancy_exponents_env())
    if fancy_exponents
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
