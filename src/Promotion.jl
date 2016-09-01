# quantity, quantity
function promote_op{T1,D1,U1,T2,D2,U2}(op, ::Type{Quantity{T1,D1,U1}}, ::Type{Quantity{T2,D2,U2}})
    numtype = promote_op(op, T1, T2)
    unittype = typeof(op(U1(), U2()))
    if unittype == Units{()}
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end

# quantity, abstract quantity
function promote_op{S,T,D,U}(op, ::Type{AbstractQuantity{S}}, ::Type{Quantity{T,D,U}})
    numtype = promote_op(op, S, T)
    AbstractQuantity{numtype}
end
promote_op{S,T,D,U}(op, x::Type{Quantity{T,D,U}}, y::Type{AbstractQuantity{S}}) =
    promote_op(op, y, x)

# quantity, number
function promote_op{R<:Number,S,D,U}(op, ::Type{R}, ::Type{Quantity{S,D,U}})

    numtype = promote_op(op,R,S)
    unittype = typeof(op(Units{()}(), U()))
    if unittype == Units{()}
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end
promote_op{R<:Number,S,D,U}(op, x::Type{Quantity{S,D,U}}, y::Type{R}) =
    promote_op(op, y, x)

# abstract quantity, abstract quantity
function promote_op{S,T}(op, ::Type{AbstractQuantity{S}}, ::Type{AbstractQuantity{T}})
    numtype = promote_op(op, S, T)
    AbstractQuantity{numtype}
end

# abstract quantity, number
function promote_op{S,T<:Number}(op, ::Type{AbstractQuantity{S}}, ::Type{T})
    numtype = promote_op(op, S, T)
    AbstractQuantity{numtype}
end
promote_op{S,T<:Number}(op, x::Type{T}, y::Type{AbstractQuantity{S}}) =
    promote_op(op, y, x)

# ------

# units, quantity
function promote_op{R<:Units,S,D,U}(op, ::Type{Quantity{S,D,U}}, ::Type{R})
    numtype = S
    unittype = typeof(op(U(), R()))
    if unittype == Units{()}
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end
promote_op{R<:Units,S,D,U}(op, x::Type{R}, y::Type{Quantity{S,D,U}}) =
    promote_op(op, y, x)

# units, abstract quantity
promote_op{R<:Units,S}(op, ::Type{R}, ::Type{AbstractQuantity{S}}) = AbstractQuantity{S}
promote_op{R<:Units,S}(op, ::Type{AbstractQuantity{S}}, ::Type{R}) = AbstractQuantity{S}

# units, number
function promote_op{R<:Number,S<:Units}(op, x::Type{R}, y::Type{S})
    unittype = typeof(op(Units{()}(), S()))
    if unittype == Units{()}
        R
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{x, dimtype, unittype}
    end
end
promote_op{R<:Number,S<:Units}(op, x::Type{S}, y::Type{R}) =
    promote_op(op, y, x)

# ------

# promotion rule for typesprom
promote_rule{S1,S2,D1,D2,U1,U2}(::Type{Quantity{S1,D1,U1}},
    ::Type{Quantity{S2,D2,U2}}) = AbstractQuantity{promote_type(S1,S2)}

promote_rule{S1,S2,D,U}(::Type{Quantity{S1,D,U}}, ::Type{Quantity{S2,D,U}}) =
    Quantity{promote_type(S1,S2),D,U}

promote_rule{S,T,D,U}(::Type{AbstractQuantity{S}}, ::Type{Quantity{T,D,U}}) =
    AbstractQuantity{promote_type(S,T)}
promote_rule{S,T,D,U}(x::Type{Quantity{T,D,U}}, y::Type{AbstractQuantity{S}}) =
    promote_rule(y,x)

promote_rule{S,T<:Number,D,U}(::Type{Quantity{S,D,U}}, ::Type{T}) =
    AbstractQuantity{promote_type(S,T)}
promote_rule{S,T<:Number,D,U}(x::Type{T}, y::Type{Quantity{S,D,U}}) =
    promote_rule(y,x)

promote_rule{S,T}(::Type{AbstractQuantity{S}}, ::Type{AbstractQuantity{T}}) =
    AbstractQuantity{promote_type(S,T)}

promote_rule{S,T<:Number}(::Type{AbstractQuantity{S}}, ::Type{T}) =
    AbstractQuantity{promote_type(S,T)}

promote_rule{S,T<:Number}(x::Type{T}, y::Type{AbstractQuantity{S}}) =
    promote_rule(y,x)
