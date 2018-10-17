# Same as Base.unwrap_unionall, but I don't want to rely on unexported functions.
function unwrap_unionall(@nospecialize(a))
    while isa(a, UnionAll)
        a = a.body
    end
    return a
end

for f in (:/, :*)
    @eval @generated function ($f(::Type{Q1}, ::Type{Q2}) where
            {Q1 <: Quantity, Q2 <: Quantity})
        Q1u = unwrap_unionall(Q1)
        Q2u = unwrap_unionall(Q2)
        T1, T2 = Q1u.parameters[1], Q2u.parameters[1]
        D1, D2 = Q1u.parameters[2], Q2u.parameters[2]
        U1, U2 = Q1u.parameters[3], Q2u.parameters[3]
        if T1 isa TypeVar || T2 isa TypeVar
            return :($(Quantity))
        else
            A = typeof($f(oneunit(T1), oneunit(T2)))
            if D1 isa TypeVar || D2 isa TypeVar
                return :($(Quantity{A}))
            else
                B = typeof($f(D1(), D2()))
                if U1 isa TypeVar || U2 isa TypeVar
                    return :($(Quantity{A,B}))
                else
                    C = typeof($f(oneunit(Q1), oneunit(Q2)))
                    return :($C)
                end
            end
        end
    end

    @eval $f(::Type{Q}, ::Type{T}) where {T<:Number, Q<:Quantity} = $f(Q, Quantity{T})
    @eval $f(::Type{T}, ::Type{Q}) where {T<:Number, Q<:Quantity} = $f(Quantity{T}, Q)
end

for f in (:+, :-)
    @eval @generated function ($f(::Type{Q1}, ::Type{Q2}) where
            {Q1 <: Quantity, Q2 <: Quantity})
        Q1u = unwrap_unionall(Q1)
        Q2u = unwrap_unionall(Q2)
        T1, T2 = Q1u.parameters[1], Q2u.parameters[1]
        D1, D2 = Q1u.parameters[2], Q2u.parameters[2]
        U1, U2 = Q1u.parameters[3], Q2u.parameters[3]
        if T1 isa TypeVar || T2 isa TypeVar
            return :($(Quantity))
        else
            # need float because in general unit conversions may have floating-point factors
            A = typeof($f(oneunit(float(T1)), oneunit(float(T2))))
            if D1 isa TypeVar || D2 isa TypeVar
                return :($(Quantity{A}))
            else
                (D1 == D2) || return :(throw(DimensionError($(D1()), $(D2()))))
                if U1 isa TypeVar || U2 isa TypeVar
                    return :($(Quantity{A,D1}))
                else
                    C = typeof($f(oneunit(Q1), oneunit(Q2)))
                    return :($C)
                end
            end
        end
    end

    @eval @generated function $f(::Type{N}, ::Type{Q}) where {N<:Number, Q<:Quantity}
        Qu = unwrap_unionall(Q)
        T = Qu.parameters[1]
        D = Qu.parameters[2]
        U = Qu.parameters[3]
        if T isa TypeVar
            return :($(Quantity))
        else
            A = typeof($f(oneunit(float(N)), oneunit(float(T))))
            if D isa TypeVar
                return :($(Quantity{A}))
            else
                (D <: typeof(NoDims)) || return :(throw(DimensionError($(D()), NoDims)))
                if U isa TypeVar
                    return :($(Quantity{A,D}))
                else
                    C = typeof($f(oneunit(N), oneunit(Q)))
                    return :($C)
                end
            end
        end
    end

    @eval $f(::Type{Q}, ::Type{N}) where {N<:Number, Q<:Quantity} = $f(N, Q)
end
