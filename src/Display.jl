"Format a unitful quantity."
function show{T,D,U}(io::IO, x::Quantity{T,D,U})
    show(io,x.val)
    print(io," ")
    show(io,U())
    nothing
end

"Call `show` on each `UnitDatum` in the tuple held by `Units`."
function show(io::IO,x::Unitlike)
    first = ""
    tup = typeof(x).parameters[1]
    map(tup) do y
        print(io,first)
        show(io,y)
        first = " "
    end
    nothing
end

"Show the unit, prefixing with any decimal prefix and appending the exponent."
function show(io::IO, x::Unit)
    print(io, prefix(Val{tens(x)}()))
    print(io, abbr(x))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x))))
    nothing
end

"Show the dimension, appending any exponent."
function show(io::IO, x::Dimension)
    print(io, abbr(x))
    print(io, (power(x) == 1//1 ? "" : superscript(power(x))))
end

"Prints exponents nicely with Unicode."
superscript(i::Rational) = begin
    i.den == 1 ? "^"*string(i.num) : "^"*replace(string(i),"//","/")
end
