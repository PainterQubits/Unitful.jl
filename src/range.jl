const colon = Base.:(:)

import Base: ArithmeticRounds
import Base: OrderStyle, Ordered, ArithmeticStyle, ArithmeticWraps
import Base.Broadcast: DefaultArrayStyle, broadcasted

*(y::Units, r::AbstractRange) = *(r,y)
*(r::AbstractRange, y::Units, z::Units...) = *(r, *(y,z...))

Base._range(start::Quantity{<:Real}, ::Nothing, stop, len::Integer) =
    _range(promote(start, stop)..., len)
Base._range(start, ::Nothing, stop::Quantity{<:Real}, len::Integer) =
    _range(promote(start, stop)..., len)
Base._range(start::Quantity{<:Real}, ::Nothing, stop::Quantity{<:Real}, len::Integer) =
    _range(promote(start, stop)..., len)
(Base._range(start::T, ::Nothing, stop::T, len::Integer) where (T<:Quantity{<:Real})) =
    LinRange{T}(start, stop, len)
(Base._range(start::T, ::Nothing, stop::T, len::Integer) where (T<:Quantity{<:Integer})) =
    Base._linspace(Float64, ustrip(start), ustrip(stop), len, 1)*unit(T)
function Base._range(start::T, ::Nothing, stop::T, len::Integer) where (T<:Quantity{S}
    where S<:Union{Float16,Float32,Float64})
    range(ustrip(start), stop=ustrip(stop), length=len) * unit(T)
end
function _range(start::Quantity{T}, stop::Quantity{T}, len::Integer) where {T}
    dimension(start) != dimension(stop) && throw(DimensionError(start, stop))
    Base._range(start, nothing, stop, len)
end
function Base._range(a::T, st::T, ::Nothing, len::Integer) where (T<:Quantity{S}
        where S<:Union{Float16,Float32,Float64})
    return Base._range(ustrip(a), ustrip(st), nothing, len) * unit(T)
end
Base._range(a::Quantity{<:Real}, st::Quantity{<:AbstractFloat}, ::Nothing, len::Integer) =
    Base._range(float(a), st, nothing, len)
Base._range(a::Quantity{<:AbstractFloat}, st::Quantity{<:Real}, ::Nothing, len::Integer) =
    Base._range(a, float(st), nothing, len)
function Base._range(a::Quantity{<:AbstractFloat}, st::Quantity{<:AbstractFloat}, ::Nothing, len::Integer)
    dimension(a) != dimension(st) && throw(DimensionError(a, st))
    Base._range(promote(a, uconvert(unit(a), st))..., nothing, len)
end
Base._range(a::Quantity, st::Real, ::Nothing, len::Integer) =
    Base._range(promote(a, uconvert(unit(a), st))..., nothing, len)
Base._range(a::Real, st::Quantity, ::Nothing, len::Integer) =
    Base._range(promote(a, uconvert(unit(a), st))..., nothing, len)
# the following is needed to give sane error messages when doing e.g. range(1°, 2V, 5)
function Base._range(a::Quantity, step, ::Nothing, len::Integer)
    dimension(a) != dimension(step) && throw(DimensionError(a,step))
    _a, _step = promote(a, uconvert(unit(a), step))
    return Base._rangestyle(OrderStyle(_a), ArithmeticStyle(_a), _a, _step, len)
end
*(r::AbstractRange, y::Units) = range(first(r)*y, step=step(r)*y, length=length(r))

# first promote start and stop, leaving step alone
colon(start::A, step, stop::C) where {A<:Real,C<:Quantity} = colonstartstop(start,step,stop)
colon(start::A, step, stop::C) where {A<:Quantity,C<:Real} = colonstartstop(start,step,stop)
colon(a::T, b::Quantity, c::T) where {T<:Real} = colon(promote(a,b,c)...)
colon(start::Quantity{<:Real}, step, stop::Quantity{<:Real}) =
    colon(promote(start, step, stop)...)

# promotes start and stop
function colonstartstop(start::A, step, stop::C) where {A,C}
    dimension(start) != dimension(stop) && throw(DimensionError(start, stop))
    colon(convert(promote_type(A,C),start), step, convert(promote_type(A,C),stop))
end

function colon(start::A, step::B, stop::A) where A<:Quantity{<:Real} where B<:Quantity{<:Real}
    dimension(start) != dimension(step) && throw(DimensionError(start, step))
    colon(promote(start, step, stop)...)
end

OrderStyle(::Type{<:AbstractQuantity{T}}) where T = OrderStyle(T)
ArithmeticStyle(::Type{<:AbstractQuantity{T}}) where T = ArithmeticStyle(T)

(colon(start::T, step::T, stop::T) where T <: Quantity{<:Real}) =
    _colon(OrderStyle(T), ArithmeticStyle(T), start, step, stop)
_colon(::Ordered, ::Any, start::T, step, stop::T) where {T} = StepRange(start, step, stop)
_colon(::Ordered, ::ArithmeticRounds, start::T, step, stop::T) where {T} =
    StepRangeLen(start, step, floor(Int, (stop-start)/step)+1)
_colon(::Any, ::Any, start::T, step, stop::T) where {T} =
    StepRangeLen(start, step, floor(Int, (stop-start)/step)+1)

# Opt into TwicePrecision functionality
*(x::Base.TwicePrecision, y::Units) = Base.TwicePrecision(x.hi*y, x.lo*y)
*(x::Base.TwicePrecision, y::Quantity) = (x * ustrip(y)) * unit(y)
function colon(start::T, step::T, stop::T) where (T<:Quantity{S}
        where S<:Union{Float16,Float32,Float64})
    # This will always return a StepRangeLen
    return colon(ustrip(start), ustrip(step), ustrip(stop)) * unit(T)
end

# No need to confuse things by changing the type once units are on there,
# if we can help it.
*(r::StepRangeLen, y::Units) =
    StepRangeLen{typeof(zero(eltype(r))*y)}(r.ref*y, r.step*y, length(r), r.offset)
*(r::LinRange, y::Units) = LinRange(r.start*y, r.stop*y, length(r))
*(r::StepRange, y::Units) = StepRange(r.start*y, r.step*y, r.stop*y)
function /(x::Base.TwicePrecision, v::Quantity)
    x / Base.TwicePrecision(oftype(ustrip(x.hi)/ustrip(v)*unit(v), v))
end

# These can be removed (I think) if `range_start_step_length()` returns a `StepRangeLen` for
# non-floats, cf. https://github.com/JuliaLang/julia/issues/40672
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::AbstractRange, x::AbstractQuantity) =
    broadcasted(DefaultArrayStyle{1}(), *, r, ustrip(x)) * unit(x)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::AbstractQuantity, r::AbstractRange) =
    broadcasted(DefaultArrayStyle{1}(), *, ustrip(x), r) * unit(x)
# for ambiguity resolution
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::StepRangeLen{T}, x::AbstractQuantity) where T =
    broadcasted(DefaultArrayStyle{1}(), *, r, ustrip(x)) * unit(x)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::AbstractQuantity, r::StepRangeLen{T}) where T =
    broadcasted(DefaultArrayStyle{1}(), *, ustrip(x), r) * unit(x)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::LinRange, x::AbstractQuantity) =
    LinRange(r.start*x, r.stop*x, r.len)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::AbstractQuantity, r::LinRange) =
    LinRange(x*r.start, x*r.stop, r.len)
