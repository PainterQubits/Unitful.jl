import .Latexify: @latexrecipe, latexify, FancyNumberFormatter
import .LaTeXStrings: LaTeXString

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


