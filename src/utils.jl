@inline isunitless(::Units) = false
@inline isunitless(::Units{()}) = true

@inline numtype(::Quantity{T}) where {T} = T
@inline numtype(::Type{Quantity{T,D,U}}) where {T,D,U} = T
@inline dimtype(u::Unit{U,D}) where {U,D} = D

"""
    ustrip(x::Number)
    ustrip(x::Quantity)
Returns the number out in front of any units. The value of `x` may differ from the number
out front of the units in the case of dimensionless quantities, e.g. `1m/mm != 1`. See
[`uconvert`](@ref) and the example below. Because the units are removed, information may be
lost and this should be used with some care.

This function is mainly intended for compatibility with packages that don't know
how to handle quantities.

```jldoctest
julia> ustrip(2u"μm/m") == 2
true

julia> uconvert(NoUnits, 2u"μm/m") == 2//1000000
true
```
"""
@inline ustrip(x::Number) = x / unit(x)
@inline ustrip(x::Quantity) = ustrip(x.val)

"""
    ustrip(x::Array{Q}) where {Q <: Quantity}
Strip units from an `Array` by reinterpreting to type `T`. The resulting
`Array` is a not a copy, but rather a unit-stripped view into array `x`. Because the units
are removed, information may be lost and this should be used with some care.

This function is provided primarily for compatibility purposes; you could pass
the result to PyPlot, for example.

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
@inline ustrip(A::Array{Q}) where {Q <: Quantity} = reinterpret(numtype(Q), A)

@deprecate(ustrip(A::AbstractArray{T}) where {T<:Number}, ustrip.(A))

"""
    ustrip(A::Diagonal)
    ustrip(A::Bidiagonal)
    ustrip(A::Tridiagonal)
    ustrip(A::SymTridiagonal)
Strip units from various kinds of matrices by calling `ustrip` on the underlying vectors.
"""
ustrip(A::Diagonal) = Diagonal(ustrip(A.diag))
@static if VERSION >= v"0.7.0-DEV.884" # PR 22703
    ustrip(A::Bidiagonal) = Bidiagonal(ustrip(A.dv), ustrip(A.ev), ifelse(istriu(A), :U, :L))
else
    ustrip(A::Bidiagonal) = Bidiagonal(ustrip(A.dv), ustrip(A.ev), istriu(A))
end
ustrip(A::Tridiagonal) = Tridiagonal(ustrip(A.dl), ustrip(A.d), ustrip(A.du))
ustrip(A::SymTridiagonal) = SymTridiagonal(ustrip(A.dv), ustrip(A.ev))

"""
    unit(x::Quantity{T,D,U}) where {T,D,U}
    unit(x::Type{Quantity{T,D,U}}) where {T,D,U}
Returns the units associated with a `Quantity` or `Quantity` type.

Examples:

```jldoctest
julia> unit(1.0u"m") == u"m"
true

julia> unit(typeof(1.0u"m")) == u"m"
true
```
"""
@inline unit(x::Quantity{T,D,U}) where {T,D,U} = U()
@inline unit(::Type{Quantity{T,D,U}}) where {T,D,U} = U()


"""
    unit(x::Number)
Returns a `Unitful.Units{(), Dimensions{()}}` object to indicate that ordinary
numbers have no units. This is a singleton, which we export as `NoUnits`.
The unit is displayed as an empty string.

Examples:

```jldoctest
julia> typeof(unit(1.0))
Unitful.FreeUnits{(),Unitful.Dimensions{()}}

julia> typeof(unit(Float64))
Unitful.FreeUnits{(),Unitful.Dimensions{()}}

julia> unit(1.0) == NoUnits
true
```
"""
@inline unit(x::Number) = NoUnits
@inline unit(x::Type{T}) where {T <: Number} = NoUnits

"""
    dimension(x::Number)
    dimension(x::Type{T}) where {T<:Number}
Returns a `Unitful.Dimensions{()}` object to indicate that ordinary
numbers are dimensionless. This is a singleton, which we export as `NoDims`.
The dimension is displayed as an empty string.

Examples:

```jldoctest
julia> typeof(dimension(1.0))
Unitful.Dimensions{()}
julia> typeof(dimension(Float64))
Unitful.Dimensions{()}
julia> dimension(1.0) == NoDims
true
```
"""
@inline dimension(x::Number) = NoDims
@inline dimension(x::Type{T}) where {T <: Number} = NoDims

"""
    dimension(u::Units{U,D}) where {U,D}
Returns a [`Unitful.Dimensions`](@ref) object corresponding to the dimensions
of the units, `D()`. For a dimensionless combination of units, a
`Unitful.Dimensions{()}` object is returned.

Examples:

```jldoctest
julia> dimension(u"m")
𝐋

julia> typeof(dimension(u"m"))
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}

julia> typeof(dimension(u"m/km"))
Unitful.Dimensions{()}
```
"""
@inline dimension(u::Units{U,D}) where {U,D} = D()

"""
    dimension(x::Quantity{T,D}) where {T,D}
    dimension(::Type{Quantity{T,D,U}}) where {T,D,U}
Returns a [`Unitful.Dimensions`](@ref) object `D()` corresponding to the
dimensions of quantity `x`. For a dimensionless [`Unitful.Quantity`](@ref), a
`Unitful.Dimensions{()}` object is returned.

Examples:

```jldoctest
julia> dimension(1.0u"m")
𝐋

julia> typeof(dimension(1.0u"m/μm"))
Unitful.Dimensions{()}
```
"""
@inline dimension(x::Quantity{T,D}) where {T,D} = D()
@inline dimension(::Type{Quantity{T,D,U}}) where {T,D,U} = D()

@deprecate(dimension(x::AbstractArray{T}) where {T<:Number}, dimension.(x))
@deprecate(dimension(x::AbstractArray{T}) where {T<:Units}, dimension.(x))

"""
    struct DimensionError <: Exception
      x
      y
    end
Thrown when dimensions don't match in an operation that demands they do.
Display `x` and `y` in error message.
"""
struct DimensionError <: Exception
    x
    y
end

Base.showerror(io::IO, e::DimensionError) =
    print(io, "DimensionError: $(e.x) and $(e.y) are not dimensionally compatible.");
