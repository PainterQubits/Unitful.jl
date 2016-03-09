# By inlining the unit, unitless methods I don't expect a performance penalty...

# Fallback methods for unit support
# For numbers without units, return the number as is
@inline unitless(x::Number) = x
# For numbers without units, we think of the unit as multiplicative identity
@inline unit(x::Number) = one(x)

# range.jl l25
function steprange_last{T}(start::T, step, stop)
    if isa(start,AbstractFloat) || isa(step,AbstractFloat)
        throw(ArgumentError("StepRange should not be used with floating point"))
    end
    z = zero(step)
    step == z && throw(ArgumentError("step cannot be zero"))

    if stop == start
        last = stop
    else
        if (step > z) != (stop > start)
            # empty range has a special representation where stop = start-1
            # this is needed to avoid the wrap-around that can happen computing
            # start - step, which leads to a range that looks very large instead
            # of empty.
            if step > z
                last = start - oftype(stop-start,1)
            else
                last = start + oftype(stop-start,1)
            end
        else
            diff = stop - start
            if T<:Signed && (diff > zero(diff)) != (stop > start)
                # handle overflowed subtraction with unsigned rem
                if diff > zero(diff)
                    remain = -convert(T, unsigned(-diff) % step)
                else
                    remain = convert(T, unsigned(diff) % step)
                end
            else
                remain = Base.steprem(start,stop,step)
            end
            last = stop - remain
        end
    end
    last
end

# range.jl l74
unitrange_last{T<:Integer}(start::T, stop::T) =
    ifelse(stop >= start, stop, convert(T,start-oftype(stop-start,1)))
unitrange_last{T}(start::T, stop::T) =
    ifelse(stop >= start, convert(T,start+floor(stop-start)),
                          convert(T,start-oftype(stop-start,1)))

# range.jl commit 2bb94d6 l85
range(a::Real, len::Integer) =
    UnitRange{typeof(a)}(a, oftype(a, oftype(a, unitless(a)+len-1)))

# range.jl commit 2bb94d6 l116
function rat(x)
    y = unitless(x)
    a = d = 1
    b = c = 0
    m = maxintfloat(Float32)
    while abs(y) <= m
        f = trunc(Int,y)
        y -= f
        a, c = f*a + c, a
        b, d = f*b + d, b
        max(abs(a),abs(b)) <= convert(Int,m) || return c, d
        oftype(unitless(x),a)/oftype(unitless(x),b) == unitless(x) && break
        y = inv(y)
    end
    return a*unit(x), b
end

# range.jl commit 2bb94d6 l133
function colon{T<:AbstractFloat}(start::T, step::T, stop::T)
    step == zero(T) && throw(ArgumentError("range step cannot be zero"))
    start == stop && return FloatRange{T}(start,step,1,1)
    (zero(step) < step) != (start < stop) && return FloatRange{T}(start,step,0,1)

    # float range "lifting"
    r = (stop-start)/step
    n = round(r)
    lo = prevfloat((prevfloat(stop)-nextfloat(start))/n)
    hi = nextfloat((nextfloat(stop)-prevfloat(start))/n)
    if lo <= step <= hi
        a0, b = rat(start)
        a = convert(T,a0)
        if a/convert(T,b) == unitless(start)
            c0, d = rat(step)
            c = convert(T,c0)
            if c/convert(T,d) == unitless(step)
                e = lcm(b,d)
                a *= div(e,b)
                c *= div(e,d)
                eT = convert(T,e)
                if (a+n*c)/eT == unitless(stop)
                    return FloatRange{T}(a, c, n+1, eT)
                end
            end
        end
    end
    FloatRange{T}(start, step, floor(r)+1, one(step))
end

# range.jl l166
colon{T<:AbstractFloat}(a::T, b::T) = colon(a, oftype(a,1), b)

# range.jl l169
range(a::AbstractFloat, len::Integer) = FloatRange(a,oftype(a,1),len,oftype(a,1))
range(a::AbstractFloat, st::AbstractFloat, len::Integer) = FloatRange(a,st,len,oftype(a,1))
range(a::Real, st::AbstractFloat, len::Integer) = FloatRange(float(a), st, len, oftype(st,1))
range(a::AbstractFloat, st::Real, len::Integer) = FloatRange(a, float(st), len, oftype(a,1))

# range.jl commit 2bb94d6 l183
function linspace{T<:AbstractFloat}(start::T, stop::T, len::T)
    len == round(len) || throw(InexactError())
    zero(len) <= len || error("linspace($start, $stop, $len): negative length")
    if len == zero(len)
        n = unitless(convert(T, 2))
        if isinf(n*start) || isinf(n*stop)
            start /= n; stop /= n; n = T(1)
        end
        return LinSpace(-start, -stop, -T(1), n)
    end
    if unitless(len) == 1
        start == stop || error("linspace($start, $stop, $len): endpoints differ")
        return LinSpace(-start, -start, zero(T), T(1))
    end
    n = convert(T, unitless(len) - 1)
    len - n == T(1) || error("linspace($start, $stop, $len): too long for $T")
    a0, b = rat(start)
    a = convert(T,a0)
    if a/convert(T,b) == unitless(start)
        c0, d = rat(stop)
        c = convert(T,c0)
        if c/convert(T,d) == unitless(stop)
            e = lcm(b,d)
            a *= div(e,b)
            c *= div(e,d)
            s = convert(T,n*e)
            if isinf(a*n) || isinf(c*n)
                s, p = frexp(s)
                p2 = oftype(unitless(s),2)^p
                a /= p2; c /= p2
            end
            if a*n/s == start && c*n/s == stop
                return LinSpace(a, c, len, s)
            end
        end
    end
    a, c, s = start, stop, n
    if isinf(a*n) || isinf(c*n)
        s, p = frexp(s)
        p2 = oftype(unitless(s),2)^p
        a /= p2; c /= p2
    end
    if a*n/s == start && c*n/s == stop
        return LinSpace(a, c, len, s)
    end
    return LinSpace(start, stop, len, n)
end

# range.jl commit 2bb94d6 l230
function linspace{T<:AbstractFloat}(start::T, stop::T, len::Real)
    T_len = convert(T, len)
    unitless(T_len) == len || throw(InexactError())
    linspace(start, stop, T_len)
end

# range.jl commit 2bb94d6 l315
step(r::UnitRange) = oftype(r.start, 1)

# range.jl commit 2bb94d6 l316
step(r::FloatRange) = r.step / unitless(r.divisor)

# range.jl commit 2bb94d6 l317
step{T}(r::LinSpace{T}) = ifelse(r.len <= zero(r.len), convert(T, NaN),
    (r.stop-r.start) / unitless(r.divisor))

# range.jl commit 2bb94d6 l323
length(r::UnitRange)  = Integer(unitless(r.stop - r.start) + 1)
length(r::FloatRange) = Integer(unitless(r.len))
length(r::LinSpace)   = Integer(unitless(r.len) + signbit(unitless(r.len) - 1))

# range.jl commit 2bb94d6 l360
first{T}(r::LinSpace{T}) = convert(T, (unitless(r.len)-1)*r.start/r.divisor)

# range.jl commit 2bb94d6 l364
last{T}(r::FloatRange{T}) = convert(T, (r.start + (unitless(r.len) - 1)*r.step)/r.divisor)

# range.jl commit 2bb94d6 l365
last{T}(r::LinSpace{T}) = convert(T, (unitless(r.len) - 1)*r.stop/r.divisor)

# range.jl commit 2bb94d6 l388
next{T}(r::LinSpace{T}, i::Int) =
    (convert(T, ((unitless(r.len)-i)*r.start + (i-1)*r.stop)/r.divisor), i+1)
#
# # range.jl l397
start{T}(r::UnitRange{T}) = oftype(r.start + T(1), r.start)
next{T}(r::UnitRange{T}, i) = (convert(T, i), i + T(1))
done{T}(r::UnitRange{T}, i) = i == oftype(i, r.stop) + T(1)

function show(io::IO, z::Complex)
    if unitless(z) != z
        print(io, "(")
    end
    r, i = reim(unitless(z))
    compact = limit_output(io)
    Base.showcompact_lim(io, r)
    if signbit(i) && !isnan(i)
        i = -i
        print(io, compact ? "-" : " - ")
    else
        print(io, compact ? "+" : " + ")
    end
    Base.showcompact_lim(io, i)
    if !(isa(i,Integer) && !isa(i,Bool) || isa(i,AbstractFloat) && isfinite(i))
        print(io, "*")
    end
    print(io, "im")
    if unitless(z) != z
        print(io, ") ")
        print(io, unit(z))
    end
end

if VERSION >= v"0.5.0-dev+2562"
    # range.jl commit c8995d1 l433
    function getindex{T}(r::LinSpace{T}, i::Integer)
        Base.@_inline_meta
        @boundscheck checkbounds(r, i);
        convert(T, ((unitless(r.len)-i)*r.start + (i-1)*r.stop)/r.divisor)
    end

    # range.jl commit c8995d1 l441
    function getindex{T<:Integer}(r::UnitRange, s::UnitRange{T})
        Base.@_inline_meta
        @boundscheck checkbounds(r, s)
        st = oftype(r.start, r.start + oftype(r.start, s.start - oftype(s.start,1)))
        range(st, length(s))
    end

    # range.jl commit c8995d1 l448
    function getindex{T<:Integer}(r::UnitRange, s::StepRange{T})
        Base.@_inline_meta
        @boundscheck checkbounds(r, s)
        st = oftype(r.start, r.start + oftype(r.start, s.start - oftype(s.start,1)))
        range(st, oftype(r.start, step(s)), length(s))
    end

    # range.jl commit c8995d1 l468
    function getindex{T}(r::LinSpace{T}, s::OrdinalRange)
        Base.@_inline_meta
        @boundscheck checkbounds(r, s)
        sl::T = length(s)
        ifirst = first(s)
        ilast = last(s)
        vfirst::T = ((unitless(r.len) - ifirst) * r.start + (ifirst - 1) * r.stop) / r.divisor
        vlast::T = ((unitless(r.len) - ilast) * r.start + (ilast - 1) * r.stop) / r.divisor
        return linspace(vfirst, vlast, sl)
    end
else
    ### Below makes the code work with older versions of 0.5-dev

    # range.jl commit 2bb94d6 l426
    unsafe_getindex{T}(r::LinSpace{T}, i::Integer) =
        convert(T, ((unitless(r.len)-i)*r.start + (i-1)*r.stop)/r.divisor)

    # range.jl commit 2bb94d6 l432
    function unsafe_getindex{T<:Integer}(r::UnitRange, s::UnitRange{T})
        st = oftype(r.start, r.start + oftype(r.start, s.start - oftype(s.start,1)))
        range(st, length(s))
    end

    # range.jl commit 2bb94d6 l438
    function unsafe_getindex{T<:Integer}(r::UnitRange, s::StepRange{T})
        st = oftype(r.start, r.start + oftype(r.start, s.start - oftype(s.start,1)))
        range(st, oftype(r.start, step(s)), length(s))
    end
    # range.jl commit 2bb94d6 l455
    function unsafe_getindex{T}(r::LinSpace{T}, s::OrdinalRange)
        sl::T = length(s)
        ifirst = first(s)
        ilast = last(s)
        vfirst::T = ((length(r) - ifirst) * r.start + (ifirst - 1) * r.stop) / r.divisor
        vlast::T = ((length(r) - ilast) * r.start + (ilast - 1) * r.stop) / r.divisor
        return linspace(vfirst, vlast, sl)
    end
end
