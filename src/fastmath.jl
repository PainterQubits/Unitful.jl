import Base.FastMath
import Core.Intrinsics:
    sqrt_llvm_fast,
    neg_float_fast,
    add_float_fast,
    sub_float_fast,
    mul_float_fast,
    div_float_fast,
    rem_float_fast,
    eq_float_fast,
    ne_float_fast,
    lt_float_fast,
    le_float_fast

import Base.FastMath: @fastmath,
    FloatTypes,
    ComplexTypes,
    add_fast,
    sub_fast,
    mul_fast,
    div_fast,
    rem_fast,
    cmp_fast,
    # mod_fast,
    eq_fast,
    ne_fast,
    lt_fast,
    le_fast,
    pow_fast,
    sqrt_fast,
    atan2_fast,
    hypot_fast,
    max_fast,
    min_fast,
    minmax_fast,
    cis_fast,
    angle_fast,
    fast_op,
    libm

sub_fast{T<:FloatTypes}(x::Quantity{T}) = typeof(x)(neg_float_fast(x.val))

add_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Quantity{T,D,U}(add_float_fast(x.val, y.val))

sub_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Quantity{T,D,U}(sub_float_fast(x.val, y.val))

function mul_fast{T<:FloatTypes}(x::Quantity{T}, y::Quantity{T})
    D = typeof(dimension(x) * dimension(y))
    U = typeof(unit(x) * unit(y))
    Quantity{T,D,U}(mul_float_fast(x.val, y.val))
end
function div_fast{T<:FloatTypes}(x::Quantity{T}, y::Quantity{T})
    D = typeof(dimension(x) / dimension(y))
    U = typeof(unit(x) / unit(y))
    Quantity{T,D,U}(div_float_fast(x.val, y.val))
end

rem_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Quantity{T,D,U}(rem_float_fast(x.val, y.val))

add_fast{T<:FloatTypes}(x::Quantity{T}, y::Quantity{T}, z::Quantity{T}, t::Quantity{T}...) =
    add_fast(add_fast(add_fast(x, y), z), t...)
mul_fast{T<:FloatTypes}(x::Quantity{T}, y::Quantity{T}, z::Quantity{T}, t::Quantity{T}...) =
    mul_fast(mul_fast(mul_fast(x, y), z), t...)

@fastmath begin
    cmp_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        ifelse(x==y, 0, ifelse(x<y, -1, +1))
    # function mod_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U})
    #     r = rem(x,y)
    #     @compat ifelse(xor((r > zero(Quantity{T,D,U})), (y > zero(Quantity{T,D,U}))), r+y, r)
    # end
end

eq_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    eq_float_fast(x.val,y.val)
ne_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    ne_float_fast(x.val,y.val)
lt_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    lt_float_fast(x.val,y.val)
le_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    le_float_fast(x.val,y.val)

@fastmath begin
    abs_fast{T<:ComplexTypes}(x::Quantity{T}) = hypot(real(x), imag(x))
    abs2_fast{T<:ComplexTypes}(x::Quantity{T}) = real(x)*real(x) + imag(x)*imag(x)
    conj_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}) =
        Quantity{T,D,U}(T(real(x.val), -imag(x.val)))
    inv_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}) = conj(x) / abs2(x)
    sign_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}) =
        x == Quantity(0, U()) ? float(zero(x)) : x/abs(x)

    add_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        Quantity{T,D,U}(T(real(x.val)+real(y.val), imag(x.val)+imag(y.val)))
    add_fast{T<:FloatTypes,D,U}(x::Quantity{Complex{T},D,U}, b::Quantity{T,D,U}) =
        Quantity{Complex{T},D,U}(Complex{T}(real(x.val)+b.val, imag(x.val)))
    add_fast{T<:FloatTypes,D,U}(a::Quantity{T,D,U}, y::Quantity{Complex{T},D,U}) =
        Quantity{Complex{T},D,U}(Complex{T}(a.val+real(y.val), imag(y.val)))

    sub_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        Quantity{T,D,U}(T(real(x.val)-real(y.val), imag(x.val)-imag(y.val)))
    sub_fast{T<:FloatTypes,D,U}(x::Quantity{Complex{T},D,U}, b::Quantity{T,D,U}) =
        Quantity{Complex{T},D,U}(Complex{T}(real(x.val)-b.val, imag(x.val)))
    sub_fast{T<:FloatTypes,D,U}(a::Quantity{T,D,U}, y::Quantity{Complex{T},D,U}) =
        Quantity{Complex{T},D,U}(Complex{T}(a.val-real(y.val), -imag(y.val)))

    function mul_fast{T<:ComplexTypes}(x::Quantity{T}, y::Quantity{T})
        D = typeof(dimension(x) * dimension(y))
        U = typeof(unit(x) * unit(y))
        Quantity{T,D,U}(T(real(x.val)*real(y.val) - imag(x.val)*imag(y.val),
          real(x.val)*imag(y.val) + imag(x.val)*real(y.val)))
    end
    function mul_fast{T<:FloatTypes}(x::Quantity{Complex{T}}, b::Quantity{T})
        D = typeof(dimension(x) * dimension(b))
        U = typeof(unit(x) * unit(b))
        Quantity{Complex{T},D,U}(Complex{T}(real(x.val)*b.val, imag(x.val)*b.val))
    end
    function mul_fast{T<:FloatTypes}(a::Quantity{T}, y::Quantity{Complex{T}})
        D = typeof(dimension(a) * dimension(y))
        U = typeof(unit(a) * unit(y))
        Quantity{Complex{T},D,U}(Complex{T}(a.val*real(y.val), a.val*imag(y.val)))
    end

    @inline function div_fast{T<:ComplexTypes}(x::Quantity{T}, y::Quantity{T})
        D = typeof(dimension(x) * dimension(y))
        U = typeof(unit(x) * unit(y))
        Quantity{T,D,U}(T(real(x.val)*real(y.val) + imag(x.val)*imag(y.val),
          imag(x.val)*real(y.val) - real(x.val)*imag(y.val))) / abs2(y)
    end
    function div_fast{T<:FloatTypes}(x::Quantity{Complex{T}}, b::Quantity{T})
        D = typeof(dimension(x) / dimension(b))
        U = typeof(unit(x) / unit(b))
        Quantity{Complex{T},D,U}(Complex{T}(real(x.val)/b.val, imag(x.val)/b.val))
    end
    function div_fast{T<:FloatTypes}(a::Quantity{T}, y::Quantity{Complex{T}})
        D = typeof(dimension(a) * dimension(y))
        U = typeof(unit(a) * unit(y))
        Quantity{Complex{T},D,U}(Complex{T}(a.val*real(y.val),
            -a.val*imag(y.val))) / abs2(y)
    end

    eq_fast{T<:ComplexTypes}(x::Quantity{T}, y::Quantity{T}) =
        (real(x)==real(y)) & (imag(x)==imag(y))
    eq_fast{T<:FloatTypes}(x::Quantity{Complex{T}}, b::Quantity{T}) =
        (real(x)==b) & (imag(x)==zero(b))
    eq_fast{T<:FloatTypes}(a::Quantity{T}, y::Quantity{Complex{T}}) =
        (a==real(y)) & (zero(a)==imag(y))

    ne_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) = !(x==y)
end

for op in (:+, :-, :*, :/, :(==), :!=, :<, :<=, :cmp, :mod, :rem)
    op_fast = fast_op[op]
    @eval begin
        # Fallback method for Quantitys after promotion.
        $op_fast{T<:Number}(x::Quantity{T},ys::Quantity{T}...) = $op(x,ys...)
    end
end

# exponentiation is not and cannot be type-stable for `Quantity`s,
# so we will not fastmathify it
pow_fast(x::Quantity, y::Integer) = x^y
pow_fast(x::Quantity, y::Rational) = x^y

sqrt_fast{T<:FloatTypes}(x::Quantity{T}) =
    Quantity(sqrt_llvm_fast(x.val), sqrt(unit(x)))

for f in (:cos, :sin, :tan)
    f_fast = fast_op[f]
    @eval begin
        $f_fast{U}(x::DimensionlessQuantity{Float32,U}) =
            ccall(($(string(f,"f")),libm), Float32, (Float32,), uconvert(x,NoUnits))
        $f_fast{U}(x::DimensionlessQuantity{Float64,U}) =
            ccall(($(string(f)),libm), Float64, (Float64,), uconvert(x,NoUnits))
    end
end

atan2_fast{D,U}(x::Quantity{Float32,D,U}, y::Quantity{Float32,D,U}) =
    ccall(("atan2f",libm), Float32, (Float32,Float32), x.val, y.val)
atan2_fast{D,U}(x::Quantity{Float64,D,U}, y::Quantity{Float64,D,U}) =
    ccall(("atan2",libm), Float64, (Float64,Float64), x.val, y.val)

@fastmath begin
    hypot_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        sqrt(x*x + y*y)

    # Note: we use the same comparison for min, max, and minmax, so
    # that the compiler can convert between them
    max_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        ifelse(y > x, y, x)
    min_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        ifelse(y > x, x, y)
    minmax_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        ifelse(y > x, (x,y), (y,x))

    # complex numbers

    cis_fast{T<:FloatTypes,U}(x::DimensionlessQuantity{T,U}) =
        Complex{T}(cos(x), sin(x))

    angle_fast{T<:ComplexTypes}(x::Quantity{T}) = atan2(imag(x), real(x))
end
