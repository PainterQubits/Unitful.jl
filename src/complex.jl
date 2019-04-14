# This file is meant to provide all the methods in
# https://github.com/JuliaLang/julia/blob/master/base/complex.jl that
# are defined for Real or Complex numbers, just for
# AbstractQuantities{T,D,U} where T is Real or Complex, respectively.
#
# It is currently incomplete.

Base.complex(z::AbstractQuantity{T,D,U}) where {T<:Complex,D,U} = z
function Base.complex(x::Quantity{T,D,U}, y = zero(real)) where {
    T<:Real,D,U
}
    r, i = promote(x, y)
    return Quantity{complex(T),D,U}(complex(ustrip(r), ustrip(i)))
end

# implement Base.widen for real and complex quantities because Unitful
# does not have an implementation for widen yet
Base.widen(::Type{Quantity{T,D,U}}) where {T,D,U} =
    Quantity{widen(T),D,U}

# skip Base.float because it is already implemented

#Base.real(z::Quantity{T,D,U}) where {T<:Complex,D,U} =
#    Quantity{T,D,U}(real(ustrip(z)))

#Base.imag(z::Quantity{T,D,U}) where {T<:Complex,D,U} =
#    Quantity{T,D,U}(imag(ustrip(z)))

Base.reim(z::Quantity{T,D,U}) where {T<:Complex,D,U} =
    Quantity{T,D,U}(reim(ustrip(z)))

# Base.real for types has a general implementation in julia; a faster
# method could be provided but is not strictly required.

# Base.isreal, etc., are already implemented in Unitful.

# Base.flipsign is already implemented in Unitful.

# To Do: Check if Base.show, Base.read, Base.write, etc. need any
#        attention

# ...
