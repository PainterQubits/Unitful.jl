
"""
    Quantity(x::Number, y::Units)
Outer constructor for `Quantity`s. This is a generated function to avoid
determining the dimensions of a given set of units each time a new quantity is
made.
"""
@generated function Quantity(x::Number, y::Units)
    u = y()
    du = dimension(u)
    dx = dimension(x)
    d = du*dx
    :(Quantity{typeof(x), typeof($d), typeof($u)}(x))
end
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
*(x::Quantity, y::Number) = Quantity(x.val*y, unit(x))

# looked in arraymath.jl for similar code
function *(A::Units, B::AbstractArray{T}) where {T}
    F = similar(B, Base.promote_op(*, typeof(A), T))
    for (iF, iB) in zip(eachindex(F), eachindex(B))
        @inbounds F[iF] = *(A, B[iB])
    end
    return F
end

function *(A::AbstractArray{T}, B::Units) where {T}
    F = similar(A, Base.promote_op(*, T, typeof(B)))
    for (iF, iA) in zip(eachindex(F), eachindex(A))
        @inbounds F[iF] = *(A[iA], B)
    end
    return F
end

# Division (units)
/(x::Quantity, y::Units) = Quantity(x.val, unit(x) / y)
/(x::Units, y::Quantity) = Quantity(1/y.val, x / unit(y))
/(x::Number, y::Units) = Quantity(x,inv(y))
/(x::Units, y::Number) = (1/y) * x

//(x::Quantity, y::Units) = Quantity(x.val, unit(x) / y)
//(x::Units, y::Quantity) = Quantity(1//y.val, x / unit(y))
//(x::Number, y::Units) = Rational(x)/y
//(x::Units, y::Number) = (1//y) * x

# Division (quantities)
for op in (:/, ://)
    @eval begin
        ($op)(x::Quantity, y::Quantity) = Quantity(($op)(x.val, y.val), unit(x) / unit(y))
        ($op)(x::Quantity, y::Number) = Quantity(($op)(x.val, y), unit(x))
        ($op)(x::Number, y::Quantity) = Quantity(($op)(x, y.val), inv(unit(y)))
    end
end

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

# Addition / subtraction
for op in [:+, :-]
    @eval ($op)(x::Quantity{S,D,U}, y::Quantity{T,D,U}) where {S,T,D,U} =
        Quantity(($op)(x.val,y.val), U())

    # If not generated, there are run-time allocations
    @eval function ($op)(x::Quantity{S,D,SU}, y::Quantity{T,D,TU}) where {S,T,D,SU,TU}
        ($op)(promote(x,y)...)
    end

    @eval ($op)(x::Quantity, y::Quantity) = throw(DimensionError(x,y))
    @eval ($op)(x::Quantity) = Quantity(($op)(x.val),unit(x))
end

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
    @static if VERSION >= v"0.6.0-" # work-around Julia issue 20103
        # Catch some signatures pre-promotion
        @eval @inline ($_x)(x::Number, y::Quantity, z::Quantity) = ($_y)(x,y,z)
        @eval @inline ($_x)(x::Quantity, y::Number, z::Quantity) = ($_y)(x,y,z)

        # Post-promotion
        @eval @inline ($_x)(x::Quantity{T}, y::Quantity{T}, z::Quantity{T}) where {T <: Number} = ($_y)(x,y,z)
    else
        @eval @inline ($_x)(x::Quantity{T}, y::T, z::T) where {T <: Number} = ($_y)(x,y,z)
        @eval @inline ($_x)(x::T, y::Quantity{T}, z::T) where {T <: Number} = ($_y)(x,y,z)
        @eval @inline ($_x)(x::T, y::T, z::Quantity{T}) where {T <: Number} = ($_y)(x,y,z)
        @eval @inline ($_x)(x::Quantity{T}, y::Quantity{T}, z::T) where {T <: Number} = ($_y)(x,y,z)
        @eval @inline ($_x)(x::T, y::Quantity{T}, z::Quantity{T}) where {T <: Number} = ($_y)(x,y,z)
        @eval @inline ($_x)(x::Quantity{T}, y::T, z::Quantity{T}) where {T <: Number} = ($_y)(x,y,z)
        @eval @inline ($_x)(x::Quantity{T}, y::Quantity{T}, z::Quantity{T}) where {T <: Number} = ($_y)(x,y,z)
    end

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

atan2(y::Quantity, x::Quantity) = atan2(promote(y,x)...)
atan2(y::Quantity{T,D,U}, x::Quantity{T,D,U}) where {T,D,U} = atan2(y.val,x.val)
atan2(y::Quantity{T,D1,U1}, x::Quantity{T,D2,U2}) where {T,D1,U1,D2,U2} =
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

@inline isless(x::Quantity{T,D,U}, y::Quantity{T,D,U}) where {T,D,U} = _isless(x,y)
@inline _isless(x::Quantity{T,D,U}, y::Quantity{T,D,U}) where {T,D,U} = isless(x.val, y.val)
@inline _isless(x::Quantity{T,D1,U1}, y::Quantity{T,D2,U2}) where {T,D1,D2,U1,U2} = throw(DimensionError(x,y))
@inline _isless(x,y) = isless(x,y)

isless(x::Quantity, y::Quantity) = _isless(promote(x,y)...)
isless(x::Quantity, y::Number) = _isless(promote(x,y)...)
isless(x::Number, y::Quantity) = _isless(promote(x,y)...)

@inline <(x::Quantity{T,D,U}, y::Quantity{T,D,U}) where {T,D,U} = _lt(x,y)
@inline _lt(x::Quantity{T,D,U}, y::Quantity{T,D,U}) where {T,D,U} = <(x.val,y.val)
@inline _lt(x::Quantity{T,D1,U1}, y::Quantity{T,D2,U2}) where {T,D1,D2,U1,U2} = throw(DimensionError(x,y))
@inline _lt(x,y) = <(x,y)

<(x::Quantity, y::Quantity) = _lt(promote(x,y)...)
<(x::Quantity, y::Number) = _lt(promote(x,y)...)
<(x::Number, y::Quantity) = _lt(promote(x,y)...)

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
        y::AbstractArray{Quantity{T2,D,U2}}; rtol::Real=Base.rtoldefault(T1,T2),
        atol=zero(Quantity{T1,D,U1}), norm::Function=vecnorm) where {T1,D,U1,T2,U2}

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

==(x::Quantity{S,D,U}, y::Quantity{T,D,U}) where {S,T,D,U} = (x.val == y.val)
function ==(x::Quantity, y::Quantity)
    dimension(x) != dimension(y) && return false
    ==(promote(x,y)...)
end

function ==(x::Quantity, y::Number)
    ==(promote(x,y)...)
end
==(x::Number, y::Quantity) = ==(y,x)
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
one(x::Type{Quantity{T,D,U}}) where {T,D,U} = one(T)

isreal(x::Quantity) = isreal(x.val)
isfinite(x::Quantity) = isfinite(x.val)
isinf(x::Quantity) = isinf(x.val)
isnan(x::Quantity) = isnan(x.val)

unsigned(x::Quantity) = Quantity(unsigned(x.val), unit(x))

for f in (:exp, :exp10, :exp2, :expm1, :log, :log10, :log1p, :log2)
    @eval ($f)(x::DimensionlessQuantity) = ($f)(uconvert(NoUnits, x))
end

real(x::Quantity) = Quantity(real(x.val), unit(x))
imag(x::Quantity) = Quantity(imag(x.val), unit(x))
conj(x::Quantity) = Quantity(conj(x.val), unit(x))

@inline vecnorm(x::Quantity, p::Real=2) =
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

Base.literal_pow(::typeof(^), x::Quantity, ::Type{Val{v}}) where {v} =
    Quantity(Base.literal_pow(^, x.val, Val{v}),
             Base.literal_pow(^, unit(x), Val{v}))

# All of these are needed for ambiguity resolution
^(x::Quantity, y::Integer) = Quantity((x.val)^y, unit(x)^y)
^(x::Quantity, y::Rational) = Quantity((x.val)^y, unit(x)^y)
^(x::Quantity, y::Real) = Quantity((x.val)^y, unit(x)^y)

Base.rand(r::AbstractRNG, ::Type{Quantity{T,D,U}}) where {T,D,U} = rand(r,T)*U()
Base.ones(Q::Type{<:Quantity}, dims::Tuple) = fill!(Array{Q}(dims), oneunit(Q))
Base.ones(a::AbstractArray, Q::Type{<:Quantity}) = fill!(similar(a,Q), oneunit(Q))
