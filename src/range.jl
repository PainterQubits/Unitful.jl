const colon = Base.:(:)

import Base: ArithmeticRounds
import Base: OrderStyle, Ordered, ArithmeticStyle, ArithmeticWraps
import Base.Broadcast: DefaultArrayStyle, broadcasted

*(y::Units, r::AbstractRange) = *(r,y)
*(r::AbstractRange, y::Units, z::Units...) = *(r, *(y,z...))

Base._range(start::Quantity, ::Nothing, stop, len::Integer) =
    _range(promote(start, stop)..., len)
Base._range(start, ::Nothing, stop::Quantity, len::Integer) =
    _range(promote(start, stop)..., len)
Base._range(start::Quantity, ::Nothing, stop::Quantity, len::Integer) =
    _range(promote(start, stop)..., len)
Base._range(start::T, ::Nothing, stop::T, len::Integer) where {T<:Quantity} =
    LinRange{T}(start, stop, len)
Base._range(start::T, ::Nothing, stop::T, len::Integer) where {T<:Quantity{<:Integer}} =
    Base._linspace(Float64, ustrip(start), ustrip(stop), len, 1)*unit(T)
Base._range(start::T, ::Nothing, stop::T, len::Integer) where {S<:Base.IEEEFloat, T<:Quantity{S}} =
    range(ustrip(start), stop=ustrip(stop), length=len) * unit(T)
function _range(start::Quantity{T}, stop::Quantity{T}, len::Integer) where {T}
    dimension(start) != dimension(stop) && throw(DimensionError(start, stop))
    Base._range(start, nothing, stop, len)
end
Base._range(a::T, st::T, ::Nothing, len::Integer) where {T<:Quantity{<:Base.IEEEFloat}} =
    Base._range(ustrip(a), ustrip(st), nothing, len) * unit(T)
Base._range(a::T, st::T, ::Nothing, len::Integer) where {T<:Quantity{<:AbstractFloat}} =
    StepRangeLen{typeof(st*len),typeof(a),typeof(st)}(a, st, len)
@static if VERSION ≥ v"1.8.0-DEV"
    function Base._range(a::T, st::T, ::Nothing, len::Integer) where {T<:Quantity}
        stop = a + st * (len - oneunit(len))
        if ustrip(stop) isa Signed
            StepRange{typeof(stop), typeof(st)}(a, st, stop)
        else
            StepRangeLen{typeof(stop), typeof(a), typeof(st)}(a, st, len)
        end
    end
else
    Base._range(a::T, st::T, ::Nothing, len::Integer) where {T<:Quantity} =
        Base._rangestyle(OrderStyle(a), ArithmeticStyle(a), a, st, len)
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
    Base._range(promote(a, uconvert(unit(a), step))..., nothing, len)
end
Base._range(a::Quantity, ::Nothing, ::Nothing, len::Integer) =
    Base._range(a, real(one(a)), nothing, len)
@static if VERSION ≥ v"1.7"
    Base._range(::Nothing, ::Nothing, stop::Quantity, len::Integer) =
        Base._range(nothing, real(one(stop)), stop, len)
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
uconvert(y, x::Base.TwicePrecision) = Base.TwicePrecision(uconvert(y, x.hi), uconvert(y, x.lo))

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

const BCAST_PROPAGATE_CALLS = Union{typeof(upreferred), typeof(ustrip), Units}
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::AbstractRange, x::Ref{<:Units}) = r * x[]
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Ref{<:Units}, r::AbstractRange) = x[] * r
broadcasted(::DefaultArrayStyle{1}, x::BCAST_PROPAGATE_CALLS, r::StepRangeLen) = StepRangeLen{typeof(x(zero(eltype(r))))}(x(r.ref), x(r.step), r.len, r.offset)
broadcasted(::DefaultArrayStyle{1}, x::BCAST_PROPAGATE_CALLS, r::StepRange) = StepRange(x(r.start), x(r.step), x(r.stop))
broadcasted(::DefaultArrayStyle{1}, x::BCAST_PROPAGATE_CALLS, r::LinRange) = LinRange(x(r.start), x(r.stop), r.len)
broadcasted(::DefaultArrayStyle{1}, ::typeof(|>), r::AbstractRange, x::Ref{<:BCAST_PROPAGATE_CALLS}) = broadcasted(DefaultArrayStyle{1}(), x[], r)

# for ambiguity resolution
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::StepRangeLen{T}, x::AbstractQuantity) where T =
    broadcasted(DefaultArrayStyle{1}(), *, r, ustrip(x)) * unit(x)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::AbstractQuantity, r::StepRangeLen{T}) where T =
    broadcasted(DefaultArrayStyle{1}(), *, ustrip(x), r) * unit(x)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::LinRange, x::AbstractQuantity) =
    LinRange(r.start*x, r.stop*x, r.len)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::AbstractQuantity, r::LinRange) =
    LinRange(x*r.start, x*r.stop, r.len)
