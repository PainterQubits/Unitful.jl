@inline isunitless(::Units) = false
@inline isunitless(::Units{()}) = true

@inline numtype(::AbstractQuantity{T}) where {T} = T
@inline numtype(::Type{Q}) where {T, Q<:AbstractQuantity{T}} = T

@inline dimtype(u::Unit{U,D}) where {U,D} = D

"""
    ustrip(u::Units, x::Quantity)
    ustrip(T::Type, u::Units, x::Quantity)

Convert `x` to units `u` using [`uconvert`](@ref) and return the number out the
front of the resulting quantity. If `T` is supplied, also `convert` the
resulting number into type `T`.

This function is mainly intended for compatibility with packages that don't know
how to handle quantities.

```jldoctest
julia> ustrip(u"m", 1u"mm") == 1//1000
true

julia> ustrip(Float64, u"m", 2u"mm") == 0.002
true
```

`ustrip` supports `InverseFunctions.inverse`:

```jldoctest
julia> using InverseFunctions: inverse

julia> inverse(Base.Fix1(ustrip, u"m"))(5)
5 m
```
"""
@inline ustrip(u::Units, x) = ustrip(uconvert(u, x))
@inline ustrip(T::Type, u::Units, x) = convert(T, ustrip(u, x))

"""
    ustrip(x::Number)
    ustrip(x::Quantity)

Returns the number out in front of any units. The value of `x` may differ from the number
out front of the units in the case of dimensionless quantities, e.g. `1m/mm != 1`. See
[`uconvert`](@ref) and the example below. Because the units are removed, information may be
lost and this should be used with some care — see `ustrip(u,x)` for a safer alternative.

```jldoctest
julia> ustrip(2u"μm/m") == 2
true

julia> uconvert(NoUnits, 2u"μm/m") == 2//1000000
true
```
"""
@inline ustrip(x::Number) = x / unit(x)
@inline ustrip(x::Quantity) = ustrip(x.val)
@inline ustrip(x::Missing) = missing

"""
    ustrip(x::Array{Q}) where {Q <: Quantity}
Strip units from an `Array` by reinterpreting to type `T`. The resulting
`Array` is a not a copy, but rather a unit-stripped view into array `x`. Because the units
are removed, information may be lost and this should be used with some care.

This function is provided primarily for compatibility purposes; you could pass
the result to PyPlot, for example.

```jldoctest
julia> a = [1u"m", 2u"m"]
2-element Vector{Quantity{Int64, 𝐋, Unitful.FreeUnits{(m,), 𝐋, nothing}}}:
 1 m
 2 m

julia> b = ustrip(a)
2-element reinterpret(Int64, ::Vector{Quantity{Int64, 𝐋, Unitful.FreeUnits{(m,), 𝐋, nothing}}}):
 1
 2

julia> a[1] = 3u"m"; b
2-element reinterpret(Int64, ::Vector{Quantity{Int64, 𝐋, Unitful.FreeUnits{(m,), 𝐋, nothing}}}):
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
ustrip(A::Bidiagonal) = Bidiagonal(ustrip(A.dv), ustrip(A.ev), ifelse(istriu(A), :U, :L))
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
@inline unit(x::AbstractQuantity{T,D,U}) where {T,D,U} = U()
@inline unit(::Type{<:AbstractQuantity{T,D,U}}) where {T,D,U} = U()


"""
    unit(x::Number)
Returns the [`NoUnits`](@ref) object to indicate that ordinary numbers have no units. The
unit is displayed as an empty string.

Examples:

```jldoctest
julia> typeof(unit(1.0))
Unitful.FreeUnits{(), NoDims, nothing}

julia> typeof(unit(Float64))
Unitful.FreeUnits{(), NoDims, nothing}

julia> unit(1.0) == NoUnits
true
```
"""
@inline unit(x::Number) = NoUnits
@inline unit(x::Type{T}) where {T <: Number} = NoUnits
@inline unit(x::Type{Union{Missing, T}}) where T = unit(T)
@inline unit(x::Type{Missing}) = missing
@inline unit(x::Missing) = missing

"""
    absoluteunit(::Units)
    absoluteunit(::Quantity)
Given a unit or quantity, which may or may not be affine (e.g. `°C`), return the
corresponding unit on the absolute temperature scale (e.g. `K`). Passing a
[`Unitful.ContextUnits`](@ref) object will return another `ContextUnits` object with
the same promotion unit, which may be an affine unit, so take care.
"""
function absoluteunit end

absoluteunit(x::AbstractQuantity{T,D,U}) where {T,D,U} = absoluteunit(U())
absoluteunit(::FreeUnits{N,D,A}) where {N,D,A} = FreeUnits{N,D}()
absoluteunit(::ContextUnits{N,D,P,A}) where {N,D,P,A} = ContextUnits{N,D,P}()
absoluteunit(::FixedUnits{N,D,A}) where {N,D,A} = FixedUnits{N,D}()

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
@inline dimension(x::Missing) = missing
@inline dimension(x::Type{Missing}) = missing
@inline dimension(x::IsRootPowerRatio{S,T}) where {S,T} = dimension(T)
@inline dimension(x::Level) = dimension(reflevel(x))
@inline dimension(x::Type{T}) where {T<:Level} = dimension(reflevel(T))
@inline dimension(x::Gain) = NoDims
@inline dimension(x::Type{<:Gain}) = NoDims

dimension(a::MixedUnits{L}) where {L} = dimension(L) * dimension(a.units)

"""
    dimension(u::Units{U,D}) where {U,D}
Returns a [`Unitful.Dimensions`](@ref) object corresponding to the dimensions
of the units, `D`. For a dimensionless combination of units, a
`Unitful.Dimensions{()}` object is returned (`NoDims`).

Examples:

```jldoctest
julia> dimension(u"m")
𝐋

julia> typeof(dimension(u"m"))
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}

julia> dimension(u"m/km")
NoDims
```
"""
@inline dimension(u::Units{U,D}) where {U,D} = D

"""
    dimension(x::Quantity{T,D}) where {T,D}
    dimension(::Type{Quantity{T,D,U}}) where {T,D,U}
Returns a [`Unitful.Dimensions`](@ref) object `D` corresponding to the
dimensions of quantity `x`. For a dimensionless [`Unitful.Quantity`](@ref), a
`Unitful.Dimensions{()}` object is returned (`NoDims`).

Examples:

```jldoctest
julia> dimension(1.0u"m")
𝐋

julia> typeof(dimension(1.0u"m/μm"))
Unitful.Dimensions{()}
```
"""
@inline dimension(x::AbstractQuantity{T,D}) where {T,D} = D
@inline dimension(::Type{<:AbstractQuantity{T,D,U}}) where {T,D,U} = D

@deprecate(dimension(x::AbstractArray{T}) where {T<:Number}, dimension.(x))
@deprecate(dimension(x::AbstractArray{T}) where {T<:Units}, dimension.(x))

"""
    struct DimensionError <: Exception
Physical dimensions are inconsistent for the attempted operation.
"""
struct DimensionError <: Exception
    x
    y
end

"""
    WithDims(q::Quantity)
    WithDims(u::Units)
Returns a subtype of [`Unitful.Quantity`](@ref) with the dimensions constrained to the
dimension of `q` or `u`.
Useful to build unitful interfaces that don't constrain the numeric type or the unit, just the dimension of a quantity.

Examples:

```jldoctest
julia> using Unitful, Unitful.DefaultSymbols; import Unitful.hr
julia> circumference_of_square(side::WithDims(m)) = 4*side;
julia> circumference_of_square((1//2)m)  # works
2//1 m
julia> circumference_of_square((1//2)km)  # also works
2//1 km
# You can also constrain the return type. The numeric type is usually inferred automatically.
julia> kinetic_energy(mass::WithDims(kg), velocity::WithDims(m/s))::WithDims(J) = mass*velocity^2;
julia> kinetic_energy(1000kg, 100km/hr)
10000000 kg km^2 hr^-2
```

See also [`Unitful.WithUnits`](@ref).
"""
WithDims(q::Quantity)  = Quantity{T, dimension(q), U} where {T<:Real, U<:Unitlike}
WithDims(u::Units)     = Quantity{T, dimension(u), U} where {T<:Real, U<:Unitlike}

"""
    WithUnits(q::Quantity)
    WithUnits(u::Units)
Returns a subtype of [`Unitful.Quantity`](@ref) with the dimensions and units constrained to the
dimension and units of `q` or `u`.
Useful to build unitful interfaces that don't constrain the unit, but not the numeric type of a quantity.

Examples:

```jldoctest
julia> using Unitful, Unitful.DefaultSymbols; import Unitful.hr
julia> circumference_of_square(side::WithUnits(m)) = 4*side;
julia> circumference_of_square((1//2)m)  # works
2//1 m
julia> # circumference_of_square((1//2)km)  # doesn't work, constrained to exactly meters

# You can also constrain the return type. The numeric type is usually inferred automatically.
julia> kinetic_energy(mass::WithUnits(kg), velocity::WithUnits(m/s))::WithUnits(J) = mass*velocity^2 |> x->uconvert(J, x)
julia> kinetic_energy(1000kg, uconvert(m/s, 100km/hr))
62500000//81 J
```

See also [`Unitful.WithDims`](@ref).
"""
WithUnits(q::Quantity) = Quantity{T, dimension(q),   unit(q)} where {T<:Real}
WithUnits(u::Units)    = Quantity{T, dimension(u), typeof(u)} where {T<:Real}

Base.showerror(io::IO, e::DimensionError) =
    print(io, "DimensionError: $(e.x) and $(e.y) are not dimensionally compatible.");

"""
    struct AffineError <: Exception
An invalid operation was attempted with affine units / quantities.
"""
struct AffineError <: Exception
    x
end

Base.showerror(io::IO, e::AffineError) = print(io, "AffineError: $(e.x)")

fp_overflow_underflow(input, result) =
    isfinite(input) && !isfinite(result) || !iszero(input) && iszero(result)
