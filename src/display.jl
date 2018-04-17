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

"""
    show(io::IO, x::Quantity)
Show a unitful quantity by calling `show` on the numeric value, appending a
space, and then calling `show` on a units object `U()`.
"""
function show(io::IO, x::Quantity)
    show(io,x.val)
    if !isunitless(unit(x))
        print(io," ")
        show(io, unit(x))
    end
    nothing
end

function show(io::IO, x::Quantity{S, Dimensions{()}, <:Units{
    (Unitful.Unit{:Degree,Unitful.Dimensions{()}}(0, 1//1),),
        Unitful.Dimensions{()}}}) where S
    show(io, x.val); show(io, unit(x)); nothing
end

"""
    show(io::IO, x::Unitlike)
Call [`Unitful.showrep`](@ref) on each object in the tuple that is the type
variable of a [`Unitful.Units`](@ref) or [`Unitful.Dimensions`](@ref) object.
"""
function show(io::IO, x::Unitlike)
    first = ""
    foreach(sortexp(typeof(x).parameters[1])) do y
        print(io,first)
        showrep(io,y)
        first = " "
    end
    nothing
end

"""
    sort_exp(xs)
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
    i.den == 1 ? "^"*string(i.num) : "^"*replace(string(i),"//","/")
end
