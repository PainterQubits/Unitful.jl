"""
```
macro dimension(name, abbr)
```

Extends [`Unitful.abbr`](@ref). Creates a type alias for the new dimension and
exports it.

Usage example: `@dimension 𝐋 "L" Length` (see `src/Defaults.jl`.)
"""
macro dimension(symb, abbr, name)
    s = Symbol(symb)
    x = Expr(:quote, name)
    esc(quote
        Unitful.abbr(::Unitful.Dimension{$x}) = $abbr
        const $s = Unitful.Dimensions{(Unitful.Dimension{$x}(1),)}()
        # export $s
        typealias $(name){T,U}
            Quantity{T,Unitful.Dimensions{(Unitful.Dimension{$x}(1),)},U}
        # export $(name)
    end)
end

"""
```
macro derived_dimension(dimension, derived...)
```

Creates type aliases for derived dimensions, like `[Area] = [Length]^2`.
Exports them.

Usage example: `@derived_dimension Area 𝐋^2`
"""
macro derived_dimension(symb, dims)
    esc(quote
        typealias ($symb){T,U}
            Quantity{T,typeof($dims),U}
        # export $(symb)
    end)
end


"""
```
macro baseunit(symb, name, abbr, dimension)
```

Define a base unit, typically but not necessarily SI.
"""
macro baseunit(symb, abbr, name, dimension)
    x = Expr(:quote, name)
    esc(quote
        Unitful.abbr(::Unitful.Unit{$x}) = $abbr
        Unitful.dimension(y::Unitful.Unit{$x}) = $dimension^y.power
        Unitful.basefactor(::Unitful.Unit{$x}) = (1.0, 1)
        Unitful.@prefixed_unit_symbols $symb $name
    end)
end

"""
```
macro unit(symb,abbr,name,equals,tf)
```

Define a unit.
"""
macro unit(symb,abbr,name,equals,tf)
    # name is a symbol
    # abbr is a string
    x = Expr(:quote, name)
    quote
        inex, ex = Unitful.basefactor(Unitful.unit($(esc(equals))))
        eq = Unitful.unitless($(esc(equals)))
        Base.isa(eq, Base.Integer) || Base.isa(eq, Base.Rational) ?
             (ex *= eq) : (inex *= eq)
        Unitful.abbr(::Unitful.Unit{$(esc(x))}) = $abbr
        Unitful.dimension(y::Unitful.Unit{$(esc(x))}) =
            Unitful.dimension($(esc(equals)))^y.power
        Unitful.basefactor(y::Unitful.Unit{$(esc(x))}) =
            Unitful.basefactorhelper(inex, ex, y.power)
        if $tf
            Unitful.@prefixed_unit_symbols $(esc(symb)) $(esc(name))
        else
            Unitful.@unit_symbols $(esc(symb)) $(esc(name))
        end
    end
end


"""
```
defaults()
```

Includes the file `src/Defaults.jl` from the Unitful package. This results in
common units and dimensions being generated in the `Main` module.
"""
defaults() = include(joinpath(Pkg.dir("Unitful"),"src","Defaults.jl"))
