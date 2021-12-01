function rrule(UT::Type{Quantity{T,D,U}}, x::Number) where {T,D,U}
    unitful_x = Quantity{T,D,U}(x)
    projector_x = ProjectTo(x)
    uq_pullback(Δx) = (NoTangent(), projector_x(Δx) * oneunit(UT))
    return unitful_x, uq_pullback
end

function ProjectTo(x::Quantity)
    project_val = ProjectTo(x.val) # Project the literal number
    return ProjectTo{typeof(x)}(; project_val = project_val)
end

function (projector::ProjectTo{<:Quantity})(x::Number)
    new_val = projector.project_val(ustrip(x))
    return new_val*unit(x)
end

# Project Unitful Quantities onto numerical types by projecting the value and carrying units
(project::ProjectTo{<:Real})(dx::Quantity) = project(ustrip(dx))*unit(dx)
(project::ProjectTo{<:Complex})(dx::Quantity) = project(ustrip(dx))*unit(dx)

function rrule(::typeof(*), x::Quantity, y::Units, z::Units...)
    Ω = *(x, y, z...)
    project_x = ProjectTo(x)
    function times_pb(Δ)
        δ = project_x(Δ)
        units = (y, z...)
        return (NoTangent(), *(δ, y, z...), ntuple(_ -> NoTangent(), length(units))...)
    end
    return Ω, times_pb
end

rrule(::typeof(/), x::Number, y::Units) = rrule(*, x, inv(y))
rrule(::typeof(/), x::Units, y::Number) = rrule(*, x, inv(y))
