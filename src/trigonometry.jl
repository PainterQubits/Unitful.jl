# now that D is 𝚽 and not of NoDims we have to define show here 
# because we to dispatch on typeof(°) has been declared (in pkgdefaults.jl)
function show(io::IO, x::Quantity{T,D,typeof(°)}) where {T,D}
    show(io, x.val)
    show(io, unit(x))
    nothing
end

import Base.mod2pi
mod2pi(x::DimensionlessQuantity) = mod2pi(uconvert(NoUnits, x))
mod2pi(x::Quantity{T,𝚽,typeof(°)}) where T = mod(x, 360°)
mod2pi(x::Quantity{T,𝚽,typeof(rad)}) where T = mod2pi(x.val)rad

## For numerical accuracy, specific to the degree
# _r radian form, _d degree form
for (_r,_d) in ((:sin,:sind),(:cos,:cosd),(:tan,:tand)
               ,(:csc,:cscd),(:sec,:secd),(:cot,:cotd)
               )
    # calling radian form with radians
    @eval $_r(x::Quantity{T, 𝚽, typeof(rad)}) where T = $_d(rad2deg(x.val))
    # calling degree form with degrees
    @eval $_d(x::Quantity{T, 𝚽, typeof(°)}) where T = $_d(x.val)
    # calling radian form with degrees
    @eval $_r(x::Quantity{T, 𝚽, typeof(°)}) where T = $_d(x.val)
    # calling degree form with radians
    @eval $_d(x::Quantity{T, 𝚽, typeof(rad)}) where T = $_d(rad2deg(x.val))
end

cis(x::Quantity{T, 𝚽, U}) where {T,U} = cos(x) + im*sin(x)

# these cannot be exported but can be called like
# julia> using Unitful
#
# julia> u = Unitful
#
# julia> u.atan(0.5)
# 0.5235987755982989 rad
#
# julia> u.asind(0.5)
# 30.000000000000004°
atan(y::Number,x::Number) = Base.atan(y,x)rad
atan(y::AbstractQuantity{T,D,U}, x::AbstractQuantity{T,D,U}) where {T,D,U} = Base.atan(y.val,x.val)rad
atan(y::AbstractQuantity, x::AbstractQuantity) = atan(promote(y,x)...)
atan(y::AbstractQuantity{T,D1,U1}, x::AbstractQuantity{T,D2,U2}) where {T,D1,U1,D2,U2} =
    throw(DimensionError(x,y))

atand(y::Number,x::Number) = Base.atand(y,x)°
atand(y::AbstractQuantity{T,D,U}, x::AbstractQuantity{T,D,U}) where {T,D,U} = Base.atand(y.val,x.val)°
atand(y::AbstractQuantity, x::AbstractQuantity) = atand(promote(y,x)...)
atand(y::AbstractQuantity{T,D1,U1}, x::AbstractQuantity{T,D2,U2}) where {T,D1,U1,D2,U2} =
    throw(DimensionError(x,y))

# these cannot be exported but can be called like
# julia> using Unitful
#
# julia> u = Unitful
#
# julia> u.asin(0.5)
# 0.5235987755982989 rad
#
# julia> u.asind(0.5)
# 30.000000000000004°
for (_r,_d) in ((:asin,:asind),(:acos,:acosd),(:atan,:atand)
               ,(:acsc,:acscd),(:asec,:asecd),(:acot,:acotd)
               )
    @eval $_r(x::Number) = Base.$_r(x)rad
    @eval $_d(x::Number) = Base.$_d(x)°
end

angle(x::AbstractQuantity{<:Complex}) = angle(x.val)rad

import Base.*
*(x::Quantity{S,𝚽,typeof(rad)}, y::Quantity{T,𝐋,U}) where {S,T,U} = x.val*y
*(x::Quantity{S,𝐋,U}, y::Quantity{T,𝚽,typeof(rad)}) where {S,T,U} = y.val*x
