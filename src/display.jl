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

show(io::IO, x::Unit{N,D}) where {N,D} = show(io, FreeUnits{(x,), D, nothing}())

"""
    show(io::IO, x::Quantity)
Show a unitful quantity by calling `show` on the numeric value, appending a
space, and then calling `show` on a units object `U()`.
"""
function show(io::IO, x::Quantity)
    show(io, x.val)
    show_unit(io, x)
end

function show(io::IO, mime::MIME"text/plain", x::Quantity)
    show(io, mime, x.val)
    show(io, mime, unit(x))
end


function show(io::IO, mime::MIME"text/html", x::Quantity)
    ioc = IOContext(io, :unitsymbolcolor=>:yellow)
    show(ioc, x)
end


function show(io::IO, x::Quantity{S, NoDims, <:Units{
    (Unitful.Unit{:Degree, NoDims}(0, 1//1),), NoDims}}) where S
    show(io, x.val)
    show(io, unit(x))
end

function show(io::IO, x::Type{T}) where T<:Quantity
    if get(io, :shorttype, false)
        # Given the shorttype context argument (as in an array of quanities description),
        # the numeric type and unit symbol is enough info to superficially represent the type.
        print(io, numtype(x),"{")
        ioc = IOContext(io, :dontshowlocalunits=>false)
        show_unit(ioc, T)
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
        print(io,first)
        showrep(io,y)
        first = "∙"
    end
    nothing
end


"""
    show(io::IO, x::AbstractArray{Quantity{T,D,U}, N})  where {T,D,U,N}
Print the unit of an AbstractArray outside and after the array. Output can
be used to define a full copy.
"""
function show(io::IO, x::AbstractArray{Quantity{T,D,U}, N})  where {T,D,U,N} # short form
    ioc = IOContext(io, :typeinfo => T)
    show(ioc, ustrip.(x))
    show_unit(io, first(x))
end

"""
    show(io::IO, mime::MIME"text/plain", x::AbstractArray{Quantity{T,D,U}, N}) where {T,D,U,N}
Show the type information only in the header for AbstractArrays.
The type information header is formatted for readability and the output can't be used as a constructor, just
as with any AbstractArray.
"""
function show(io::IO, mime::MIME"text/plain", x::AbstractArray{Quantity{T,D,U}, N}) where {T,D,U,N} # long form
    # For abstract arrays, the REPL output can't normally be used to make a new and identical instance of
    # the array. So we don't bother to do that either, in this context.
    # This pair in IOContext specifies an informal type representation,
    # if the opposite is not already specified from upstream.
    pai = Pair(:shorttype, get(io, :shorttype, true))
    ioc = IOContext(io, pai, :dontshowlocalunits=>true)
    # Now call the method which would normally have been called if we didn't slightly interfere here.
    invoke(show, Tuple{IO, MIME{Symbol("text/plain")}, AbstractArray}, ioc, mime, x)
end

function show(io::IO, mime::MIME"application/prs.juno.inline", x::AbstractArray{Quantity{T,D,U}, N}) where {T,D,U,N} # long form
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
formatted by `superscript`.
Also prints with color when allowed by io.
Pass in
    IOContext(..., :showconstructor=>true)
to show a longer more formal form of the unit type, which can be used as a constructor.
This is done internally when the output of vanilla Julia types would also double as constructor.
"""
function showrep(io::IO, x::Unit)
    p = power(x)
    supers = superscript(p)
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

"""
    showrep(io::IO, x::Dimension)
Show the dimension, appending any exponent as formatted by `superscript`.
"""
function showrep(io::IO, x::Dimension)
    print(io, abbr(x))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x))))
end

function showrep(io::IO, x::FreeUnits{N,D,A}) where {N, D, A<:Affine}
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

function show(io::IO, x::Quantity{T,D,U}) where {T<:Rational, D, U}
    # Add paranthesis: 1//1000m² -> (1//1000)m²
    print(io, "(")
    show(io, x.val)
    print(io, ")")
    show_unit(io, x)
end

function show(io::IO, mime::MIME"text/plain", x::Quantity{T,D,U}) where {T<:Rational, D, U}
    # Add paranthesis: 1//1000m² -> (1//1000)m²
    print(io, "(")
    show(io, mime, x.val)
    print(io, ")")
    show(io, mime, unit(x))
end

function show(io::IO, mime::MIME"text/html", x::Quantity{T,D,U}) where {T<:Rational, D, U}
    # Add paranthesis: 1//1000m² -> (1//1000)m²
    ioc = IOContext(io, :unitsymbolcolor=>:yellow)
    print(ioc, "(")
    show(ioc, mime, x.val)
    print(ioc, ")")
    show_unit(ioc, mime, unit(x))
end


function show(io::IO, x::FreeUnits{N,D,A}) where {N, D, A<:Affine}
    showrep(io, x)
end
"""
Show the unit of x provided io does not have a dictionary entry with the type info.
In that case, the unit information has already been shown.
"""
function show_unit(io::IO, x)
    typeinfo = get(io, :typeinfo, Any)::Type
    if !(x isa typeinfo)
        typeinfo = Any
    end
    eltype_ctx = Base.typeinfo_eltype(typeinfo)
    eltype_x = eltype(x)
    if eltype_ctx != eltype_x
        if !isunitless(unit(x))
            # For elements in abstract arrays, we use typeinfo to get the
            # wanted format for the header info. In this method, we do not
            # want to redundantly display the remaining type info.
            if !get(io, :dontshowlocalunits, false)
                # The return type is an instance U() of the singleton type U in Quantity{T,D,U},
                # i.e. 'show' dispatches to (io, ::FreeUnits{N,D,A}).
                # Which is great, but the numeric type of x is lost.
                show(io, unit(x))
            end
        end
    end
end

"""
String representation of exponent.
"""
function superscript(i::Rational)
    deno = i.den
    nume = i.num
    if deno == 1
        if nume == 1
            ""
        elseif nume == -4
            "⁻⁴"
        elseif nume == -3
            "⁻³"
        elseif nume == -2
            "⁻²"
        elseif nume == -1
            "⁻¹"
        elseif nume == 2
            "²"
        elseif nume == 3
            "³"
        elseif nume == 4
            "⁴"
        else
            "^" * string(i.num)
        end
    else
        "^" * replace(string(i), "//" => "/")
    end
end
