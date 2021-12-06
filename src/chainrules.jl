function rrule(UT::Type{Quantity{T,D,U}}, x::Number) where {T,D,U}
    unitful_x = Quantity{T,D,U}(x)
    projector_x = ProjectTo(x)
    uq_pullback(Δx) = (NoTangent(), projector_x(Δx) * oneunit(UT))
    return unitful_x, uq_pullback
end

function (projector::ProjectTo{<:Quantity})(x::Number)
    new_val = projector.project_val(ustrip(x))
    return new_val*unit(x)
end

# Project Unitful Quantities onto numerical types by projecting the value and carrying units
ProjectTo(x::Quantity) = ProjectTo(x.val)

(project::ProjectTo{<:Real})(dx::Quantity) = project(ustrip(dx))*unit(dx)
(project::ProjectTo{<:Complex})(dx::Quantity) = project(ustrip(dx))*unit(dx)

function rrule(::typeof(*), x::Quantity, y::Units, z::Units...)
    Ω = *(x, y, z...)
    function times_pb(Δ)
        nots = ntuple(_ -> NoTangent(), 1 + length(z))
        return (NoTangent(), *(ProjectTo(x)(Δ), y, z...), nots...)
    end
    return Ω, times_pb
end

rrule(::typeof(/), x::Number, y::Units) = rrule(*, x, inv(y))
rrule(::typeof(/), x::Units, y::Number) = rrule(*, x, inv(y))
