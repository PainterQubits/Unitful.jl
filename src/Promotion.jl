# ------ promote_op with dimensions and units ------

for op in (.+, .-, +, -)
    @eval function promote_op{S<:Dimensions,T<:Dimensions}(::typeof($op),
        ::Type{S}, ::Type{T})
        if S==T   # add or subtract same dimension, get same dimension
            x
        else
            throw(DimensionError())
        end
    end
    @eval function promote_op{S<:Units,T<:Units}(
        ::typeof($op), ::Type{S}, ::Type{T})
        if dimension(S())==dimension(T())
            promote_type(S,T)
        else
            throw(DimensionError())
        end
    end
end

function promote_op{S<:Unitlike,T<:Unitlike}(op, ::Type{S}, ::Type{T})
    typeof(op(S(), T()))
end

# ------ promote_op with quantities ------

# quantity, quantity
function promote_op{T1,D1,U1,T2,D2,U2}(op, x::Type{Quantity{T1,D1,U1}},
    y::Type{Quantity{T2,D2,U2}})
    # figuring out numeric type can be subtle if D1 == D2 but U1 != U2.
    # in particular, consider adding 1m + 1cm... the numtype is not Int.
    unittype = promote_op(op, U1, U2)
    numtype = if D1 == D2
        promote_type(T1, T2, typeof(convfact(U1(),U2())))
    else
        promote_type(T1, T2)
    end
    if unittype == typeof(NoUnits)
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end

# number, quantity
function promote_op{R<:Number,S,D,U}(op, ::Type{R}, ::Type{Quantity{S,D,U}})
    unittype = promote_op(op, typeof(NoUnits), U)
    numtype = if D == Dimensions{()}
        promote_type(R, S, typeof(convfact(NoUnits,U())))
    else
        promote_type(R, S)
    end
    if unittype == typeof(NoUnits)
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end

function promote_op{R<:Number,S,D,U}(op, x::Type{Quantity{S,D,U}}, y::Type{R})
    unittype = promote_op(op, U, typeof(NoUnits))
    numtype = if D == Dimensions{()}
        promote_type(R, S, typeof(convfact(U(),NoUnits)))
    else
        promote_type(R, S)
    end
    if unittype == typeof(NoUnits)
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end

# ------ promote_op with units ------

# units, quantity
function promote_op{R<:Units,S,D,U}(op, ::Type{Quantity{S,D,U}}, ::Type{R})
    numtype = S
    unittype = typeof(op(U(), R()))
    if unittype == typeof(NoUnits)
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end
function promote_op{R<:Units,S,D,U}(op, x::Type{R}, y::Type{Quantity{S,D,U}})
    numtype = S
    unittype = typeof(op(R(), U()))
    if unittype == typeof(NoUnits)
        numtype
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{numtype, dimtype, unittype}
    end
end

# units, number
function promote_op{R<:Number,S<:Units}(op, ::Type{R}, ::Type{S})
    unittype = typeof(op(NoUnits, S()))
    if unittype == typeof(NoUnits)
        R
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{R, dimtype, unittype}
    end
end
function promote_op{R<:Number,S<:Units}(op, ::Type{S}, ::Type{R})
    unittype = typeof(op(S(), NoUnits))
    if unittype == typeof(NoUnits)
        R
    else
        dimtype = typeof(dimension(unittype()))
        Quantity{R, dimtype, unittype}
    end
end
# ------ promote_rule ------

# quantity, quantity (different dims)
promote_rule{S1,S2,D1,D2,U1,U2}(::Type{Quantity{S1,D1,U1}},
    ::Type{Quantity{S2,D2,U2}}) = Quantity{promote_type(S1,S2)} # was Number

# quantity, quantity (same dims)
function promote_rule{S1,S2,D,U1,U2}(::Type{Quantity{S1,D,U1}},
    ::Type{Quantity{S2,D,U2}})

    numtype = promote_type(S1,S2,typeof(convfact(U1(),U2())))
    if promote_type(U1,U2) != typeof(NoUnits)
        Quantity{numtype, D, promote_type(U1,U2)}
    else
        numtype
    end
end

# quantity, quantity (same dims, same units)
promote_rule{S1,S2,D,U}(::Type{Quantity{S1,D,U}}, ::Type{Quantity{S2,D,U}}) =
    Quantity{promote_type(S1,S2),D,U}

# number, quantity
function promote_rule{S,T<:Number,D,U}(::Type{Quantity{S,D,U}}, ::Type{T})
    if D == Dimensions{()}
        promote_type(S,T,typeof(convfact(U(),NoUnits)))
    else
        Quantity{promote_type(S,T)}
    end
end

promote_rule{S,T<:Number}(::Type{Quantity{S}}, ::Type{T}) = Quantity{promote_type(S,T)}

# With only one of these, you can get a segmentation fault because you
# fall back to the number, quantity promote_rule above and there is an infinite
# recursion.
promote_rule{T,S,D,U}(::Type{Quantity{T}}, ::Type{Quantity{S,D,U}}) = Quantity{promote_type(T,S)}
promote_rule{T,S,D,U}(::Type{Quantity{S,D,U}}, ::Type{Quantity{T}}) = Quantity{promote_type(T,S)}
