struct IsRootPowerRatio{S,T}
    val::T
end
IsRootPowerRatio{S}(x) where {S} = IsRootPowerRatio{S, typeof(x)}(x)
Base.show(io::IO, x::IsRootPowerRatio{S}) where {S} =
    print(io, ifelse(S, "root-power ratio", "power ratio"), " with reference ", x.val)
const PowerRatio{T} = IsRootPowerRatio{false,T}
const RootPowerRatio{T} = IsRootPowerRatio{true,T}
dimension(x::IsRootPowerRatio{S,T}) where {S,T} = dimension(T)
unwrap(x::IsRootPowerRatio) = x.val
unwrap(x) = x

base(::LogInfo{N,B}) where {N,B} = B
prefactor(::LogInfo{N,B,P}) where {N,B,P} = P

leveltype(x::Level{L,S}) where {L,S} = Level{L,S}
dimension(x::Level) = dimension(reflevel(x))
dimension(x::Type{T}) where {T<:Level} = dimension(reflevel(T))
function Base.float(x::Level{L,S}) where {L,S}
    v = float(x.val)
    return Level{L,S,typeof(v)}(v)
end
logunit(x::Level{L,S}) where {L,S} = MixedUnits{Level{L,S}}()
logunit(x::Type{T}) where {L,S,T<:Level{L,S}} = MixedUnits{Level{L,S}}()

abbr(x::Level{L,S}) where {L,S} = join([abbr(L()), " (", S, ")"])

Base.convert(::Type{LogScaled{L1}}, x::Level{L2,S}) where {L1,L2,S} = Level{L1,S}(x.val)
Base.convert(T::Type{<:Level}, x::Level) = T(x.val)
Base.convert(::Type{Quantity{T,D,U}}, x::Level) where {T,D,U} =
    convert(Quantity{T,D,U}, x.val)
Base.convert(::Type{Quantity{T}}, x::Level) where {T<:Number} = convert(Quantity{T}, x.val)
Base.convert(::Type{T}, x::Quantity) where {L,S,T<:Level{L,S}} = T(x)
Base.convert(::Type{T}, x::Level) where {T<:Real} = T(x.val)

"""
    reflevel(x::Level{L,S})
    reflevel(::Type{Level{L,S}})
    reflevel(::Type{Level{L,S,T}})
Returns the reference level, e.g.

```jldoctest
julia> reflevel(3u"dBm")
1 mW
```
"""
function reflevel end
reflevel(x::Level{L,S}) where {L,S} = unwrap(S)
reflevel(::Type{Level{L,S}}) where {L,S} = unwrap(S)
reflevel(::Type{Level{L,S,T}}) where {L,S,T} = unwrap(S)

gaintype(x::Gain{L}) where {L} = Gain{L}
dimension(x::Gain) = NoDims
dimension(x::Type{<:Gain}) = NoDims
function Base.float(x::Gain{L}) where {L}
    v = float(x.val)
    return Gain{L,typeof(v)}(v)
end
logunit(x::Gain{L}) where {L} = MixedUnits{Gain{L}}()
logunit(x::Type{T}) where {L, T<:Gain{L}} = MixedUnits{Gain{L}}()

abbr(x::Gain{L}) where {L} = abbr(L())
function Gain{L}(val::Real) where {L <: LogInfo}
    dimension(val) != NoDims && throw(DimensionError(val,1))
    return Gain{L, typeof(val)}(val)
end

Base.convert(::Type{Gain{L}}, x::Gain{L}) where {L} = Gain{L}(x.val)
Base.convert(::Type{Gain{L1}}, x::Gain{L2}) where {L1,L2} = Gain{L1}(_gconv(L1,L2,x))
Base.convert(::Type{Gain{L,T1}}, x::Gain{L,T2}) where {L,T1,T2} = Gain{L,T1}(x.val)
Base.convert(T::Type{Gain{L1,T1}}, x::Gain{L2,T2}) where {L1,L2,T1,T2} = T(_gconv(L1,L2,x))
Base.convert(::Type{LogScaled{L1}}, x::Gain{L2}) where {L1,L2} = Gain{L1}(_gconv(L1,L2,x))
function _gconv(L1,L2,x)
    if isrootpower(L1) == isrootpower(L2)
        gain = tolog(L1,fromlog(L2,x.val))
    elseif isrootpower(L1) && !isrootpower(L2)
        gain = tolog(L1,fromlog(L2,0.5*x.val))
    else
        gain = tolog(L1,fromlog(L2,2*x.val))
    end
    return gain
end

tolog(L,S,x) = (1+isrootpower(S)) * prefactor(L()) * (logfn(L()))(x)
tolog(L,x) = (1+isrootpower(L)) * prefactor(L()) * (logfn(L()))(x)
fromlog(L,S,x) = unwrap(S) * expfn(L())( x / ((1+isrootpower(S))*prefactor(L())) )
fromlog(L,x) = expfn(L())( x / ((1+isrootpower(L))*prefactor(L())) )

function Base.show(io::IO, x::MixedUnits{T,U}) where {T,U}
    print(io, abbr(x))
    if x.units != NoUnits
        print(io, " ")
        show(io, x.units)
    end
end

abbr(::MixedUnits{L}) where {L <: Level} = abbr(L(reflevel(L)))
abbr(::MixedUnits{L}) where {L <: Gain} = abbr(L(1))

dimension(a::MixedUnits{L}) where {L} = dimension(L) * dimension(a.units)
unit(a::MixedUnits{L,U}) where {L,U} = U()
logunit(a::MixedUnits{L}) where {L} = MixedUnits{L}()
isunitless(::MixedUnits) = false

Base. *(::MixedUnits, ::MixedUnits) = error("cannot have more than one logarithmic unit.")
Base. /(::MixedUnits{T}, ::MixedUnits{S}) where {T,S} =
    error("cannot divide logarithmic units except to cancel.")
Base. /(x::MixedUnits{T}, y::MixedUnits{T}) where {T} = x.units / y.units

Base. *(x::MixedUnits{T}, y::Units) where {T} = MixedUnits{T}(x.units * y)
Base. *(x::Units, y::MixedUnits) = y * x
Base. /(x::MixedUnits{T}, y::Units) where {T} = MixedUnits{T}(x.units / y)
Base. /(x::Units, y::MixedUnits) = error("cannot divide logarithmic units except to cancel.")

Base. *(x::Real, y::MixedUnits{Level{L,S}}) where {L,S} = (Level{L,S}(fromlog(L,S,x)))*y.units
Base. *(x::Real, y::MixedUnits{Gain{L}}) where {L} = (Gain{L}(x))*y.units
Base. *(x::MixedUnits, y::Number) = y * x
Base. /(x::Number, y::MixedUnits) = error("cannot divide out logarithmic units; try `linear`.")
Base. /(x::MixedUnits, y::Number) = inv(y) * x

function uconvert(a::Units, x::Level)
    dimension(a) != dimension(x) && throw(DimensionError(a,x))
    return uconvert(a, x.val)
end
uconvert(a::Units, x::Quantity{<:Level}) = uconvert(a, linear(x))
uconvert(a::Units, x::Quantity{<:Gain}) = uconvert(a, linear(x))
function uconvert(a::MixedUnits{Level{L,S}}, x::Number) where {L,S}
    dimension(a) != dimension(x) && throw(DimensionError(a,x))
    q1 = uconvert(unit(unwrap(S))*a.units, linear(x)) / a.units
    return Level{L,S}(q1) * a.units
end

function uconvert(a::MixedUnits{Gain{L}}, x::Gain) where {L}
    dimension(a) != dimension(x) && throw(DimensionError(a,x))
    return convert(Gain{L}, x)
end
function uconvert(a::MixedUnits{<:Gain}, x::Number)
    dimension(a) != dimension(x) && throw(DimensionError(a,x))
    error("ambiguous; use `uconvertr` or `uconvertrp`.")
end
function uconvert(a::MixedUnits{Gain{L}}, x::Quantity) where {L}
    dimension(a) != dimension(x) && throw(DimensionError(a,x))
    convert(Gain{L}, x.val) * convfact(unit(a), unit(x)) * unit(a)
end
function uconvert(a::MixedUnits{Gain{L1,<:Real}}, x::Level{L2,S}) where {L1,L2,S}
    dimension(a) != dimension(x) && throw(DimensionError(a,x))
    return Level{L1,S}(x.val)
end

ustrip(x::Level{L,S}) where {L<:LogInfo,S} = tolog(L,S,x.val/reflevel(x))
ustrip(x::Gain) = x.val

isrootpower(y::IsRootPowerRatio{T}) where {T} = T
isrootpower(y) = isrootpower_dim(dimension(y))
isrootpower_dim(y) =
    error("undefined behavior. Please file an issue with the code needed to reproduce.")

==(x::Gain, y::Level) = ==(y,x)
==(x::Level, y::Gain) = false

Base. +(x::Level{L,S}, y::Level{L,S}) where {L,S} = Level{L,S}(x.val + y.val)
Base. +(x::Gain{L}, y::Gain{L}) where {L} = Gain{L}(x.val + y.val)
Base. +(x::Level{L,S}, y::Gain{L}) where {L,S} = Level{L,S}(fromlog(L, S, ustrip(x)+y.val))
Base. +(x::Gain, y::Level) = +(y,x)

Base. -(x::Level{L,S}, y::Level{L,S}) where {L,S} = Level{L,S}(x.val - y.val)
Base. -(x::Gain{L}, y::Gain{L}) where {L} = Gain{L}(x.val - y.val)
Base. -(x::Level{L,S}, y::Gain{L}) where {L,S} = Level{L,S}(fromlog(L, S, ustrip(x) - y.val))
Base. -(x::Gain, y::Level) = error("cannot subtract a level from a gain.")

# Multiplication
Base. *(x::Number, y::Level) = *(y,x)
Base. *(x::Bool, y::Level) = *(y,x)                                    # for method ambiguity
Base. *(x::Quantity, y::Level) = *(y,x)                                # for method ambiguity
Base. *(x::Level, y::Number) = (leveltype(x))(x.val * y)
Base. *(x::Level, y::Bool) = (leveltype(x))(x.val * y)    # for method ambiguity
Base. *(x::Level, y::Quantity) = *(x.val, y)
Base. *(x::Level, y::Level) = *(x.val, y.val)
Base. *(x::Level, y::Gain) = *(promote(x,y)...)
Base. *(x::Level{L,S}, y::Gain{L}) where {L,S} = Level{L,S}(fromlog(L, S, ustrip(x)+y.val))

Base. *(x::Number, y::Gain) = *(y,x)
Base. *(x::Bool, y::Gain) = *(y,x)                                     # for method ambiguity
Base. *(x::Gain, y::Number) = (gaintype(x))(x.val * y)
Base. *(x::Gain, y::Bool) = (gaintype(x))(x.val * y)                   # for method ambiguity
Base. *(x::Gain, y::Level) = *(promote(x,y)...)
Base. *(x::Gain, y::Gain) = *(promote(x,y)...)
Base. *(x::Gain{L}, y::Level{L,S}) where {L,S} = Level{L,S}(fromlog(L, S, ustrip(x)+y.val))
Base. *(x::Gain{L}, y::Gain{L}) where {L} = Gain{L}(x.val + y.val)     # contentious?

Base. *(x::Quantity, y::Gain) =
    isrootpower(x) ? uconvertrp(NoUnits, y) * x : uconvertp(NoUnits, y) * x
Base. *(x::Gain, y::Quantity) = *(y,x)

# Division
Base. /(x::Level, y::Number) = (leveltype(x))(linear(x) / y)
Base. /(x::Level, y::Quantity) = linear(x) / y
Base. /(x::Level, y::Level) = linear(x) / linear(y)
Base. /(x::Level{L,S}, y::Gain{L}) where {L,S} = Level{L,S}(fromlog(L, S, ustrip(x) - y.val))
Base. //(x::Level, y::Number) = (leveltype(x))(linear(x) // y)
Base. //(x::Quantity, y::Level) = x // linear(y)
Base. //(x::Level, y::Quantity) = linear(x) // y
Base. //(x::Level, y::Level) = linear(x) // linear(y)
Base. //(x::Level, y::Complex) = linear(x) // y     # ambiguity resolution
Base. //(x::Number, y::Level) = x//linear(y)
Base. //(x::Level, y::Units) = x/y
Base. //(x::Units, y::Level) = x//linear(y)

Base. /(x::Gain{L}, y::Gain{L}) where {L} = Gain{L}(x.val - y.val)
Base. /(x::Quantity, y::Gain) =
    isrootpower(x) ? x / uconvertrp(NoUnits, y) : x / uconvertp(NoUnits, y)
Base. //(x::Gain, y::Units) = x/y
Base. //(x::Units, y::Gain) = x//linear(y)

function (Base.promote_rule(::Type{Level{L1,S1,T1}}, ::Type{Level{L2,S2,T2}})
        where {L1,L2,S1,S2,T1<:Number,T2<:Number})
    if L1 == L2
        if S1 == S2
            # Use convert(promote_type(typeof(S1), typeof(S2)), S1) instead of S1?
            return Level{L1, S1, promote_type(T1,T2)}
        else
            return promote_type(T1,T2)
        end
    else
        return promote_type(T1,T2)
    end
end

function Base.promote_rule(::Type{Level{L,R,S}}, ::Type{Quantity{T,D,U}}) where {L,R,S,T,D,U}
    return promote_type(S, Quantity{T,D,U})
end
function Base.promote_rule(::Type{Quantity{T,D,U}}, ::Type{Level{L,R,S}}) where {L,R,S,T,D,U}
    return promote_type(S, Quantity{T,D,U})
end
function Base.promote_rule(::Type{Level{L,R,S}}, ::Type{T}) where {L,R,S,T<:Real}
    return promote_type(S,T)
end
function Base.promote_rule(::Type{T}, ::Type{Level{L,R,S}}) where {L,R,S,T<:Real}
    return promote_type(S,T)
end

Base.promote_rule(::Type{G1}, ::Type{G2}) where {L,T1,T2, G1<:Gain{L,T1}, G2<:Gain{L,T2}} =
    Gain{L,promote_type(T1,T2)}
Base.promote_rule(A::Type{G}, B::Type{N}) where {L,T1, G<:Gain{L,T1}, N<:Number} =
    error("no automatic promotion of $A and $B.")
Base.promote_rule(A::Type{G}, B::Type{L}) where {G<:Gain, L2, L<:Level{L2}} = LogScaled{L2}

function Base.show(io::IO, x::Gain)
    print(io, x.val, " ", abbr(x))
    nothing
end
function Base.show(io::IO, x::Level)
    print(io, ustrip(x), " ", abbr(x))
    nothing
end

function Base.show(io::IO, x::Quantity{<:Union{Level,Gain},D,U}) where {D,U}
    print(io, "[")
    show(io, x.val)
    print(io, "]")
    if !isunitless(U())
        print(io," ")
        show(io, U())
    end
    nothing
end

"""
    uconvertp(u::Units, x)
    uconvertp(u::MixedUnits, x)
Generically, this is the same as [`Unitful.uconvert`](@ref). In cases where unit conversion
would be ambiguous without further information (e.g. `uconvert(dB, 10)`), `uconvertp`
presumes ratios are of root-power quantities.

It is important to note that careless use of this function can lead to erroneous calculations.
Consider `Quantity{<:Gain}` types: it is tempting to use this to transform `-20dB/m` into
`0.1/m`, however this means something fundamentally different than `-20dB/m`. Consider what
happens when you try to compute exponential attenuation by multiplying `0.1/m` by a length.

Examples:
```jldoctest
julia> using Unitful

julia> uconvertp(u"dB", 10)
20 dB

julia> uconvertp(NoUnits, 20u"dB")
10
```
"""
function uconvertp end
uconvertp(u, x) = uconvert(u, x)    # fallback
uconvertp(::Units{()}, x::Gain{L}) where {L} =
    fromlog(L, ifelse(isrootpower(L), 2, 1)*x.val)
uconvertp(u::T, x::Real) where {L, T <: MixedUnits{Gain{L}, <:Units{()}}} =
    ifelse(isrootpower(L), 0.5, 1) * tolog(L, x) * u
# function uconvertp(a::MixedUnits{Gain{L}}, x::Number) where {L}
#     dimension(a) != dimension(x) && throw(DimensionError(a,x))
#
# end

"""
    uconvertrp(u::Units, x)
    uconvertrp(u::MixedUnits, x)
In most cases, this is the same as [`Unitful.uconvert`](@ref). In cases where unit conversion
would be ambiguous without further information (e.g. `uconvert(dB, 10)`), `uconvertp`
presumes ratios are of power quantities.

It is important to note that careless use of this function can lead to erroneous calculations.
Consider `Quantity{<:Gain}` types: it is tempting to use this to transform `-20dB/m` into
`0.01/m`, however this means something fundamentally different than `-20dB/m`. Consider what
happens when you try to compute exponential attenuation by multiplying `0.01/m` by a length.
"""

function uconvertrp end
uconvertrp(u, x) = uconvert(u, x)
uconvertrp(::Units{()}, x::Gain{L}) where {L} =
    fromlog(L, ifelse(isrootpower(L), 1.0, 0.5)*x.val)
uconvertrp(u::T, x::Real) where {L, T <: MixedUnits{Gain{L}, <:Units{()}}} =
    ifelse(isrootpower(L), 1, 2) * tolog(L, x) * u

"""
    linear(x::Quantity)
    linear(x::Level)
    linear(x::Number) = x
Returns a quantity equivalent to `x` but without any logarithmic scales.

It is important to note that this operation will error for `Quantity{<:Gain}` types. This
is for two reasons:

- `20dB` could be interpreted as either a power or root-power ratio.
- Even if `-20dB/m` were interpreted as, say, `0.01/m`, this means something fundamentally
  different than `-20dB/m`. `0.01/m` cannot be used to calculate exponential attenuation.
"""
linear(x::Quantity{<:Level}) = (x.val.val)*unit(x)
linear(x::Quantity{<:Gain}) = error("use uconvertp or uconvertrp instead.")
linear(x::Level) = x.val
linear(x::Gain) = error("use uconvertp or uconvertrp instead.")
linear(x::Number) = x

"""
    logfn(x::LogInfo)
Returns the appropriate logarithm function to use in calculations involving the
logarithmic unit / quantity. For example, decibel-based units yield `log10`,
Neper-based yield `ln`, and so on. Returns `x->log(base, x)` as a fallback.
"""
function logfn end
logfn(x::LogInfo{N,10}) where {N} = log10
logfn(x::LogInfo{N,2})  where {N} = log2
logfn(x::LogInfo{N,e})  where {N} = log
logfn(x::LogInfo{N,B})  where {N,B} = x->log(B,x)

"""
    expfn(x::LogInfo)
Returns the appropriate exponential function to use in calculations involving the
logarithmic unit / quantity. For example, decibel-based units yield `exp10`,
Neper-based yield `exp`, and so on. Returns `x->(base)^x` as a fallback.
"""
function expfn end
expfn(x::LogInfo{N,10}) where {N} = exp10
expfn(x::LogInfo{N,2})  where {N} = exp2
expfn(x::LogInfo{N,e})  where {N} = exp
expfn(x::LogInfo{N,B})  where {N,B} = x->B^x

Base.rtoldefault(::Type{Level{L,S,T}}) where {L,S,T} =
    Base.rtoldefault(typeof(tolog(L,S,oneunit(T)/unwrap(S))))
Base.rtoldefault(::Type{Gain{L,T}}) where {L,T} = Base.rtoldefault(T)

Base.isapprox(x::Level, y::Level; kwargs...) = isapprox(promote(x,y)...; kwargs...)
Base.isapprox(x::T, y::T; kwargs...) where {T <: Level} = _isapprox(x, y; kwargs...)
_isapprox(x::Level{L,S,T}, y::Level{L,S,T}; atol = Level{L,S}(reflevel(x)), kwargs...) where {L,S,T} =
    isapprox(ustrip(x), ustrip(y); atol = ustrip(convert(Level{L,S}, atol)),
        kwargs...)

Base.isapprox(x::Gain, y::Gain; kwargs...) = isapprox(promote(x,y)...; kwargs...)
Base.isapprox(x::T, y::T; kwargs...) where {T <: Gain} = _isapprox(x, y; kwargs...)
_isapprox(x::Gain{L,T}, y::Gain{L,T}; atol = Gain{L}(oneunit(T)), kwargs...) where {L,T} =
    isapprox(ustrip(x), ustrip(y); atol = ustrip(convert(Gain{L,T}, atol)), kwargs...)

# For documentation generation...
struct InvalidOp end
Base.show(io::IO, ::InvalidOp) = print(io, "†")
macro _doctables(x)
    return esc(quote
        try
            $x
        catch
            Unitful.InvalidOp()
        end
    end)
end
