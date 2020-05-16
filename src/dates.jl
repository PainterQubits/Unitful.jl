# Conversion from and to types from the `Dates` stdlib

import Dates: Week, Day, Hour, Minute, Second, Millisecond, Microsecond, Nanosecond

for (period, unit) = ((Nanosecond, ns), (Microsecond, μs), (Millisecond, ms), (Second, s),
                      (Minute, minute), (Hour, hr), (Day, d), (Week, wk))
    @eval unit(::Type{$period}) = $unit
    @eval (::Type{$period})(x::AbstractQuantity) = $period(ustrip(unit($period), x))
end

dimension(p::Dates.FixedPeriod) = dimension(typeof(p))
dimension(::Type{<:Dates.FixedPeriod}) = 𝐓

"""
    unit(x::Dates.FixedPeriod)
    unit(x::Type{<:Dates.FixedPeriod})

Return the units that correspond to a particular period.

# Examples

```julia
julia> unit(Second(15)) == u"s"
true

julia> unit(Hour) == u"hr"
true
```
"""
unit(p::Dates.FixedPeriod) = unit(typeof(p))

numtype(x::Dates.FixedPeriod) = numtype(typeof(x))
numtype(::Type{T}) where {T<:Dates.FixedPeriod} = Int64

quantitytype(::Type{T}) where {T<:Dates.FixedPeriod} =
    Quantity{numtype(T),dimension(T),typeof(unit(T))}

ustrip(p::Dates.FixedPeriod) = Dates.value(p)

Quantity(period::Dates.FixedPeriod) = Quantity(ustrip(period), unit(period))

uconvert(u::Units, period::Dates.FixedPeriod) = uconvert(u, Quantity(period))

(T::Type{<:AbstractQuantity})(period::Dates.FixedPeriod) = T(Quantity(period))

convert(T::Type{<:AbstractQuantity}, period::Dates.FixedPeriod) = T(period)
convert(T::Type{<:Dates.FixedPeriod}, x::AbstractQuantity) = T(x)

round(T::Type{<:Dates.FixedPeriod}, x::AbstractQuantity, r::RoundingMode=RoundNearest) =
    T(round(numtype(T), ustrip(unit(T), x), r))
round(u::Units, period::Dates.FixedPeriod, r::RoundingMode=RoundNearest; kwargs...) =
    round(u, Quantity(period), r; kwargs...)
round(T::Type{<:Number}, u::Units, period::Dates.FixedPeriod, r::RoundingMode=RoundNearest;
      kwargs...) = round(T, u, Quantity(period), r; kwargs...)
round(T::Type{<:AbstractQuantity}, period::Dates.FixedPeriod, r::RoundingMode=RoundNearest;
      kwargs...) = round(T, Quantity(period), r; kwargs...)

for (f, r) in ((:floor,:RoundDown), (:ceil,:RoundUp), (:trunc,:RoundToZero))
    @eval $f(T::Type{<:Dates.FixedPeriod}, x::AbstractQuantity) = round(T, x, $r)
    @eval $f(u::Units, period::Dates.FixedPeriod; kwargs...) =
        round(u, period, $r; kwargs...)
    @eval $f(T::Type{<:Number}, u::Units, period::Dates.FixedPeriod; kwargs...) =
        round(T, u, period, $r; kwargs...)
    @eval $f(T::Type{<:AbstractQuantity}, period::Dates.FixedPeriod; kwargs...) =
        round(T, period, $r; kwargs...)
end

for op = (:+, :-, :*, :/, ://, :fld, :cld, :mod, :rem, :atan,
          :(==), :isequal, :<, :isless, :≤)
    @eval $op(x::Dates.FixedPeriod, y::AbstractQuantity) = $op(Quantity(x), y)
    @eval $op(x::AbstractQuantity, y::Dates.FixedPeriod) = $op(x, Quantity(y))
end
for op = (:*, :/, ://)
    @eval $op(x::Dates.FixedPeriod, y::Units) = $op(Quantity(x), y)
    @eval $op(x::Units, y::Dates.FixedPeriod) = $op(x, Quantity(y))
end

div(x::Dates.FixedPeriod, y::AbstractQuantity, r...) = div(Quantity(x), y, r...)
div(x::AbstractQuantity, y::Dates.FixedPeriod, r...) = div(x, Quantity(y), r...)

isapprox(x::Dates.FixedPeriod, y::AbstractQuantity; kwargs...) =
    isapprox(Quantity(x), y; kwargs...)
isapprox(x::AbstractQuantity, y::Dates.FixedPeriod; kwargs...) =
    isapprox(x, Quantity(y); kwargs...)

function isapprox(x::AbstractArray{<:AbstractQuantity}, y::AbstractArray{T};
                  kwargs...) where {T<:Dates.Period}
    if isconcretetype(T)
        y′ = reinterpret(quantitytype(T), y)
    else
        y′ = Quantity.(y)
    end
    isapprox(x, y′; kwargs...)
end
isapprox(x::AbstractArray{<:Dates.Period},
         y::AbstractArray{<:AbstractQuantity}; kwargs...) =
    isapprox(y, x; kwargs...)

Base.promote_rule(::Type{Quantity{T,𝐓,U}}, ::Type{S}) where {T,U,S<:Dates.FixedPeriod} =
    promote_type(Quantity{T,𝐓,U}, quantitytype(S))
