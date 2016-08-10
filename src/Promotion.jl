@generated function promote_op{T1,D1,U1,T2,D2,U2}(op,
    ::Type{Quantity{T1,D1,U1}}, ::Type{Quantity{T2,D2,U2}})

    numtype = promote_op(op(), T1, T2)
    resunits = typeof(op()(U1(), U2()))
    resdim = typeof(dimension(resunits()))
    :(Quantity{$numtype, $resdim, $resunits})
end

@eval begin
    # number, quantity
    @generated function promote_op{R<:Real,S,D,U}(op,
        ::Type{R}, ::Type{Quantity{S,D,U}})

        numtype = promote_op(op(),R,S)
        unittype = typeof(op()(Units{()}(), U()))
        dimtype = typeof(dimension(unittype()))
        :(Quantity{$numtype, $dimtype, $unittype})
    end

    # quantity, number
    @generated function promote_op{R<:Real,S,D,U}(op,
        ::Type{Quantity{S,D,U}}, ::Type{R})

        numtype = promote_op(op(),S,R)
        unittype = typeof(op()(U(), Units{()}()))
        dimtype = typeof(dimension(unittype()))
        :(Quantity{$numtype, $dimtype, $unittype})
    end

    # unit, quantity
    @generated function promote_op{R<:Units,S,D,U}(op,
        ::Type{Quantity{S,D,U}}, ::Type{R})

        numtype = S
        unittype = typeof(op()(U(), R()))
        dimtype = typeof(dimension(unittype()))
        :(Quantity{$numtype, $dimtype, $unittype})
    end

    # quantity, unit
    @generated function promote_op{R<:Units,S,D,U}(op,
        ::Type{R}, ::Type{Quantity{S,D,U}})

        numtype = S
        unittype = typeof(op()(R(), U()))
        dimtype = typeof(dimension(unittype()))
        :(Quantity{$numtype, $dimtype, $unittype})
    end
end

@eval begin
    @generated function promote_op{R<:Real,S<:Units}(op,
        x::Type{R}, y::Type{S})
        unittype = typeof(op()(Units{()}(), S()))
        dimtype = typeof(dimension(unittype()))
        :(Quantity{x, $dimtype, $unittype})
    end

    @generated function promote_op{R<:Real,S<:Units}(op,
        y::Type{S}, x::Type{R})
        unittype = typeof(op()(S(), Units{()}()))
        dimtype = typeof(dimension(unittype()))
        :(Quantity{x, $dimtype, $unittype})
    end
end

promote_rule{S,T,D,U}(::Type{Quantity{S,D,U}},::Type{Quantity{T,D,U}}) =
    Quantity{promote_type(S,T),D,U}
