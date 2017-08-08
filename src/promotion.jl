# quantity, quantity (different dims)
Base.promote_rule(::Type{Quantity{S1,D1,U1}},
        ::Type{Quantity{S2,D2,U2}}) where {S1,D1,U1,S2,D2,U2} =
    Quantity{promote_type(S1,S2)}

# quantity, quantity (same dims, different units)
function Base.promote_rule(::Type{Quantity{S1,D,U1}},
    ::Type{Quantity{S2,D,U2}}) where {S1,S2,D,U1,U2}

    p = promote_unit(U1(), U2())
    numtype = promote_type(S1,S2,
        promote_type(typeof(convfact(p,U1())), typeof(convfact(p,U2()))))
    if !isunitless(p)
        if U1 <: ContextUnits && U2 <: ContextUnits
            up1 = upreferred(U1())
            if up1 === upreferred(U2())
                return Quantity{numtype,D,typeof(ContextUnits(p,up1))}
            else
                return Quantity{numtype,D,typeof(p)}
            end
        elseif U1 <: ContextUnits || U2 <: ContextUnits
            return Quantity{numtype,D,typeof(ContextUnits(p,p))}
        else
            return Quantity{numtype,D,typeof(p)}
        end
    else
        return numtype
    end
end

# number, quantity
function Base.promote_rule(::Type{Quantity{S,D,U}}, ::Type{T}) where {S,T <: Number,D,U}
    if D == typeof(NoDims)
        promote_type(S,T,typeof(convfact(NoUnits,U())))
    else
        Quantity{promote_type(S,T)}
    end
end

Base.promote_rule(::Type{Quantity{S}}, ::Type{T}) where {S,T <: Number} =
    Quantity{promote_type(S,T)}

# With only one of these, you can get a segmentation fault because you # fall back to the
# number, quantity promote_rule above and there is an infinite recursion.
Base.promote_rule(::Type{Quantity{T}}, ::Type{Quantity{S,D,U}}) where {T,S,D,U} =
    Quantity{promote_type(T,S)}

Base.promote_rule(::Type{Quantity{S,D,U}}, ::Type{Quantity{T}}) where {T,S,D,U} =
    Quantity{promote_type(T,S)}
