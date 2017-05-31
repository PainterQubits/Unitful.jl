@compat Base.linspace(start::Quantity{<:Real}, stop, len::Integer) =
    _linspace(promote(start, stop)..., len)
@compat Base.linspace(start, stop::Quantity{<:Real}, len::Integer) =
    _linspace(promote(start, stop)..., len)
@compat Base.linspace(start::Quantity{<:Real}, stop::Quantity{<:Real}, len::Integer) =
    _linspace(promote(start, stop)..., len)
(Base.linspace(start::T, stop::T, len::Integer) where (T<:Quantity{<:Real})) =
    LinSpace{T}(start, stop, len)
(Base.linspace(start::T, stop::T, len::Integer) where (T<:Quantity{<:Integer})) =
    linspace(Float64, ustrip(start), ustrip(stop), len, 1)*unit(T)

function _linspace{T}(start::Quantity{T}, stop::Quantity{T}, len::Integer)
    dimension(start) != dimension(stop) && throw(DimensionError(start, stop))
    linspace(start, stop, len)
end

@compat function colon(start::Quantity{<:Real}, step, stop::Quantity{<:Real})
    dimension(start) != dimension(stop) && throw(DimensionError(start, stop))
    T = promote_type(typeof(start),typeof(stop))
    return colon(convert(T,start), step, convert(T,stop))
end

function colon(start::A, step::B, stop::A) where A<:Quantity{<:Real} where B<:Quantity{<:Real}
    dimension(start) != dimension(step) && throw(DimensionError(start, step))
    colon(promote(start, step, stop)...)
end

# Traits for quantities using triangular dispatch
import Base: TypeOrder, TypeArithmetic, HasOrder,
    ArithmeticRounds, ArithmeticOverflows
@compat (::Type{TypeOrder})(::Type{<:Quantity{<:Real}}) = HasOrder()
@compat (::Type{TypeArithmetic})(::Type{<:Quantity{<:AbstractFloat}}) =
    ArithmeticRounds()
@compat (::Type{TypeArithmetic})(::Type{<:Quantity{<:Integer}}) =
    ArithmeticOverflows()

@compat (colon(start::T, step::T, stop::T) where T <: Quantity{<:Real}) =
    _colon(TypeOrder(T), TypeArithmetic(T), start, step, stop)
_colon{T}(::HasOrder, ::Any, start::T, step, stop::T) = StepRange(start, step, stop)
_colon{T}(::HasOrder, ::ArithmeticRounds, start::T, step, stop::T) =
    StepRangeLen(start, step, floor(Int, (stop-start)/step)+1)
_colon{T}(::Any, ::Any, start::T, step, stop::T) =
    StepRangeLen(start, step, floor(Int, (stop-start)/step)+1)

# Opt into TwicePrecision functionality
*(x::Base.TwicePrecision, y::Units) = Base.TwicePrecision(x.hi*y, x.lo*y)
*(x::Base.TwicePrecision, y::Quantity) = (x * ustrip(y)) * unit(y)
function colon(start::T, step::T, stop::T) where (T<:Quantity{S}
    where S<:Union{Float16,Float32,Float64})
    # This will always return a StepRangeLen
    r = colon(ustrip(start), ustrip(step), ustrip(stop))
    return r*unit(T)
end
function Base.linspace(start::T, stop::T, len::Integer) where (T<:Quantity{S}
    where S<:Union{Float16,Float32,Float64})
    linspace(ustrip(start), ustrip(stop), len)*unit(T)
end

# No need to confuse things by changing the type once units are on there,
# if we can help it.
*(r::StepRangeLen, y::Units) = StepRangeLen(r.ref*y, r.step*y, length(r), r.offset)
*(r::LinSpace, y::Units) = LinSpace(r.start*y, r.stop*y, length(r))
*(r::StepRange, y::Units) = StepRange(r.start*y, r.step*y, r.stop*y)
