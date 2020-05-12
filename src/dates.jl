

# Dates.FixedPeriod == Union{Day, Hour, Microsecond, Millisecond, Minute, Nanosecond, Second, Week}
Quantity(x::Dates.Nanosecond) = x.value * u"ns"
Quantity(x::Dates.Microsecond) = x.value * u"μs"
Quantity(x::Dates.Millisecond) = x.value * u"ms"
Quantity(x::Dates.Second) = x.value * u"s"
Quantity(x::Dates.Minute) = x.value * u"minute"
Quantity(x::Dates.Hour) = x.value * u"hr"
Quantity(x::Dates.Day) = x.value * u"d"
Quantity(x::Dates.Week) = x.value * u"wk"

uconvert(a::Units, x::Dates.FixedPeriod) = uconvert(a, Quantity(x))

Base.promote_rule(::Type{Quantity{T,D,U}}, ::Type{<:Dates.FixedPeriod}) where {T,D,U} =
    Quantity{promote_type(T,Int),D,U}

convert(type::Type{<:Quantity}, x::Dates.FixedPeriod) = convert(type, Quantity(x))

Base.inv(x::Dates.FixedPeriod) = inv(Quantity(x))

convert(::Type{Dates.Nanosecond}, x::Quantity) = Dates.Nanosecond(ustrip(uconvert(u"ns", x)))
convert(::Type{Dates.Microsecond}, x::Quantity) = Dates.Microsecond(ustrip(uconvert(u"μs", x)))
convert(::Type{Dates.Millisecond}, x::Quantity) = Dates.Millisecond(ustrip(uconvert(u"ms", x)))
convert(::Type{Dates.Second}, x::Quantity) = Dates.Second(ustrip(uconvert(u"s", x)))
convert(::Type{Dates.Minute}, x::Quantity) = Dates.Minute(ustrip(uconvert(u"minute", x)))
convert(::Type{Dates.Hour}, x::Quantity) = Dates.Hour(ustrip(uconvert(u"hr", x)))
convert(::Type{Dates.Day}, x::Quantity) = Dates.Day(ustrip(uconvert(u"d", x)))
convert(::Type{Dates.Week}, x::Quantity) = Dates.Week(ustrip(uconvert(u"wk", x)))
