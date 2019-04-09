using Unitful: rad, °, 𝚽, AbstractQuantity

export atan_°,  asin_°,  acos_°,  asinh_°,  acosh_°,
       atan_rad,asin_rad,acos_rad,asinh_rad,acosh_rad

# unable to dispatch on this now that D is not of NoDims until the unit
# has been declared (in pkgdefaults.jl)
function show(io::IO, x::Quantity{T,D,typeof(°)}) where {T,D}
    show(io, x.val)
    show(io, unit(x))
    nothing
end

import Base.mod2pi
mod2pi(x::DimensionlessQuantity) = mod2pi(uconvert(NoUnits, x))
mod2pi(x::Quantity{T,𝚽,typeof(rad)}) where T = deg2rad(mod(rad2deg(x.val), 360))rad
mod2pi(x::Quantity{T,𝚽,typeof(°)}) where T = mod(x, 360°)

## For numerical accuracy, specific to the degree
# _r radian form, _d degree form
for (_r,_d) in ((:sin,:sind),(:cos,:cosd),(:tan,:tand),(:sec,:secd),(:csc,:cscd),(:cot,:cotd))
    @eval import Base: $_r, $_d
    # calling radian form with radians
    @eval $_r(x::Quantity{T, 𝚽, typeof(rad)}) where T = $_d(rad2deg(x.val))
    # calling degree form with degrees
    @eval $_d(x::Quantity{T, 𝚽, typeof(°)}) where T = $_d(x.val)
    # calling radian form with degrees
    @eval $_r(x::Quantity{T, 𝚽, typeof(°)}) where T = $_d(x.val)
    # calling degree form with radians
    @eval $_d(x::Quantity{T, 𝚽, typeof(rad)}) where T = $_d(rad2deg(x.val))
end

import Base.cis
cis(x::Quantity{T, 𝚽, U}) where {T,U} = cos(x) + im*sin(x)

import Base: atan, asin, acos, asinh, acosh
atan(y::AbstractQuantity, x::AbstractQuantity) = atan(promote(y,x)...)
atan(y::AbstractQuantity{T,D,U}, x::AbstractQuantity{T,D,U}) where {T,D,U} = atan(y.val,x.val)
atan(y::AbstractQuantity{T,D1,U1}, x::AbstractQuantity{T,D2,U2}) where {T,D1,U1,D2,U2} =
    throw(DimensionError(x,y))
atan_rad(y,x) = atan(y,x)rad
atan_°(y,x) = rad2deg(atan(y,x))°

for _x in (:asin, :acos, :asinh, :acosh)
    _r = Symbol(_x,:_rad)
    _d = Symbol(_x,:_°)
    @eval $_r(x) = $_x(x)rad
    @eval $_d(x) = rad2deg($_x(x))°
end

angle(x::AbstractQuantity{<:Complex}) = angle(x.val)rad

import Base.*
*(x::Quantity{S,𝚽,typeof(rad)}, y::Quantity{T,𝐋,U}) where {S,T,U} = x.val*y
*(x::Quantity{S,𝐋,U}, y::Quantity{T,𝚽,typeof(rad)}) where {S,T,U} = y.val*x
