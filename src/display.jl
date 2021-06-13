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
        Typeinfo = get(io, :typeinfo, Nothing)::Type
        if isconcretetype(Typeinfo) && isa(x, Typeinfo)
            # No need to show the unit twice, no need for potential brackets
            showval(io, x.val, false)
        else
            # If TypeInfo covers more than one type, it can mean that the
            # calling context is a mixed collection. We need to
            # show units per element.
            showval(io, x.val, true)
            showunit(io, x)
        end
    end
end

function show(io::IO, mime::MIME"text/plain", x::Quantity)
    # This is the decorated form. Users may want to specialize on this
    # for specific units.
    if isunitless(unit(x))
        # No units to show, no need for potential brackets
        showval(io, x.val, false)
    else
        Typeinfo = get(io, :typeinfo, Nothing)::Type
        if isconcretetype(Typeinfo) && isa(x, Typeinfo)
            # No need to show the unit twice, no need for potential brackets
            showval(io, x.val, false)
        else
            # If TypeInfo covers more than one type, it can mean that the
            # calling context is a mixed collection. We need to
            # show units per element.
            showval(io, x.val, true)
            showunit(io, x)
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
Call [`Unitfu.showrep`](@ref) on each object in the tuple that is the type
variable of a [`Unitfu.Units`](@ref) or [`Unitfu.Dimensions`](@ref) object.
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
formatted by [`Unitfu.superscript`](@ref).
Also prints with color when allowed by io.
"""
function showrep(io::IO, x::Unit)
    col = get(io, :unitsymbolcolor, :cyan)
    printstyled(io, color = col, prefix(x), abbr(x), power(x) == 1//1 ? "" : superscript(power(x); io = io))
    nothing
end
"""
    showrep(io::IO, x::Dimension)
    Show the dimension, appending any exponent as formatted by
    [`Unitfu.superscript`](@ref).
"""
function showrep(io::IO, x::Dimension)
    print(io, abbr(x))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x); io=io)))
end


"""
    showunit(io::IO, x)
Show the unit of x, prefixed by space depending on the unit.
"""
function showunit(io::IO, x)
    has_unit_spacing(unit(x)) && print(io, ' ')
    show(io, unit(x))
end
showunit(io::IO, ::MIME, x) = showunit(io, x)

"""
Returns exponents as a string.

This function returns the value as a string. It does not print to `io`. `io` is
only used for IO context values. If `io` contains the `:fancy_exponent`
property and the value is a `Bool`, this value will override the behavior of
fancy exponents.
"""
function superscript(i::Rational; io::Union{IO, Nothing} = nothing)
    if io === nothing
        iocontext_value = nothing
    else
        iocontext_value = get(io, :fancy_exponent, nothing)
    end
    if iocontext_value isa Bool
        fancy_exponent = iocontext_value
    else
        v = get(ENV, "UNITFUL_FANCY_EXPONENTS", "true")
        t = tryparse(Bool, lowercase(v))
        fancy_exponent = (t === nothing) ? false : t
    end
    if fancy_exponent
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
  This tells arrayshow.jl about the fact  that Quantities can be parsed back
  accurately from their un-decorated representations.
  We define the necessary functions for doing that with arrays and tuples as well.
  , which is used when showing
  such arrays. Prefixes to Array{Quantity} will not be printed.
=#
@eval Base.typeinfo_implicit(::Type{<:Quantity}) = true

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
=#
function Base._show_nonempty(io::IO, X::AbstractMatrix{Quantity{T,D,U}}, prefix::String)  where {T,D,U}
    ulX = ustrip(X)
    Unitlesstype = AbstractMatrix{T}
    invoke(_show_nonempty,
                   Tuple{IO, Unitlesstype, String},
                   io, ulX, prefix)
    showunit(io, eltype(X))
end

#=
  Target collections shown as abstract vectors where all elements are of the same quanity type (unit and numeric type).
  The method is unchanged from the method for itr::Union{AbstractArray,SimpleVector}, from Julia 1.4.0, but attaches
  unit context before displaying elements, and show units after closing brackets.
  Units for individual elements are not shown because the io context is used to convey that they are shown by the calling
  context - at the end.
 =#
function Base.show_delim_array(io::IO, itr::AbstractArray{<:Quantity}, op, delim, cl,
                          delim_one, i1=first(LinearIndices(itr)), l=last(LinearIndices(itr)))
    # Since we are going to show the quanity type afterwards, let's inform the functions which show individual elements
    io = IOContext(io, :typeinfo => eltype(itr))
    # What follows, until the last line, is a direct copy of the less specialized function.
    print(io, op)
    if !show_circular(io, itr)
        recur_io = IOContext(io, :SHOWN_SET => itr)
        first = true
        i = i1
        if l >= i1
            while true
                if !isassigned(itr, i)
                    print(io, undef_ref_str)
                else
                    x = itr[i]
                    show(recur_io, x)
                end
                i += 1
                if i > l
                    delim_one && first && print(io, delim)
                    break
                end
                first = false
                print(io, delim)
                print(io, ' ')
            end
        end
    end
    print(io, cl)
    # This is  added to Julia 1.4.0 Base.show_delim_array for itr::Union(AbstractArray, SimpleVector)...
    showunit(io, eltype(itr))
end

#=
  Target
  This is closely based to the non-typed method of the function, from Julia 1.4.0, but strips units from the
  inside of brackets and shows units after the bracket.

  Target tuples of quantities where all elements of the tuple are of the same (numeric and unit) type.
  The method is unchanged from the method for itr::Union{AbstractArray,SimpleVector}, from Julia 1.4.0, but attaches
  unit context before displaying elements, and show units after closing brackets.
  Units for individual elements are not shown because the io context is used to convey that they are shown by the calling
  context - at the end.

=#
function Base.show_delim_array(io::IO,
                               itr:: NTuple{N, <:Quantity},
                               op,
                               delim,
                               cl,
                               delim_one,
                               i1=1,
                               n=typemax(Int)) where {N}
    # Since we are going to show the quanity type afterwards, let's inform the functions which show individual elements
    io = IOContext(io, :typeinfo => eltype(itr))
    # What follows, until the last line, is a direct copy of the less specialized function.
    print(io, op)
    if !show_circular(io, itr)
        recur_io = IOContext(io, :SHOWN_SET => itr)
        y = iterate(itr)
        first = true
        i0 = i1-1
        while i1 > 1 && y !== nothing
            y = iterate(itr, y[2])
            i1 -= 1
        end
        if y !== nothing
            typeinfo = get(io, :typeinfo, Any)
            while true
                x = y[1]
                y = iterate(itr, y[2])
                show(IOContext(recur_io, :typeinfo => itr isa typeinfo <: Tuple ?
                                             fieldtype(typeinfo, i1+i0) :
                                             typeinfo),
                     x)
                i1 += 1
                if y === nothing || i1 > n
                    delim_one && first && print(io, delim)
                    break
                end
                first = false
                print(io, delim)
                print(io, ' ')
            end
        end
    end
    print(io, cl)
    # This is added to Julia 1.4.0 Base.show_delim_array (duck-typed, eltype may give a Type{Union{}}
    showunit(io, eltype(itr))
end
