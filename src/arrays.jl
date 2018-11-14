export UnitfulArray, UnitfulVector, UnitfulMatrix

const TupleOf{T} = NTuple{N, T} where N

# Perhaps we should have U<:NTuple{N}. That way, one could use vectors of units,
# which _sounds_ bad (type-unstable), but it's just O(N) bad, compared to the
# O(N^2) or O(N^3) linear algebra operations. It would still be a win over a plain
# Matrix{Any} that stores unitful quantities.
struct UnitfulArray{T, N, A<:AbstractArray{T, N}, U<:NTuple{N, TupleOf{Units}}} <: AbstractArray{Quantity{T}, N}
    arr::A
    units::U
end
UnitfulArray(arr, units...) = UnitfulArray(arr, units)
const UnitfulVector{T} = UnitfulArray{T, 1}
const UnitfulMatrix{T} = UnitfulArray{T, 2}
UnitfulVector(arr, u1) = UnitfulArray(arr, u1)
UnitfulMatrix(arr, u1, u2) = UnitfulArray(arr, u1, u2)

row_units(ua::UnitfulMatrix) = ua.units[1]
column_units(ua::UnitfulMatrix) = ua.units[2]

Base.size(ua::UnitfulArray) = size(ua.arr)
Base.getindex(ua::UnitfulArray{T, N}, inds::Vararg{Int, N}) where {T, N} =
    ua.arr[inds...] * prod(getindex.(ua.units, inds))

""" Scale the rows of `ua` so that it has units `row_units`, or throw a DimensionError.
For the output, `row_units(ua) == desired_row_units` is true """
function uconvert_rows(desired_row_units::TupleOf{Units}, umat::UnitfulMatrix)
    if all(desired_row_units.==row_units(umat))
        # avoid the conversion factor if possible (premature optimization?)
        return umat
    end
    # broadcasting is equivalent to left-multiplication by a diagonal matrix
    # (which would be cleaner, but would involve allocating a vector, or
    # using a StaticArrays.SVector)
    # Float64 is because I get a segfault on my machine otherwise :( TODO: take out
    factors = Float64.((convfact.(desired_row_units, row_units(umat))...,))
    return UnitfulMatrix(factors .* umat.arr, desired_row_units, column_units(umat))
end

Base.:*(a::UnitfulMatrix, b::UnitfulMatrix) =
    UnitfulArray(a.arr * uconvert_rows(column_units(a).^-1, b).arr,
                 row_units(a), column_units(b))
Base.inv(ua::UnitfulMatrix) = UnitfulMatrix(inv(ua.arr), ua.units[2].^-1, ua.units[1].^-1)
Base.adjoint(ua::UnitfulMatrix) = UnitfulMatrix(adjoint(ua.arr), ua.units[2], ua.units[1])

