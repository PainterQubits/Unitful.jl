import Base.FastMath
import Core.Intrinsics
import FastMath: @fastmath,
    add_fast,
    sub_fast,
    mul_fast,
    div_fast,
    rem_fast,
    cmp_fast,
    mod_fast,
    eq_fast,
    ne_fast,
    lt_fast,
    le_fast,
    fast_op

FloatTypes = Union{Quantity{Float32}, Quantity{Float64}}

add_fast{T<:FloatTypes}(x::T, y::T) =
    box(T,Base.add_float_fast(unbox(T,x), unbox(T,y)))
sub_fast{T<:FloatTypes}(x::T, y::T) =
    box(T,Base.sub_float_fast(unbox(T,x), unbox(T,y)))
@generated function mul_fast{T<:FloatTypes}(x::T, y::T)
    S = typeof(T(1)*T(1))
    :(box($S,Base.mul_float_fast(unbox(T,x), unbox(T,y))))
end
@generated function div_fast{T<:FloatTypes}(x::T, y::T)
    S = typeof(div(T(1),T(1)))
    :(box(S,Base.div_float_fast(unbox(T,x), unbox(T,y))))
rem_fast{T<:FloatTypes}(x::T, y::T) =
    box(T,Base.rem_float_fast(unbox(T,x), unbox(T,y)))

add_fast{T<:FloatTypes}(x::T, y::T, zs::T...) =
    add_fast(add_fast(x, y), zs...)
mul_fast{T<:FloatTypes}(x::T, y::T, zs::T...) =
    mul_fast(mul_fast(x, y), zs...)

@fastmath begin
    cmp_fast{T<:FloatTypes}(x::T, y::T) = ifelse(x==y, 0, ifelse(x<y, -1, +1))
    function mod_fast{T<:FloatTypes}(x::T, y::T)
        r = rem(x,y)
        ifelse((r > zero(T)) $ (y > zero(T)), r+y, r)
    end
end

eq_fast{T<:FloatTypes}(x::T, y::T) =
    Base.eq_float_fast(unbox(T,x),unbox(T,y))
ne_fast{T<:FloatTypes}(x::T, y::T) =
    Base.ne_float_fast(unbox(T,x),unbox(T,y))
lt_fast{T<:FloatTypes}(x::T, y::T) =
    Base.lt_float_fast(unbox(T,x),unbox(T,y))
le_fast{T<:FloatTypes}(x::T, y::T) =
    Base.le_float_fast(unbox(T,x),unbox(T,y))
