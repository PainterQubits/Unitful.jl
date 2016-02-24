# By inlining the unit, unitless methods I don't expect a performance penalty...
@inline unitless(x) = x
@inline unit(x) = one(x)

# We override the `rat` function in Base, which is not exported.
# We allow ourselves to be a little sloppy and strip units.
# Probably for unitful quantities, units should be on the first member of the
# output tuple, if we're entirely consistent. It is however much more convenient
# to have this act the same way for unitful and unitless quantities.

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
    return a, b
end

# range.jl commit 2bb94d6 l85
range(a::Real, len::Integer) =
    UnitRange{typeof(a)}(a, oftype(a, oftype(a, unitless(a)+len-1)))

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
@generated function step(r::UnitRange)
    v = 1*unit(r.parameters[1])
    :($v)
end

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
