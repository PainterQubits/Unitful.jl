
"""
    Quantity(x::Number, y::Units)
Outer constructor for `Quantity`s. This is a generated function to avoid
determining the dimensions of a given set of units each time a new quantity is
made.
"""
@generated function _Quantity(x::Number, y::Units)
    u = y()
    du = dimension(u)
    dx = dimension(x)
    d = du*dx
    :(Quantity{typeof(x), typeof($d), typeof($u)}(x))
end
Quantity(x::Number, y::Units) = _Quantity(x, y)
Quantity(x::Number, y::Units{()}) = x

*(x::Number, y::Units, z::Units...) = Quantity(x,*(y,z...))
*(x::Units, y::Number) = *(y,x)

*(x::Quantity, y::Units, z::Units...) = Quantity(x.val, *(unit(x),y,z...))
*(x::Quantity, y::Quantity) = Quantity(x.val*y.val, unit(x)*unit(y))

# Next two lines resolves some method ambiguity:
*(x::Bool, y::T) where {T <: Quantity} =
    ifelse(x, y, ifelse(signbit(y), -zero(y), zero(y)))
*(x::Quantity, y::Bool) = Quantity(x.val*y, unit(x))

*(y::Number, x::Quantity) = *(x,y)
function *(x::Quantity, y::Number)
    x isa AffineQuantity &&
        throw(AffineError("an invalid operation was attempted with affine quantities: $x*$y"))
    return Quantity(x.val*y, unit(x))
end

*(A::Units, B::AbstractArray) = broadcast(*, A, B)
*(A::AbstractArray, B::Units) = broadcast(*, A, B)

# Division (units)
/(x::Quantity, y::Units) = Quantity(x.val, unit(x) / y)
/(x::Units, y::Quantity) = Quantity(1/y.val, x / unit(y))
/(x::Number, y::Units) = Quantity(x,inv(y))
/(x::Units, y::Number) = (1/y) * x

//(x::Quantity, y::Units) = Quantity(x.val, unit(x) / y)
//(x::Units, y::Quantity) = Quantity(1//y.val, x / unit(y))
//(x::Number, y::Units) = Rational(x)/y
//(x::Units, y::Number) = (1//y) * x

/(x::Quantity, y::Quantity) = Quantity(/(x.val, y.val), unit(x) / unit(y))
/(x::Quantity, y::Number) = Quantity(/(x.val, y), unit(x) / unit(y))
/(x::Number, y::Quantity) = Quantity(/(x, y.val), unit(x) / unit(y))
//(x::Quantity, y::Quantity) = Quantity(//(x.val, y.val), unit(x) / unit(y))
//(x::Quantity, y::Number) = Quantity(//(x.val, y), unit(x) // unit(y))
//(x::Number, y::Quantity) = Quantity(//(x, y.val), unit(x) / unit(y))

# ambiguity resolution
//(x::Quantity, y::Complex) = Quantity(//(x.val, y), unit(x))

for f in (:div, :fld, :cld)
    @eval function ($f)(x::Quantity, y::Quantity)
        z = uconvert(unit(y), x)        # TODO: use promote?
        ($f)(z.val,y.val)
    end
end

for f in (:mod, :rem)
    @eval function ($f)(x::Quantity, y::Quantity)
        z = uconvert(unit(y), x)        # TODO: use promote?
        Quantity(($f)(z.val,y.val), unit(y))
    end
end

Base.mod2pi(x::DimensionlessQuantity) = mod2pi(uconvert(NoUnits, x))
Base.mod2pi(x::Quantity{S, Dimensions{()}, <:Units{
    (Unitful.Unit{:Degree,Unitful.Dimensions{()}}(0, 1//1),),
    Unitful.Dimensions{()}}}) where S = mod(x, 360°)

# Addition / subtraction
for op in [:+, :-]
    @eval ($op)(x::Quantity{S,D,U}, y::Quantity{T,D,U}) where {S,T,D,U} =
        Quantity(($op)(x.val, y.val), U())

    @eval function ($op)(x::Quantity{S,D,SU}, y::Quantity{T,D,TU}) where {S,T,D,SU,TU}
        ($op)(promote(x,y)...)
    end

    @eval ($op)(x::Quantity, y::Quantity) = throw(DimensionError(x,y))
    @eval ($op)(x::Quantity) = Quantity(($op)(x.val), unit(x))
end

function +(x::AffineQuantity{S,D}, y::Quantity{T,D}) where {S,T,D}
    pu = promote_unit(unit(x), unit(y))
    x′ = x - 0*absoluteunit(unit(x)) # absolute zero
    return uconvert(pu, x′+y)
end
+(x::Quantity, y::AffineQuantity) = +(y,x)

# Disallow addition of affine quantities
+(x::AffineQuantity, y::AffineQuantity) = throw(AffineError(
   "an invalid operation was attempted with affine quantities: $x + $y"))

# Specialize substraction of affine quantities
function -(x::AffineQuantity, y::AffineQuantity)
    x′, y′ = promote(x,y)
    return Quantity(x′.val - y′.val, absoluteunit(unit(x′)))
end

# Disallow subtracting an affine quantity from a quantity
-(x::Quantity, y::AffineQuantity) =
    throw(AffineError("an invalid operation was attempted with affine quantities: $x - $y"))

# Needed until LU factorization is made to work with unitful numbers
function inv(x::StridedMatrix{T}) where {T <: Quantity}
    m = inv(ustrip(x))
    iq = eltype(m)
    reinterpret(Quantity{iq, typeof(inv(dimension(T))), typeof(inv(unit(T)))}, m)
end

for x in (:istriu, :istril)
    @eval ($x)(A::AbstractMatrix{T}) where {T <: Quantity} = ($x)(ustrip(A))
end

# Other mathematical functions

# `fma` and `muladd`
# The idea here is that if the numeric backing types are not the same, they
# will be promoted to be the same by the generic `fma(::Number, ::Number, ::Number)`
# method. We then catch the possible results and handle the units logic with one
# performant method.

for (_x,_y) in [(:fma, :_fma), (:muladd, :_muladd)]
    # Catch some signatures pre-promotion
    @eval @inline ($_x)(x::Number, y::Quantity, z::Quantity) = ($_y)(x,y,z)
    @eval @inline ($_x)(x::Quantity, y::Number, z::Quantity) = ($_y)(x,y,z)

    # Post-promotion
    @eval @inline ($_x)(x::Quantity{A}, y::Quantity{B}, z::Quantity{C}) where {
        A <: Number, B <: Number, C <: Number} = ($_y)(x,y,z)

    # It seems like most of this is optimized out by the compiler, including the
    # apparent runtime check of dimensions, which does not appear in @code_llvm.
    @eval @inline function ($_y)(x,y,z)
        dimension(x) * dimension(y) != dimension(z) && throw(DimensionError(x*y,z))
        uI = unit(x)*unit(y)
        uF = promote_unit(uI, unit(z))
        c = ($_x)(ustrip(x), ustrip(y), ustrip(uconvert(uI, z)))
        uconvert(uF, Quantity(c, uI))
    end
end

sqrt(x::Quantity) = Quantity(sqrt(x.val), sqrt(unit(x)))
cbrt(x::Quantity) = Quantity(cbrt(x.val), cbrt(unit(x)))

for _y in (:sin, :cos, :tan, :cot, :sec, :csc, :cis)
    @eval ($_y)(x::DimensionlessQuantity) = ($_y)(uconvert(NoUnits, x))
end

atan(y::Quantity, x::Quantity) = atan(promote(y,x)...)
atan(y::Quantity{T,D,U}, x::Quantity{T,D,U}) where {T,D,U} = atan(y.val,x.val)
atan(y::Quantity{T,D1,U1}, x::Quantity{T,D2,U2}) where {T,D1,U1,D2,U2} =
    throw(DimensionError(x,y))

for (f, F) in [(:min, :<), (:max, :>)]
    @eval @generated function ($f)(x::Quantity, y::Quantity)    #TODO
        xdim = x.parameters[2]()
        ydim = y.parameters[2]()
        if xdim != ydim
            return :(throw(DimensionError(x,y)))
        end

        isa(x.parameters[3](), FixedUnits) &&
            isa(y.parameters[3](), FixedUnits) &&
            x.parameters[3] !== y.parameters[3] &&
            error("automatic conversion prohibited.")

        xunits = x.parameters[3].parameters[1]
        yunits = y.parameters[3].parameters[1]

        factx = mapreduce((x,y)->broadcast(*,x,y), xunits) do x
            vcat(basefactor(x)...)
        end
        facty = mapreduce((x,y)->broadcast(*,x,y), yunits) do x
            vcat(basefactor(x)...)
        end

        tensx = mapreduce(tensfactor, +, xunits)
        tensy = mapreduce(tensfactor, +, yunits)

        convx = *(factx..., (10.0)^tensx)
        convy = *(facty..., (10.0)^tensy)

        :($($F)(x.val*$convx, y.val*$convy) ? x : y)
    end
end

abs(x::Quantity) = Quantity(abs(x.val), unit(x))
abs2(x::Quantity) = Quantity(abs2(x.val), unit(x)*unit(x))
angle(x::Quantity{<:Complex}) = angle(x.val)

copysign(x::Quantity, y::Number) = Quantity(copysign(x.val,y/unit(y)), unit(x))
flipsign(x::Quantity, y::Number) = Quantity(flipsign(x.val,y/unit(y)), unit(x))

for (i,j) in zip((:<, :isless), (:_lt, :_isless))
    @eval ($i)(x::Quantity, y::Quantity) = ($j)(x,y)
    @eval ($i)(x::Quantity, y::Number) = ($i)(promote(x,y)...)
    @eval ($i)(x::Number, y::Quantity) = ($i)(promote(x,y)...)

    # promotion might not yield Quantity types
    @eval @inline ($j)(x::Quantity{T1}, y::Quantity{T2}) where {T1,T2} = ($i)(promote(x,y)...)
    # If it does yield Quantity types, we'll get back here,
    # since at least the numeric part can be promoted.
    @eval @inline ($j)(x::Quantity{T,D,U}, y::Quantity{T,D,U}) where {T,D,U} = ($i)(x.val,y.val)
    @eval @inline ($j)(x::Quantity{T,D,U1}, y::Quantity{T,D,U2}) where {T,D,U1,U2} = ($i)(promote(x,y)...)
    @eval @inline ($j)(x::Quantity{T,D1,U1}, y::Quantity{T,D2,U2}) where {T,D1,D2,U1,U2} = throw(DimensionError(x,y))
end

Base.rtoldefault(::Type{Quantity{T,D,U}}) where {T,D,U} = Base.rtoldefault(T)
isapprox(x::Quantity{T,D,U}, y::Quantity{T,D,U}; atol=zero(Quantity{real(T),D,U}), kwargs...) where {T,D,U} =
    isapprox(x.val, y.val; atol=uconvert(unit(y), atol).val, kwargs...)
function isapprox(x::Quantity, y::Quantity; kwargs...)
    dimension(x) != dimension(y) && return false
    return isapprox(promote(x,y)...; kwargs...)
end
isapprox(x::Quantity, y::Number; kwargs...) = isapprox(promote(x,y)...; kwargs...)
isapprox(x::Number, y::Quantity; kwargs...) = isapprox(y, x; kwargs...)

function isapprox(x::AbstractArray{Quantity{T1,D,U1}},
        y::AbstractArray{Quantity{T2,D,U2}}; rtol::Real=Base.rtoldefault(T1,T2,0),
        atol=zero(Quantity{T1,D,U1}), norm::Function=norm) where {T1,D,U1,T2,U2}

    d = norm(x - y)
    if isfinite(d)
        return d <= atol + rtol*max(norm(x), norm(y))
    else
        # Fall back to a component-wise approximate comparison
        return all(ab -> isapprox(ab[1], ab[2]; rtol=rtol, atol=atol), zip(x, y))
    end
end
isapprox(x::AbstractArray{S}, y::AbstractArray{T};
    kwargs...) where {S <: Quantity,T <: Quantity} = false
function isapprox(x::AbstractArray{S}, y::AbstractArray{N};
    kwargs...) where {S <: Quantity,N <: Number}
    if dimension(N) == dimension(S)
        isapprox(map(x->uconvert(NoUnits,x),x),y; kwargs...)
    else
        false
    end
end
isapprox(y::AbstractArray{N}, x::AbstractArray{S};
    kwargs...) where {S <: Quantity,N <: Number} = isapprox(x,y; kwargs...)

for cmp in [:(==), :isequal]
    @eval $cmp(x::Quantity{S,D,U}, y::Quantity{T,D,U}) where {S,T,D,U} = $cmp(x.val, y.val)
    @eval function $cmp(x::Quantity, y::Quantity)
        dimension(x) != dimension(y) && return false
        $cmp(promote(x,y)...)
    end

    @eval function $cmp(x::Quantity, y::Number)
        $cmp(promote(x,y)...)
    end
    @eval $cmp(x::Number, y::Quantity) = $cmp(y,x)
end
<=(x::Quantity, y::Quantity) = <(x,y) || x==y

_dimerr(f) = error("$f can only be well-defined for dimensionless ",
        "numbers. For dimensionful numbers, different input units yield physically ",
        "different results.")
isinteger(x::Quantity) = _dimerr(isinteger)
isinteger(x::DimensionlessQuantity) = isinteger(uconvert(NoUnits, x))
for f in (:floor, :ceil, :trunc, :round)
    @eval ($f)(x::Quantity) = _dimerr($f)
    @eval ($f)(x::DimensionlessQuantity) = ($f)(uconvert(NoUnits, x))
    @eval ($f)(::Type{T}, x::Quantity) where {T <: Integer} = _dimerr($f)
    @eval ($f)(::Type{T}, x::DimensionlessQuantity) where {T <: Integer} = ($f)(T, uconvert(NoUnits, x))
end

zero(x::Quantity) = Quantity(zero(x.val), unit(x))
zero(x::Type{Quantity{T,D,U}}) where {T,D,U} = zero(T)*U()

one(x::Quantity) = one(x.val)
get_T(::Type{Quantity{T}}) where T = T
get_T(::Type{Quantity{T,D}}) where {T,D} = T
get_T(::Type{Quantity{T,D,U}}) where {T,D,U} = T
one(x::Type{<:Quantity}) = one(get_T(x))

isreal(x::Quantity) = isreal(x.val)
isfinite(x::Quantity) = isfinite(x.val)
isinf(x::Quantity) = isinf(x.val)
isnan(x::Quantity) = isnan(x.val)

eps(x::T) where {T<:Quantity} = T(eps(x.val))
eps(x::Type{T}) where {T<:Quantity} = eps(Unitful.numtype(T))

unsigned(x::Quantity) = Quantity(unsigned(x.val), unit(x))

for f in (:exp, :exp10, :exp2, :expm1, :log, :log10, :log1p, :log2)
    @eval ($f)(x::DimensionlessQuantity) = ($f)(uconvert(NoUnits, x))
end

real(x::Quantity) = Quantity(real(x.val), unit(x))
imag(x::Quantity) = Quantity(imag(x.val), unit(x))
conj(x::Quantity) = Quantity(conj(x.val), unit(x))

@inline norm(x::Quantity, p::Real=2) =
    p == 0 ? (x==zero(x) ? typeof(abs(x))(0) : typeof(abs(x))(1)) : abs(x)

"""
    sign(x::Quantity)
Returns the sign of `x`.
"""
sign(x::Quantity) = sign(x.val)

"""
    signbit(x::Quantity)
Returns the sign bit of the underlying numeric value of `x`.
"""
signbit(x::Quantity) = signbit(x.val)

prevfloat(x::Quantity{T}) where {T <: AbstractFloat} = Quantity(prevfloat(x.val), unit(x))
nextfloat(x::Quantity{T}) where {T <: AbstractFloat} = Quantity(nextfloat(x.val), unit(x))

function frexp(x::Quantity{T}) where {T <: AbstractFloat}
    a,b = frexp(x.val)
    a*unit(x), b
end

"""
    float(x::Quantity)
Convert the numeric backing type of `x` to a floating-point representation.
Returns a `Quantity` with the same units.
"""
float(x::Quantity) = Quantity(float(x.val), unit(x))

"""
    Integer(x::Quantity)
Convert the numeric backing type of `x` to an integer representation.
Returns a `Quantity` with the same units.
"""
Integer(x::Quantity) = Quantity(Integer(x.val), unit(x))

"""
    Rational(x::Quantity)
Convert the numeric backing type of `x` to a rational number representation.
Returns a `Quantity` with the same units.
"""
Rational(x::Quantity) = Quantity(Rational(x.val), unit(x))

typemin(::Type{Quantity{T,D,U}}) where {T,D,U} = typemin(T)*U()
typemin(x::Quantity{T}) where {T} = typemin(T)*unit(x)

typemax(::Type{Quantity{T,D,U}}) where {T,D,U} = typemax(T)*U()
typemax(x::Quantity{T}) where {T} = typemax(T)*unit(x)

Base.literal_pow(::typeof(^), x::Quantity, ::Val{v}) where {v} =
    Quantity(Base.literal_pow(^, x.val, Val(v)),
             Base.literal_pow(^, unit(x), Val(v)))

# All of these are needed for ambiguity resolution
^(x::Quantity, y::Integer) = Quantity((x.val)^y, unit(x)^y)
^(x::Quantity, y::Rational) = Quantity((x.val)^y, unit(x)^y)
^(x::Quantity, y::Real) = Quantity((x.val)^y, unit(x)^y)

Base.rand(r::Random.AbstractRNG, ::Random.SamplerType{Quantity{T,D,U}}) where {T,D,U} =
    rand(r, T) * U()
Base.ones(Q::Type{<:Quantity}, dims::NTuple{N,Integer}) where {N} =
    fill!(Array{Q,N}(undef, map(Base.to_dim, dims)), oneunit(Q))
Base.ones(Q::Type{<:Quantity}, dims::Tuple{}) = fill!(Array{Q}(undef), oneunit(Q))
Base.ones(a::AbstractArray, Q::Type{<:Quantity}) = fill!(similar(a,Q), oneunit(Q))
