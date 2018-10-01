for f in (:/, :*)
    @eval function $f(::Type{S}, ::Type{T}) where {S<:Quantity, T<:Quantity}
        A = typeof($f(oneunit(S), oneunit(T)))
        return A
    end
    @eval function $f(::Type{Quantity{S}}, ::Type{T}) where {S, T<:Quantity}
        A = typeof($f(oneunit(S), oneunit(numtype(T))))
        return Quantity{A}
    end
    @eval function $f(::Type{T}, ::Type{Quantity{S}}) where {S, T<:Quantity}
        A = typeof($f(oneunit(numtype(T)), oneunit(S)))
        return Quantity{A}
    end
    @eval function ($f(::Type{Quantity{T1,D1}}, ::Type{Quantity{T2,D2,U2}})
            where {T1,T2,D1,D2,U2})
        A = typeof($f(oneunit(T1), oneunit(T2)))
        B = typeof($f(D1(), D2()))
        return Quantity{A, B}
    end
    @eval function ($f(::Type{Quantity{T1,D1,U1}}, ::Type{Quantity{T2,D2}})
            where {T1,T2,D1,D2,U1})
        A = typeof($f(oneunit(T1), oneunit(T2)))
        B = typeof($f(D1(), D2()))
        return Quantity{A, B}
    end
end
