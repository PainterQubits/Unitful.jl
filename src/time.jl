"""
uconvert{T,D,U}(a::Units, x::Quantity{T,typeof(𝚯),<:Time})
In this method, we are special-casing time conversion to Julia's native
time units. The maximal time unit is days (and the smallest is nanoseconds).
"""
function uconvert(::Type{Dates.CompoundPeriod}, x::Unitful.Time)
    _nanos = ustrip(uconvert(ns, x))
    nanos = floor(Int64, _nanos)
    micros, nanos = fldmod(nanos, 1000)
    millis, micros = fldmod(micros, 1000)
    secs, millis = fldmod(millis, 1000)
    mins, secs = fldmod(secs, 60)
    hrs, mins = fldmod(mins, 60)
    dys, hrs = fldmod(hrs, 24)
    result = Dates.Nanosecond(nanos) + Dates.Microsecond(micros) +
    Dates.Millisecond(millis) + Dates.Second(secs) +
    Dates.Minute(mins) + Dates.Hour(hrs) + Dates.Day(dys)
    return result
end
