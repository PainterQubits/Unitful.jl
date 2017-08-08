__precompile__(true)
module Unitful

import Base: ==, <, <=, +, -, *, /, //, ^
import Base: show, convert
import Base: abs, abs2, float, fma, muladd, inv, sqrt, cbrt
import Base: min, max, floor, ceil, real, imag, conj
import Base: exp, exp10, exp2, expm1, log, log10, log1p, log2
import Base: sin, cos, tan, cot, sec, csc, atan2, cis, vecnorm

import Base: mod, rem, div, fld, cld, trunc, round, sign, signbit
import Base: isless, isapprox, isinteger, isreal, isinf, isfinite, isnan
import Base: copysign, flipsign
import Base: prevfloat, nextfloat, maxintfloat, rat, step #, linspace
import Base: length, float, start, done, next, last, one, zero, colon#, range
import Base: getindex, eltype, step, last, first, frexp
import Base: Integer, Rational, typemin, typemax
import Base: steprange_last, unsigned

import Base.LinAlg: istril, istriu

export unit, dimension, uconvert, ustrip, upreferred
export @dimension, @derived_dimension, @refunit, @unit, @u_str
export Quantity
export DimensionlessQuantity
export NoUnits, NoDims

const unitmodules = Vector{Module}()
const basefactors = Dict{Symbol,Tuple{Float64,Rational{Int}}}()

include("types.jl")
const promotion = Dict{Symbol,Unit}()

include("user.jl")
const NoUnits = FreeUnits{Tuple{}, Dimensions{Tuple{}}}()
const NoDims = Dimensions{Tuple{}}()
isunitless(::Units) = false
isunitless(::Units{Tuple{}}) = true

(y::FreeUnits)(x::Number) = uconvert(y,x)
(y::ContextUnits)(x::Number) = uconvert(y,x)

"""
    mutable struct DimensionError{T,S} <: Exception
      x::T
      y::S
    end
Thrown when dimensions don't match in an operation that demands they do.
Display `x` and `y` in error message.
"""
mutable struct DimensionError{T,S} <: Exception
    x::T
    y::S
end
Base.showerror(io::IO, e::DimensionError) =
    print(io,"DimensionError: $(e.x) and $(e.y) are not dimensionally compatible.");

numtype(::Quantity{T}) where {T} = T
numtype(::Type{Quantity{T,D,U}}) where {T,D,U} = T

"""
    ustrip(x::Number)
Returns the number out in front of any units. This may be different from the value
in the case of dimensionless quantities. See [`uconvert`](@ref) and the example
below. Because the units are removed, information may be lost and this should
be used with some care.

This function is just calling `x/unit(x)`, which is as fast as directly
accessing the `val` field of `x::Quantity`, but also works for any other kind
of number.

This function is mainly intended for compatibility with packages that don't know
how to handle quantities. This function may be deprecated in the future.

```jldoctest
julia> ustrip(2u"μm/m") == 2
true

julia> uconvert(NoUnits, 2u"μm/m") == 2//1000000
true
```
"""
@inline ustrip(x::Number) = x/unit(x)

"""
    ustrip{Q<:Quantity}(x::Array{Q})
Strip units from an `Array` by reinterpreting to type `T`. The resulting
`Array` is a "unit free view" into array `x`. Because the units are
removed, information may be lost and this should be used with some care.

This function is provided primarily for compatibility purposes; you could pass
the result to PyPlot, for example. This function may be deprecated in the future.

```jldoctest
julia> a = [1u"m", 2u"m"]
2-element Array{Quantity{Int64, Dimensions:{𝐋}, Units:{m}},1}:
 1 m
 2 m

julia> b = ustrip(a)
2-element Array{Int64,1}:
 1
 2

julia> a[1] = 3u"m"; b
2-element Array{Int64,1}:
 3
 2
```
"""
@inline ustrip(x::Array{Q}) where {Q <: Quantity} = reinterpret(numtype(Q), x)

"""
    ustrip{Q<:Quantity}(A::AbstractArray{Q})
Strip units from an `AbstractArray` by making a new array without units using
array comprehensions.

This function is provided primarily for compatibility purposes; you could pass
the result to PyPlot, for example. This function may be deprecated in the future.
"""
ustrip(A::AbstractArray{Q}) where {Q <: Quantity} = (numtype(Q))[ustrip(x) for x in A]

"""
    ustrip{T<:Number}(x::AbstractArray{T})
Fall-back that returns `x`.
"""
@inline ustrip(A::AbstractArray{T}) where {T <: Number} = A

ustrip(A::Diagonal{T}) where {T <: Quantity} = Diagonal(ustrip(A.diag))
ustrip(A::Bidiagonal{T}) where {T <: Quantity} =
    Bidiagonal(ustrip(A.dv), ustrip(A.ev), A.isupper)
ustrip(A::Tridiagonal{T}) where {T <: Quantity} =
    Tridiagonal(ustrip(A.dl), ustrip(A.d), ustrip(A.du))
ustrip(A::SymTridiagonal{T}) where {T <: Quantity} =
    SymTridiagonal(ustrip(A.dv), ustrip(A.ev))

"""
    unit{T,D,U}(x::Quantity{T,D,U})
Returns the units associated with a quantity.

Examples:

```jldoctest
julia> unit(1.0u"m") == u"m"
true

julia> typeof(u"m")
Unitful.FreeUnits{Tuple{Unitful.Unit{:Meter,Unitful.Dimensions{Tuple{Unitful.Dimension{:Length}(1//1)}}}(0, 1//1)},Unitful.Dimensions{Tuple{Unitful.Dimension{:Length}(1//1)}}}
```
"""
@inline unit(x::Quantity{T,D,U}) where {T,D,U} = U()

"""
    unit{T,D,U}(x::Type{Quantity{T,D,U}})
Returns the units associated with a quantity type, `ContextUnits(U(),P())`.

Examples:

```jldoctest
julia> unit(typeof(1.0u"m")) == u"m"
true
```
"""
@inline unit(::Type{Quantity{T,D,U}}) where {T,D,U} = U()


"""
    unit(x::Number)
Returns a `Unitful.Units{Tuple{}, Dimensions{Tuple{}}}` object to indicate that ordinary
numbers have no units. This is a singleton, which we export as `NoUnits`.
The unit is displayed as an empty string.

Examples:

```jldoctest
julia> typeof(unit(1.0))
Unitful.FreeUnits{Tuple{},Unitful.Dimensions{Tuple{}}}
julia> typeof(unit(Float64))
Unitful.FreeUnits{Tuple{},Unitful.Dimensions{Tuple{}}}
julia> unit(1.0) == NoUnits
true
```
"""
@inline unit(x::Number) = NoUnits
@inline unit(x::Type{T}) where {T <: Number} = NoUnits

"""
    dimension(x::Number)
    dimension{T<:Number}(x::Type{T})
Returns a `Unitful.Dimensions{Tuple{}}` object to indicate that ordinary
numbers are dimensionless. This is a singleton, which we export as `NoDims`.
The dimension is displayed as an empty string.

Examples:

```jldoctest
julia> typeof(dimension(1.0))
Unitful.Dimensions{Tuple{}}
julia> typeof(dimension(Float64))
Unitful.Dimensions{Tuple{}}
julia> dimension(1.0) == NoDims
true
```
"""
@inline dimension(x::Number) = NoDims
@inline dimension(x::Type{T}) where {T <: Number} = NoDims

"""
    dimension{U,D}(u::Units{U,D})
Returns a [`Unitful.Dimensions`](@ref) object corresponding to the dimensions
of the units, `D()`. For a dimensionless combination of units, a
`Unitful.Dimensions{Tuple{}}` object is returned.

Examples:

```jldoctest
julia> dimension(u"m")
𝐋

julia> typeof(dimension(u"m"))
Unitful.Dimensions{Tuple{Unitful.Dimension{:Length}(1//1)}}

julia> typeof(dimension(u"m/km"))
Unitful.Dimensions{Tuple{}}
```
"""
@inline dimension(u::Units{U,D}) where {U,D} = D()

"""
    dimension{T,D}(x::Quantity{T,D})
Returns a [`Unitful.Dimensions`](@ref) object `D()` corresponding to the
dimensions of quantity `x`. For a dimensionless [`Unitful.Quantity`](@ref), a
`Unitful.Dimensions{Tuple{}}` object is returned.

Examples:

```jldoctest
julia> dimension(1.0u"m")
𝐋

julia> typeof(dimension(1.0u"m/μm"))
Unitful.Dimensions{Tuple{}}
```
"""
@inline dimension(x::Quantity{T,D}) where {T,D} = D()
@inline dimension(::Type{Quantity{T,D,U}}) where {T,D,U} = D()

"""
    dimension{T<:Number}(x::AbstractArray{T})
Just calls `map(dimension, x)`.
"""
dimension(x::AbstractArray{T}) where {T <: Number} = map(dimension, x)

"""
    dimension{T<:Units}(x::AbstractArray{T})
Just calls `map(dimension, x)`.
"""
dimension(x::AbstractArray{T}) where {T <: Units} = map(dimension, x)

"""
    Quantity(x::Number, y::Units)
Outer constructor for `Quantity`s. This is a generated function to avoid
determining the dimensions of a given set of units each time a new quantity is
made.
"""
@generated function Quantity(x::Number, y::Units)
    u = y()
    d = dimension(u)
    :(Quantity{typeof(x), typeof($d), typeof($u)}(x))
end
Quantity(x::Number, y::Units{Tuple{}}) = x

"""
    promote_unit(::Units, ::Units...)
Given `Units` objects as arguments, this function returns a `Units` object appropriate
for the result of promoting quantities which have these units. This function is kind
of like `promote_rule`, except that it doesn't take types. It also does not return a tuple,
but rather just a [`Unitful.Units`](@ref) object (or it throws an error).

Although we had used `promote_rule` for `Units` objects in prior versions of Unitful,
this was always kind of a hack; it doesn't make sense to promote units directly for
a variety of reasons.
"""
function promote_unit end

# Generic methods
@inline promote_unit(x) = _promote_unit(x)
@inline _promote_unit(x::Units) = x

@inline promote_unit(x,y) = _promote_unit(x,y)

promote_unit(x::Units, y::Units, z::Units, t::Units...) =
    promote_unit(_promote_unit(x,y), z, t...)

# Use configurable fall-back mechanism for FreeUnits
@inline _promote_unit(x::T, y::T) where {T <: FreeUnits} = T()
@inline _promote_unit(x::FreeUnits{N1,D}, y::FreeUnits{N2,D}) where {N1,N2,D} =
    upreferred(dimension(x))

# same units, but promotion context disagrees
@inline _promote_unit(x::T, y::T) where {T <: ContextUnits} = T()  #ambiguity reasons
@inline _promote_unit(x::ContextUnits{N,D,P1}, y::ContextUnits{N,D,P2}) where {N,D,P1,P2} =
    ContextUnits{N,D,promote_unit(P1(), P2())}()
# different units, but promotion context agrees
@inline _promote_unit(x::ContextUnits{N1,D,P}, y::ContextUnits{N2,D,P}) where {N1,N2,D,P} =
    ContextUnits(P(), P())
# different units, promotion context disagrees, fall back to FreeUnits
@inline _promote_unit(x::ContextUnits{N1,D}, y::ContextUnits{N2,D}) where {N1,N2,D} =
    promote_unit(FreeUnits(x), FreeUnits(y))

# ContextUnits beat FreeUnits
@inline _promote_unit(x::ContextUnits{N,D}, y::FreeUnits{N,D}) where {N,D} = x
@inline _promote_unit(x::ContextUnits{N1,D,P}, y::FreeUnits{N2,D}) where {N1,N2,D,P} =
    ContextUnits(P(), P())
@inline _promote_unit(x::FreeUnits, y::ContextUnits) = promote_unit(y,x)

# FixedUnits beat everything
@inline _promote_unit(x::T, y::T) where {T <: FixedUnits} = T()
@inline _promote_unit(x::FixedUnits{M,D}, y::Units{N,D}) where {M,N,D} = x
@inline _promote_unit(x::Units, y::FixedUnits) = promote_unit(y,x)

# Different units but same dimension are not fungible for FixedUnits
@inline _promote_unit(x::FixedUnits{M,D}, y::FixedUnits{N,D}) where {M,N,D} =
    error("automatic conversion prohibited.")

# If we didn't handle it above, the dimensions mismatched.
@inline _promote_unit(x::Units, y::Units) = throw(DimensionError(x,y))

@inline name(x::Unit{S,D}) where {S,D} = S
@inline name(x::Dimension{S}) where {S} = S
@inline tens(x::Unit) = x.tens
@inline power(x::Unit) = x.power
@inline power(x::Dimension) = x.power

# This is type unstable but
# a) this method is not called by the user
# b) ultimately the instability will only be present at compile time as it is
# hidden behind a "generated function barrier"
function basefactor(inex, ex, eq, tens, p)
    # Sometimes (x::Rational)^1 can fail for large rationals because the result
    # is of type x*x so we do a hack here
    function dpow(x,p)
        if p == 0
            1
        elseif p == 1
            x
        elseif p == -1
            1//x
        else
            x^p
        end
    end

    if isinteger(p)
        p = Integer(p)
    end

    eq_is_exact = false
    output_ex_float = (10.0^tens * float(ex))^p
    eq_raised = float(eq)^p
    if isa(eq, Integer) || isa(eq, Rational)
        output_ex_float *= eq_raised
        eq_is_exact = true
    end

    can_exact = (output_ex_float < typemax(Int))
    can_exact &= (1/output_ex_float < typemax(Int))
    can_exact &= isinteger(p)

    can_exact2 = (eq_raised < typemax(Int))
    can_exact2 &= (1/eq_raised < typemax(Int))
    can_exact2 &= isinteger(p)

    if can_exact
        if eq_is_exact
            # If we got here then p is an integer.
            # Note that sometimes x^1 can cause an overflow error if x is large because
            # of how power_by_squaring is implemented for Rationals, so we use dpow.
            x = dpow(eq*ex*(10//1)^tens, p)
            return (inex^p, isinteger(x) ? Int(x) : x)
        else
            x = dpow(ex*(10//1)^tens, p)
            return ((inex*eq)^p, isinteger(x) ? Int(x) : x)
        end
    else
        if eq_is_exact && can_exact2
            x = dpow(eq,p)
            return ((inex * ex * 10.0^tens)^p, isinteger(x) ? Int(x) : x)
        else
            return ((inex * ex * 10.0^tens * eq)^p, 1)
        end
    end
end

@inline basefactor(x::Unit{U}) where {U} = basefactor(basefactors[U]..., 1, 0, power(x))

function basefactor(x::Units{U}) where {U}
    fact1 = map(basefactor, (U.parameters...))
    inex1 = mapreduce(x->getfield(x,1), *, 1.0, fact1)
    float_ex1 = mapreduce(x->float(getfield(x,2)), *, 1, fact1)
    can_exact = (float_ex1 < typemax(Int))
    can_exact &= (1/float_ex1 < typemax(Int))
    if can_exact
        inex1, mapreduce(x->getfield(x,2), *, 1, fact1)
    else
        inex1*float_ex1, 1
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
    @eval function ($op)(x::Quantity, y::Number)
        if isa(x, DimensionlessQuantity)
            ($op)(promote(x,y)...)
        else
            throw(DimensionError(x,y))
        end
    end
    @eval function ($op)(x::Number, y::Quantity)
        if isa(y, DimensionlessQuantity)
            ($op)(promote(x,y)...)
        else
            throw(DimensionError(x,y))
        end
    end

    @eval ($op)(x::Quantity) = Quantity(($op)(x.val),unit(x))
end

*(x::Number, y::Units, z::Units...) = Quantity(x,*(y,z...))

# Kind of weird, but okay, no need to make things noncommutative.
*(x::Units, y::Number) = *(y,x)

function tensfactor(x::Unit)
    p = power(x)
    if isinteger(p)
        p = Integer(p)
    end
    tens(x)*p
end

@generated function tensfactor(x::Units)
    tunits = (x.parameters[1].parameters...)
    a = mapreduce(tensfactor, +, 0, tunits)
    :($a)
end

"""
```
*(a0::Dimensions, a::Dimensions...)
```

Given however many dimensions, multiply them together.

Collect [`Unitful.Dimension`](@ref) objects from the type parameter of the
[`Unitful.Dimensions`](@ref) objects. For identical dimensions, collect powers
and sort uniquely by the name of the `Dimension`.

Examples:

```jldoctest
julia> u"𝐌*𝐋/𝐓^2"
𝐋 𝐌 𝐓^-2

julia> u"𝐋*𝐌/𝐓^2"
𝐋 𝐌 𝐓^-2

julia> typeof(u"𝐋*𝐌/𝐓^2") == typeof(u"𝐌*𝐋/𝐓^2")
true
```
"""
@generated function *(a0::Dimensions, a::Dimensions...)
    # Implementation is very similar to *(::Units, ::Units...)
    b = Vector{Dimension}()
    a0p = (a0.parameters[1].parameters...)
    length(a0p) > 0 && append!(b, a0p)
    for x in a
        xp = (x.parameters[1].parameters...)
        length(xp) > 0 && append!(b, xp)
    end

    sort!(b, by=x->power(x))
    sort!(b, by=x->name(x))

    c = Vector{Dimension}()
    if !isempty(b)
        i = start(b)
        oldstate = b[i]
        p=0//1
        while !done(b, i)
            (state, i) = next(b, i)
            if name(state) == name(oldstate)
                p += power(state)
            else
                if p != 0
                    push!(c, Dimension{name(oldstate)}(p))
                end
                p = power(state)
            end
            oldstate = state
        end
        if p != 0
            push!(c, Dimension{name(oldstate)}(p))
        end
    end

    d = Tuple{c...}
    :(Dimensions{$d}())
end

# Both methods needed for ambiguity resolution
^(x::Dimension{T}, y::Integer) where {T} = Dimension{T}(power(x)*y)
^(x::Dimension{T}, y::Number) where {T} = Dimension{T}(power(x)*y)

# A word of caution:
# Exponentiation is not type-stable for `Dimensions` objects in many cases
^(x::Dimensions{T}, y::Integer) where {T} = *(Dimensions{Tuple{map(a->a^y, (T.parameters...))...}}())
^(x::Dimensions{T}, y::Number) where {T} = *(Dimensions{Tuple{map(a->a^y, (T.parameters...))...}}())
@generated function Base.literal_pow(::typeof(^), x::Dimensions{T}, ::Type{Val{p}}) where {T,p}
    z = *(Dimensions{Tuple{map(a->a^p, (T.parameters...))...}}())
    :($z)
end

@inline dimension(u::Unit{U,D}) where {U,D} = D()^u.power

*(x::Quantity, y::Units, z::Units...) = Quantity(x.val, *(unit(x),y,z...))
*(x::Quantity, y::Quantity) = Quantity(x.val*y.val, unit(x)*unit(y))

# Next two lines resolves some method ambiguity:
*(x::Bool, y::T) where {T <: Quantity} =
    ifelse(x, y, ifelse(signbit(y), -zero(y), zero(y)))
*(x::Quantity, y::Bool) = Quantity(x.val*y, unit(x))

*(y::Number, x::Quantity) = *(x,y)
*(x::Quantity, y::Number) = Quantity(x.val*y, unit(x))

# looked in arraymath.jl for similar code
for f in (:*,)
    @eval begin
        function ($f)(A::Units, B::AbstractArray{T}) where {T}
            F = similar(B, Base.promote_op($f,typeof(A),T))
            for (iF, iB) in zip(eachindex(F), eachindex(B))
                @inbounds F[iF] = ($f)(A, B[iB])
            end
            return F
        end
        function ($f)(A::AbstractArray{T}, B::Units) where {T}
            F = similar(A, Base.promote_op($f,T,typeof(B)))
            for (iF, iA) in zip(eachindex(F), eachindex(A))
                @inbounds F[iF] = ($f)(A[iA], B)
            end
            return F
        end
    end
end

# Division (units)

/(x::Units, y::Units) = *(x,inv(y))
/(x::Dimensions, y::Dimensions) = *(x,inv(y))
/(x::Quantity, y::Units) = Quantity(x.val, unit(x) / y)
/(x::Units, y::Quantity) = Quantity(1/y.val, x / unit(y))
/(x::Number, y::Units) = Quantity(x,inv(y))
/(x::Units, y::Number) = (1/y) * x

//(x::Units, y::Units)  = x/y
//(x::Dimensions, y::Dimensions)  = x/y
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

# Division (other functions)

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

        xunits = (x.parameters[3].parameters[1].parameters...)
        yunits = (y.parameters[3].parameters[1].parameters...)

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
isapprox(x::Quantity, y::Number; kwargs...) = isapprox(uconvert(NoUnits, x), y; kwargs...)
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
    if dimension(x) == NoDims
        uconvert(NoUnits, x) == y
    else
        false
    end
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

*(y::Units, r::Range) = *(r,y)
*(r::Range, y::Units) = range(first(r)*y, step(r)*y, length(r))
*(r::Range, y::Units, z::Units...) = *(x, *(y,z...))

include("range.jl")

typemin(::Type{Quantity{T,D,U}}) where {T,D,U} = typemin(T)*U()
typemin(x::Quantity{T}) where {T} = typemin(T)*unit(x)

typemax(::Type{Quantity{T,D,U}}) where {T,D,U} = typemax(T)*U()
typemax(x::Quantity{T}) where {T} = typemax(T)*unit(x)

"""
    offsettemp(::Unit)
For temperature units, this function is used to set the scale offset.
"""
offsettemp(::Unit) = 0

@inline dimtype(u::Unit{U,D}) where {U,D} = D

@generated function *(a0::FreeUnits, a::FreeUnits...)

    # Sort the units uniquely. This is a generated function so that we
    # don't have to figure out the units each time.
    b = Vector{Unit}()
    a0p = (a0.parameters[1].parameters...)
    length(a0p) > 0 && append!(b, a0p)
    for x in a
        xp = (x.parameters[1].parameters...)
        length(xp) > 0 && append!(b, xp)
    end

    # b is an Array containing all of the Unit objects that were
    # found in the type parameters of the Units objects (a0, a...)
    sort!(b, by=x->power(x))
    sort!(b, by=x->tens(x))
    sort!(b, by=x->name(x))

    # Units[m,m,cm,cm^2,cm^3,nm,m^4,µs,µs^2,s]
    # reordered as:
    # Units[nm,cm,cm^2,cm^3,m,m,m^4,µs,µs^2,s]

    # Collect powers of a given unit
    c = Vector{Unit}()
    if !isempty(b)
        i = start(b)
        oldstate = b[i]
        p=0//1
        while !done(b, i)
            (state, i) = next(b, i)
            if tens(state) == tens(oldstate) && name(state) == name(oldstate)
                p += power(state)
            else
                if p != 0
                    push!(c, Unit{name(oldstate),dimtype(oldstate)}(tens(oldstate), p))
                end
                p = power(state)
            end
            oldstate = state
        end
        if p != 0
            push!(c, Unit{name(oldstate),dimtype(oldstate)}(tens(oldstate), p))
        end
    end
    # results in:
    # Units[nm,cm^6,m^6,µs^3,s]

    d = Tuple{c...}
    f = typeof(mapreduce(dimension, *, NoDims, c))
    :(FreeUnits{$d,$f}())
end
*(a0::ContextUnits, a::ContextUnits...) =
    ContextUnits(*(FreeUnits(a0), FreeUnits.(a)...),
                    *(FreeUnits(upreferred(a0)), FreeUnits.((upreferred).(a))...))
FreeOrContextUnits = Union{FreeUnits, ContextUnits}
*(a0::FreeOrContextUnits, a::FreeOrContextUnits...) =
    *(ContextUnits(a0), ContextUnits.(a)...)
*(a0::FixedUnits, a::FixedUnits...) =
    FixedUnits(*(FreeUnits(a0), FreeUnits.(a)...))

"""
```
*(a0::Units, a::Units...)
```

Given however many units, multiply them together. This is actually handled by
a few different methods, since we have `FreeUnits`, `ContextUnits`, and `FixedUnits`.

Collect [`Unitful.Unit`](@ref) objects from the type parameter of the
[`Unitful.Units`](@ref) objects. For identical units including SI prefixes
(i.e. cm ≠ m), collect powers and sort uniquely by the name of the `Unit`.
The unique sorting permits easy unit comparisons.

Examples:

```jldoctest
julia> u"kg*m/s^2"
kg m s^-2

julia> u"m/s*kg/s"
kg m s^-2

julia> typeof(u"m/s*kg/s") == typeof(u"kg*m/s^2")
true
```
"""
*(a0::Units, a::Units...) = FixedUnits(*(FreeUnits(a0), FreeUnits.(a)...))
# Logic above is that if we're not using FreeOrContextUnits, at least one is FixedUnits.

# Both methods needed for ambiguity resolution
^(x::Unit{U,D}, y::Integer) where {U,D} = Unit{U,D}(tens(x), power(x)*y)
^(x::Unit{U,D}, y::Number) where {U,D} = Unit{U,D}(tens(x), power(x)*y)

# A word of caution:
# Exponentiation is not type-stable for `Units` objects.
# Dimensions get reconstructed anyway so we pass Tuple{} for the D type parameter...
^(x::FreeUnits{N}, y::Integer) where {N} =
    *(FreeUnits{Tuple{map(a->a^y, (N.parameters...))...}, Tuple{}}())
^(x::FreeUnits{N}, y::Number) where {N} =
    *(FreeUnits{Tuple{map(a->a^y, (N.parameters...))...}, Tuple{}}())

^(x::ContextUnits{N,D,P}, y::Integer) where {N,D,P} =
    *(ContextUnits{Tuple{map(a->a^y, (N.parameters...))...}, Tuple{}, typeof(P()^y)}())
^(x::ContextUnits{N,D,P}, y::Number) where {N,D,P} =
    *(ContextUnits{Tuple{map(a->a^y, (N.parameters...))...}, Tuple{}, typeof(P()^y)}())

^(x::FixedUnits{N}, y::Integer) where {N} =
    *(FixedUnits{Tuple{map(a->a^y, (N.parameters...))...}, Tuple{}}())
^(x::FixedUnits{N}, y::Number) where {N} =
    *(FixedUnits{Tuple{map(a->a^y, (N.parameters...))...}, Tuple{}}())

@generated function Base.literal_pow(::typeof(^), x::FreeUnits{N}, ::Type{Val{p}}) where {N,p}
    y = *(FreeUnits{Tuple{map(a->a^p, (N.parameters...))...}, ()}())
    :($y)
end
@generated function Base.literal_pow(::typeof(^), x::ContextUnits{N,D,P}, ::Type{Val{p}}) where {N,D,P,p}
    y = *(ContextUnits{Tuple{map(a->a^p, (N.parameters...))...}, Tuple{}, typeof(P()^p)}())
    :($y)
end
@generated function Base.literal_pow(::typeof(^), x::FixedUnits{N}, ::Type{Val{p}}) where {N,p}
    y = *(FixedUnits{Tuple{map(a->a^p, (N.parameters...))...}, ()}())
    :($y)
end
Base.literal_pow(::typeof(^), x::Quantity, ::Type{Val{v}}) where {v} =
    Quantity(Base.literal_pow(^, x.val, Val{v}),
             Base.literal_pow(^, unit(x), Val{v}))

# All of these are needed for ambiguity resolution
^(x::Quantity, y::Integer) = Quantity((x.val)^y, unit(x)^y)
^(x::Quantity, y::Rational) = Quantity((x.val)^y, unit(x)^y)
^(x::Quantity, y::Real) = Quantity((x.val)^y, unit(x)^y)

# Since exponentiation is not type stable, we define a special `inv` method to
# enable fast division. For julia 0.6.0-dev.1711, the appropriate methods for ^
# and * need to be defined before this one!
for (fun,pow) in ((:inv, -1//1), (:sqrt, 1//2), (:cbrt, 1//3))
    # The following are generated functions to ensure type stability.
    @eval @generated function ($fun)(x::Dimensions{T}) where {T}
        dimtuple = map(x->x^($pow), (T.parameters...))
        y = *(Dimensions{Tuple{dimtuple...}}())    # sort appropriately
        :($y)
    end

    @eval @generated function ($fun)(x::FreeUnits{T}) where {T}
        unittuple = map(x->x^($pow), (T.parameters...))
        y = *(FreeUnits{Tuple{unittuple...},Tuple{}}())    # sort appropriately
        :($y)
    end

    @eval @generated function ($fun)(x::ContextUnits)
        unittuple = map(x->x^($pow), (x.parameters[1].parameters...))
        promounit = ($fun)(x.parameters[3]())
        y = *(ContextUnits{Tuple{unittuple...},(),typeof(promounit)}())   # sort appropriately
        :($y)
    end

    @eval @generated function ($fun)(x::FixedUnits{T}) where {T}
        unittuple = map(x->x^($pow), (T.parameters...))
        y = *(FixedUnits{Tuple{unittuple...},()}())   # sort appropriately
        :($y)
    end
end

include("display.jl")
include("promotion.jl")
include("conversion.jl")
include("fastmath.jl")
include("pkgdefaults.jl")
include("temperature.jl")

function __init__()
    # @u_str should be aware of units defined in module Unitful
    Unitful.register(Unitful)
end

end
