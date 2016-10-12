import Base.FastMath
import Core.Intrinsics: box, unbox, powi_llvm, sqrt_llvm_fast
import Base.FastMath: @fastmath,
    FloatTypes,
    ComplexTypes,
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
    pow_fast,
    sqrt_fast,
    atan2_fast,
    fast_op,
    libm

sub_fast{T<:FloatTypes}(x::Quantity{T}) = typeof(x)(box(T,
    Base.neg_float_fast(unbox(T,x.val))))

add_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Quantity{T,D,U}(box(T,
        Base.add_float_fast(unbox(T,x.val), unbox(T,y.val))))

sub_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Quantity{T,D,U}(box(T,
        Base.sub_float_fast(unbox(T,x.val), unbox(T,y.val))))

function mul_fast{T<:FloatTypes}(x::Quantity{T}, y::Quantity{T})
    D = typeof(dimension(x) * dimension(y))
    U = typeof(unit(x) * unit(y))
    Quantity{T,D,U}(box(T, Base.mul_float_fast(unbox(T,x.val), unbox(T,y.val))))
end
function div_fast{T<:FloatTypes}(x::Quantity{T}, y::Quantity{T})
    D = typeof(dimension(x) / dimension(y))
    U = typeof(unit(x) / unit(y))
    Quantity{T,D,U}(box(T, Base.div_float_fast(unbox(T,x.val), unbox(T,y.val))))
end

rem_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Quantity{T,D,U}(box(T, Base.rem_float_fast(unbox(T,x.val), unbox(T,y.val))))

add_fast{T<:FloatTypes}(x::Quantity{T}, y::Quantity{T}, zs::Quantity{T}...) =
    add_fast(add_fast(x, y), zs...)
mul_fast{T<:FloatTypes}(x::Quantity{T}, y::Quantity{T}, zs::Quantity{T}...) =
    mul_fast(mul_fast(x, y), zs...)

@fastmath begin
    cmp_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        ifelse(x==y, 0, ifelse(x<y, -1, +1))
    function mod_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U})
        r = rem(x,y)
        ifelse((r > zero(Quantity{T,D,U})) $ (y > zero(Quantity{T,D,U})), r+y, r)
    end
end

eq_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Base.eq_float_fast(unbox(T,x.val),unbox(T,y.val))
ne_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Base.ne_float_fast(unbox(T,x.val),unbox(T,y.val))
lt_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Base.lt_float_fast(unbox(T,x.val),unbox(T,y.val))
le_fast{T<:FloatTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
    Base.le_float_fast(unbox(T,x.val),unbox(T,y.val))

@fastmath begin
    abs_fast{T<:ComplexTypes}(x::Quantity{T}) = hypot(real(x), imag(x))
    abs2_fast{T<:ComplexTypes}(x::Quantity{T}) = real(x)*real(x) + imag(x)*imag(x)
    conj_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}) =
        Quantity{T,D,U}(T(real(x.val), -imag(x.val)))
    inv_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}) = conj(x) / abs2(x)
    # sign_fast{T<:ComplexTypes}(x::T) = x == 0 ? float(zero(x)) : x/abs(x) #TODO

    add_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        Quantity{T,D,U}(T(real(x.val)+real(y.val), imag(x.val)+imag(y.val)))
    add_fast{T<:FloatTypes,D,U}(x::Quantity{Complex{T},D,U}, b::Quantity{T,D,U}) =
        Quantity{T,D,U}(Complex{T}(real(x.val)+b.val, imag(x.val)))
    add_fast{T<:FloatTypes,D,U}(a::Quantity{T,D,U}, y::Quantity{Complex{T},D,U}) =
        Quantity{T,D,U}(Complex{T}(a.val+real(y.val), imag(y.val)))

    sub_fast{T<:ComplexTypes,D,U}(x::Quantity{T,D,U}, y::Quantity{T,D,U}) =
        Quantity{T,D,U}(T(real(x.val)-real(y.val), imag(x.val)-imag(y.val)))
    sub_fast{T<:FloatTypes,D,U}(x::Quantity{Complex{T},D,U}, b::Quantity{T,D,U}) =
        Quantity{T,D,U}(Complex{T}(real(x.val)-b.val, imag(x.val)))
    sub_fast{T<:FloatTypes,D,U}(a::Quantity{T,D,U}, y::Quantity{Complex{T},D,U}) =
        Quantity{T,D,U}(Complex{T}(a.val-real(y.val), -imag(y.val)))

    function mul_fast{T<:ComplexTypes}(x::Quantity{T}, y::Quantity{T})
        D = typeof(dimension(x) * dimension(y))
        U = typeof(unit(x) * unit(y))
        Quantity{T,D,U}(T(real(x.val)*real(y.val) - imag(x.val)*imag(y.val),
          real(x.val)*imag(y.val) + imag(x.val)*real(y.val)))
    end
    function mul_fast{T<:FloatTypes}(x::Quantity{Complex{T}}, b::Quantity{T})
        D = typeof(dimension(x) * dimension(y))
        U = typeof(unit(x) * unit(y))
        Quantity{T,D,U}(Complex{T}(real(x.val)*b.val, imag(x.val)*b.val))
    end
    function mul_fast{T<:FloatTypes}(a::Quantity{T}, y::Quantity{Complex{T}})
        D = typeof(dimension(x) * dimension(y))
        U = typeof(unit(x) * unit(y))
        Quantity{T,D,U}(Complex{T}(a.val*real(y.val), a.val*imag(y.val)))
    end

    @inline function div_fast{T<:ComplexTypes}(x::Quantity{T}, y::Quantity{T})
        D = typeof(dimension(x) / dimension(y))
        U = typeof(unit(x) / unit(y))
        Quantity{T,D,U}(T(real(x.val)*real(y.val) + imag(x.val)*imag(y.val),
          imag(x.val)*real(y.val) - real(x.val)*imag(y.val))) / abs2(y)
    end
    function div_fast{T<:FloatTypes}(x::Quantity{Complex{T}}, b::Quantity{T})
        D = typeof(dimension(x) / dimension(y))
        U = typeof(unit(x) / unit(y))
        Quantity{T,D,U}(Complex{T}(real(x.val)/b.val, imag(x.val)/b.val))
    end
    function div_fast{T<:FloatTypes}(a::Quantity{T}, y::Quantity{Complex{T}})
        D = typeof(dimension(x) / dimension(y))
        U = typeof(unit(x) / unit(y))
        Quantity{T,D,U}(Complex{T}(a.val*real(y.val), -a.val*imag(y.val))) / abs2(y)
    end

    eq_fast{T<:ComplexTypes}(x::Quantity{T}, y::Quantity{T}) =
        (real(x)==real(y)) & (imag(x)==imag(y))
    # eq_fast{T<:FloatTypes}(x::Complex{T}, b::T) = #TODO
    #     (real(x)==b) & (imag(x)==T(0))
    # eq_fast{T<:FloatTypes}(a::T, y::Complex{T}) =
    #     (a==real(y)) & (T(0)==imag(y))

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
pow_fast{T<:FloatTypes}(x::Quantity{T}, y::Integer) = x^y

sqrt_fast{T<:FloatTypes}(x::Quantity{T}) =
    Quantity(box(T, Base.sqrt_llvm_fast(unbox(T,x.val))), sqrt(unit(x)))


atan2_fast(x::Quantity{Float32,D,U}, y::Quantity{Float32,D,U}) =
    Quantity{Float32,D,U}(
        ccall(("atan2f",libm), Float32, (Float32,Float32), x.val, y.val))
atan2_fast(x::Quantity{Float64,D,U}, y::Quantity{Float64,D,U}) =
    Quantity{Float64,D,U}(
        ccall(("atan2",libm), Float64, (Float64,Float64), x.val, y.val))
