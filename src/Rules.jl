"For the same unit and same power, default to the larger of the two prefixes."
+{A,B,C,S}(x::DatumTuple{A,B,S}, y::DatumTuple{A,C,S}) = UnitDatum(A,max(B,C),S)

"For the same unit and different power, report a dimensional mismatch."
+{A,B,C,S,T}(x::DatumTuple{A,B,S}, y::DatumTuple{A,C,T}) =
    error("Dimensional mismatch.")

"""
Given a unit abbreviation and a `Unit` object, will define and export
`UnitDatum` for each possible SI prefix on that unit.

e.g. nm, cm, m, km, ... all get defined when `@uall m _Meter` is typed.
"""
macro uall(x,y)
    expr = Expr(:block)

    for (k,v) in prefixdict
        s = symbol(v,x)
        ea = quote
            const $(esc(s)) = UnitData(UnitDatum(($y),$k,1))
            export $(esc(s))
        end
        push!(expr.args, ea)
    end

    expr
end
