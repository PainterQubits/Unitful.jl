# ------ promote_op with dimensions ------

for op in (.+, .-, +, -)
    @eval function promote_op{S}(::typeof($op), x::Type{Dimensions{S}}, y::Type{Dimensions{S}})
        x   # add or subtract same dimension, get same dimension
    end
    @eval function promote_op{S,T}(::typeof($op), x::Type{Dimensions{S}}, y::Type{Dimensions{T}})
        error("Dimension mismatch.")
    end
end
for op in (.*, ./, *, /, //)
    @eval function promote_op{S}(::typeof($op), x::Type{Dimensions{S}}, y::Type{Dimensions{S}})
        typeof(op(x(),y()))
    end
    @eval function promote_op{S,T}(::typeof($op), x::Type{Dimensions{S}}, y::Type{Dimensions{T}})
        error("Unsupported promote_op.")
    end
end

# ------ promote_op with quantities ------

# quantity, quantity
function promote_op{T1,D1,U1,T2,D2,U2}(op, x::Type{Quantity{T1,D1,U1}},
    y::Type{Quantity{T2,D2,U2}})
    # figuring out numeric type can be subtle if D1 == D2 but U1 != U2.
    # in particular, consider adding 1m + 1cm... the numtype is not Int.
    q1,q2 = one(T1)*U1(), one(T2)*U2()
    qr = op(q1,q2)
    unittype = typeof(unit(qr))
    numtype = typeof(qr/unit(qr))
    if unittype == Units{()}
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end

# dim'd, quantity
promote_op{T2,D1,D2,U}(op, ::Type{DimensionedQuantity{D1}},
    ::Type{Quantity{T2,D2,U}}) = DimensionedQuantity{promote_op(op,D1,D2)}
promote_op{T2,D1,D2,U}(op, x::Type{Quantity{T2,D2,U}},
    y::Type{DimensionedQuantity{D1}}) = DimensionedQuantity{promote_op(op,D2,D1)}

# number, quantity
promote_op{R<:Number,S,D,U}(op, ::Type{R}, ::Type{Quantity{S,D,U}}) = Number
promote_op{R<:Number,S,D,U}(op, x::Type{Quantity{S,D,U}}, y::Type{R}) = Number

# dim'd, dim'd
promote_op{D1,D2}(op, ::Type{DimensionedQuantity{D1}},
    ::Type{DimensionedQuantity{D2}}) = DimensionedQuantity{promote_op(op,D1,D2)}

# dim'd, number
promote_op{D}(op, ::Type{DimensionedQuantity{D}}, ::Type{Number}) = Number
promote_op{D}(op, ::Type{Number}, ::Type{DimensionedQuantity{D}}) = Number


# ------ promote_op with units ------

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

# ------ promote_rule ------

# quantity, quantity (different dims)
promote_rule{S1,S2,D1,D2,U1,U2}(::Type{Quantity{S1,D1,U1}},
    ::Type{Quantity{S2,D2,U2}}) = Number

# quantity, quantity (same dims)
promote_rule{S1,S2,D,U1,U2}(::Type{Quantity{S1,D,U1}},
    ::Type{Quantity{S2,D,U2}}) = DimensionedQuantity{D}

# quantity, quantity (same dims, same units)
promote_rule{S1,S2,D,U}(::Type{Quantity{S1,D,U}}, ::Type{Quantity{S2,D,U}}) =
    Quantity{promote_type(S1,S2),D,U}

# dim'd, quantity (different dims)
promote_rule{S2,D1,D2,U}(::Type{DimensionedQuantity{D1}},
    ::Type{Quantity{S2,D2,U}}) = Number
promote_rule{S2,D1,D2,U}(x::Type{Quantity{S2,D2,U}},
    y::Type{DimensionedQuantity{D1}}) = promote_rule(y,x)

# dim'd, quantity (same dims)
promote_rule{S2,D,U}(::Type{DimensionedQuantity{D}},
    ::Type{Quantity{S2,D,U}}) = DimensionedQuantity{D}
promote_rule{S2,D,U}(x::Type{Quantity{S2,D,U}},
    y::Type{DimensionedQuantity{D}}) = promote_rule(y,x)

# number, quantity
promote_rule{S,T<:Number,D,U}(::Type{Quantity{S,D,U}}, ::Type{T}) = Number
promote_rule{S,T<:Number,D,U}(x::Type{T}, y::Type{Quantity{S,D,U}}) =
    promote_rule(y,x)

# dim'd, dim'd (different dims)
promote_rule{D1,D2}(::Type{DimensionedQuantity{D1}},
    ::Type{DimensionedQuantity{D2}}) = Number

# dim'd, dim'd (same dims)
promote_rule{D}(::Type{DimensionedQuantity{D}},
    ::Type{DimensionedQuantity{D}}) = DimensionedQuantity{D}

# dim'd, number
promote_rule{D,T<:Number}(::Type{DimensionedQuantity{D}}, ::Type{T}) =
    Number
promote_rule{D,T<:Number}(x::Type{T}, y::Type{DimensionedQuantity{D}}) =
    promote_rule(y,x)
