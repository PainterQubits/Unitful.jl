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
BracketStyle(::Type{<:Rational}) = RoundBrackets()

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
    nothing
end

function showval(io::IO, mime::MIME, x::Number, brackets::Bool=true)
    brackets && print_opening_bracket(io, x)
    show(io, mime, x)
    brackets && print_closing_bracket(io, x)
    nothing
end

# Space between numerical value and unit should always be included
# except for angular degress, minutes and seconds (° ′ ″)
# See SI 9th edition, section 5.4.3; "Formatting the value of a quantity"
# https://www.bipm.org/utils/common/pdf/si-brochure/SI-Brochure-9.pdf
#

has_unit_spacing(u::Units{(Unit{:Degree, NoDims}(0, 1//1),), NoDims}) = false

# This clone of Unitful overrides the default spacing, in order to allow reproduction
# of output quantities from their undecorated representations.
# This means that the output from show(X) can used to construct a new X.
# This is by Julia convention ("rule of thumb"), but we are not able to simultaneously follow the
# SI convention of typing space between value and unit in a quantity.
# https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing-1
has_unit_spacing(u) = false


#=
The context has info on what has been shown (or has been deemed implicit) already.
It may or may not actually have been shown on screen.

For example:
- if called via the long output form, typeinfo, if existing,
  has been shown (in 'summary'). The long form is shown when:
    show(io, MIME("text/plain", x))

- if called via show |> Base._show_nonempty (the short form)
  it has not been shown, because we defined
      typeinfo_implicit(::Type{<:Quantity}) = true

When the unit has not been shown - yet - we do not show it here.
This was the latter example.
We want the calling context to add the unit at the end of the context, e.g.
    [1,2,3]mm
Therefore, we define specialized calling contexts, e.g.
    Base._show_nonempty(io, ::Array{<:Quantity})

Note that as a consequence, we need to be able to parse
    X = [1 2; 3 4]mm
...which may contradict other Julia conventions.
=#

"""
    show(io::IO, x::Quantity)
Show a unitful quantity. If the unit is declared as known by the calling context,
drop units and decorations. If not, decorate the value with brackets if
needed, by a space if needed, and color the unit if the display has that
capability.
"""
function show(io::IO, x::Quantity)
    # This is the undecorated form.
    if isunitless(unit(x))
        # No units to show, no need for potential brackets
        showval(io, x.val, false)
    else
        typeinfo = get(io, :typeinfo, Nothing)::Type
        if isa(x, typeinfo)
            # No need to show the unit twice, no need for potential brackets
            showval(io, x.val, false)
        else
            # For some types, brackets are needed around the value.
            showval(io, x.val, true)
            showunit(io, x)
        end
    end
end


function show(io::IO, mime::MIME"text/plain", x::Quantity)
    # This is the decorated form.
    if isunitless(unit(x))
        # No units to show, no need for potential brackets
        showval(io, mime, x.val, false)
    else
        typeinfo = get(io, :typeinfo, Nothing)::Type
        if isa(x, typeinfo)
            # No need to show the unit twice, no need for potential brackets
            showval(io, mime, x.val, false)
        else
            # For some types, brackets are needed around the value.
            showval(io, mime, x.val, true)
            showunit(io, mime, x)
        end
    end
end

function show(io::IO, x::MixedUnits{T,U}) where {T,U}
    print(io, abbr(x))
    if x.units != NoUnits
        show(io, x.units)
    end
    nothing
end

function show(io::IO, x::Gain)
    print(io, x.val, abbr(x))
    nothing
end
function Base.show(io::IO, x::Level)
    print(io, ustrip(x), abbr(x))
    nothing
end





function ___show(io::IO, x::Quantity{S, NoDims, <:Units{
    (Unitful.Unit{:Degree, NoDims}(0, 1//1),), NoDims}}) where S
    show(io, x.val)
    showunit(io, x)
end

function ___show(io::IO, x::Type{T}) where T<:Quantity
    if get(io, :shorttype, false)
        # Given the shorttype context argument (as in an array of quanities description),
        # the numeric type and unit symbol is enough info to superficially represent the type.
        print(io, numtype(x),"{")
        ioc = IOContext(io, :dontshowlocalunits=>false)
        showunit(ioc, T)
        print(io, "}")
    else
        # We show a complete or partial description.
        # This pair in IOContext specifies as fallback a full formal type representation,
        # provided the opposite is not already specified by the caller:
        pa = Pair(:showconstructor, get(io, :showconstructor, true))
        ioc = IOContext(io, pa)
        invoke(show, Tuple{IO, typeof(x)}, ioc, x)
    end
end

# TODO treat the same way as arrays, by extending show_nonempty or the similar function
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
    first = ""
    foreach(sortexp(typeof(x).parameters[1])) do y
        print(io, first)
        showrep(io, y)
        first = "∙"
    end
    nothing
end


"""
    show(io::IO, mime::MIME"text/plain", x::AbstractArray{Quantity{T,D,U}, N}) where {T,D,U,N}
Show the type information only in the header for AbstractArrays.
The type information header is formatted for readability and the output can't be used as a constructor, just
as with any AbstractArray.
"""
function __show(io::IO, mime::MIME"text/plain", x::AbstractArray{Quantity{T,D,U}, N}) where {T,D,U,N} # long form
    # For abstract arrays, the REPL output can't normally be used to make a new and identical instance of
    # the array. So we don't bother to do that either, in this context.
    # This pair in IOContext specifies an informal type representation,
    # if the opposite is not already specified from upstream.
    pai = Pair(:shorttype, get(io, :shorttype, true))
    ioc = IOContext(io, pai, :dontshowlocalunits=>true)
    # Now call the method which would normally have been called if we didn't slightly interfere here.
    invoke(show, Tuple{IO, MIME{Symbol("text/plain")}, AbstractArray}, ioc, mime, x)
end

function __show(io::IO, mime::MIME"application/prs.juno.inline", x::AbstractArray{Quantity{T,D,U}, N}) where {T,D,U,N} # long form
    # For abstract arrays, the REPL output can't normally be used to make a new and identical instance of
    # the array. So we don't bother to do that either, in this context.
    # This pair in IOContext specifies an informal type representation,
    # if the opposite is not already specified from upstream.
    ioc = IOContext(io, :unitsymbolcolor=>:yellow)
    show(ioc, MIME("text/plain"), x)
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
Also prints with color when allowed by io.
Pass in
    IOContext(..., :showconstructor=>true)
to show a longer more formal form of the unit type, which can be used as a constructor.
This is done internally when the output of vanilla Julia types would also double as constructor.
"""
function ____showrep(io::IO, x::Unit)
    supers = power(x) == 1//1 ? "" : superscript(power(x))
    if get(io, :showconstructor, false)
        # Print a longer, more formal definition which can be used as a constructor or inform the interested user.
        print(io, typeof(x), "(", tens(x), ", ", power(x), ")")
    else
        # Print the shortest representation of the unit (of a number), i.e. prefix, unit symbol, superscript.
        # Color output is context-aware.
        col = get(io, :unitsymbolcolor, :cyan)
        printstyled(io, color = col, prefix(x), abbr(x), supers)
    end
end

function showrep(io::IO, x::Unit)
    col = get(io, :unitsymbolcolor, :cyan)
    printstyled(io, color = col, prefix(x), abbr(x), power(x) == 1//1 ? "" : superscript(power(x)))
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

function ____showrep(io::IO, x::FreeUnits{N,D,A}) where {N, D, A<:Affine}
    if get(io, :showconstructor, false)
        # Print a longer, more formal definition which can be used as a constructor or inform the interested user.
        print(io, "FreeUnits{", N, ",", D, ",", A, "}")
    else
        # Print the shortest representation of the affine unit.
        # Color output is context-aware.
        col = get(io, :unitsymbolcolor, :cyan)
        printstyled(io, color = col, abbr(x))
    end
end

function ___show(io::IO, x::Quantity{T,D,U}) where {T<:Rational, D, U}
    # Add paranthesis: 1//1000m² -> (1//1000)m²
    print(io, "(")
    show(io, x.val)
    print(io, ")")
    showunit(io, x)
end

function ____show(io::IO, mime::MIME"text/plain", x::Quantity{T,D,U}) where {T<:Rational, D, U}
    # Add paranthesis: 1//1000m² -> (1//1000)m²
    print(io, "(")
    show(io, mime, x.val)
    print(io, ")")
    show(io, mime, unit(x))
end

function ____show(io::IO, mime::MIME"text/html", x::Quantity{T,D,U}) where {T<:Rational, D, U}
    # Add paranthesis: 1//1000m² -> (1//1000)m²
    ioc = IOContext(io, :unitsymbolcolor=>:yellow)
    print(ioc, "(")
    show(ioc, mime, x.val)
    print(ioc, ")")
    showunit(ioc, mime, unit(x))
end


function ________show(io::IO, x::FreeUnits{N,D,A}) where {N, D, A<:Affine}
    showrep(io, x)
end
"""
    showunit(io::IO, x)
Show the unit of x, prefixed by space depending on the unit.
"""
function showunit(io::IO, x)
    # This is the undecorated form, which by rule-of thumb should be reproducable
    # from REPL output.
    has_unit_spacing(unit(x)) && print(io, ' ')
    show(io, unit(x))
end
function showunit(io::IO, mime::MIME, x)
    # This is the decorated form, or sometimes called multi-line form.
    # We could add spacing  in these cases, or even use the full
    # type definition of the unit.
    has_unit_spacing(unit(x)) && print(io, ' ')
    show(io, mime, unit(x))
end

"""
superscript(i::Rational)
String representation of exponent.
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


#=
  Quantities can be parsed back accurately from their un-decorated representations
  We define the necessary functions for doing that with arrays as well.
  This tells arrayshow.jl about the fact, which is used when showing
  such arrays. Prefixes to Array{Quantity} will not be printed.
=#
Base.typeinfo_implicit(::Type{<:Quantity}) = true


#=
 We reluctantly (ref.
 https://docs.julialang.org/en/v1/manual/style-guide/#Don't-overload-methods-of-base-container-types-1)
 extend how the un-decorated representation of arrays are shown.

 The vanilla representation would be
   1) Show summary
   2) modify io to inform the following function calls that types are already known.
   3) call _show_nonempty(io, X) or show_delim_array
 We want to follow this logic, but also move units out of the matrix (if all units are similar)

  The only modification here is to show the unit in short form
  after closing brackets.
  TODO consider @nospecialize, test compile + run time.
=#
function Base._show_nonempty(io::IO, X::AbstractArray{Quantity{T,D,U}, 2}, prefix::String)  where {T<:Number,D,U,N}
    ulX = ustrip(X)
    Unitlesstype = AbstractMatrix{T}
    invoke(_show_nonempty,
                   Tuple{IO, Unitlesstype, String},
                   io, ulX, prefix)
    showunit(io, eltype(X))
end

function Base.show_delim_array(io::IO,
                               itr::AbstractArray{Quantity{T,D,U}, 1},
                               op,
                               delim,
                               cl,
                               delim_one,
                               i1=first(LinearIndices(itr)),
                               l=last(LinearIndices(itr)))  where {T<:Number,D,U,N}
    ulitr = ustrip(itr)
    Unitlesstype = AbstractVector{T}
    invoke(show_delim_array,
                   Tuple{IO, Unitlesstype, Char, String, Char, Bool, Int, Int},
                   io, ulitr, op, delim, cl, delim_one, i1, l)
    showunit(io, eltype(itr))
end
