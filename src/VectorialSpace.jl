"""
```
dimensional_space{Us <: Units}(::Type{Us})
dimensional_space(units::Units)
```

Aggregates the dimensions present in the units (whether or not they cancel out).
Returns the dimensions present in the unit with a power of 1.

```jldoctest
julia> dimensional_space(u"m/km")
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}

julia> dimensional_space(u"m/s")
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),Unitful.Dimension{:Time}(1//1))}

julia> dimensional_space(u"m/s*J")
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),Unitful.Dimension{:Mass}(1//1),Unitful.Dimension{:Time}(1//1))}

julia> dimensional_space(u"m/m")
Unitful.Dimensions{()}
```
"""
function dimensional_space{Us <: Units}(::Type{Us})
    directions = Set{Dimension}()
    for u in Us.parameters[1]
        for d in typeof(dimension(u)).parameters[1]
            push!(directions, typeof(d)(1))
        end
    end
    length(directions) == 0 && return Dimensions{()}
    typeof(prod(Dimensions{(d,)}() for d in directions))
end
dimensional_space(u::Units) = dimensional_space(typeof(u))

"""
```
dimensional_matrix{Us <: Units}(::Type{Us}, dimspace::Dimensions)
dimensional_matrix{Us <: Units}(::Type{Us})
dimensional_matrix(units::Units)
```

Transforms input unit to vectorial format, where each component in the vector is
the power of a separate dimension.

Returns a matrix where each row corresponds to a direction and each column to a
unit, and the second element is a tuple of dimensions (or row-labels)

```jldoctest
julia> dimensional_matrix(u"J*m/s")
3×3 Array{Rational{Int64},2}:
  2//1  1//1   0//1
  1//1  0//1   0//1
 -2//1  0//1  -1//1
```
"""
function dimensional_matrix{Us <: Units}(::Type{Us})
    const dimspace = dimensional_space(Us)
    # return eltype
    const rtype = typeof(Dimension{:Length}(1).power)

    const ndims = length(dimspace.parameters[1])
    result = zeros(rtype, (ndims, length(Us.parameters[1])))
    length(result) == 0 && return result

    for column in 1:size(result, 2)
        const unit = Us.parameters[1][column]
        for dim in typeof(dimension(unit)).parameters[1]
            const index = findfirst(dimspace.parameters[1], typeof(dim)(1))
            @assert index ≠ 0
            result[index, column] = dim.power
        end
    end

    result
end

dimensional_matrix(u::Units) = dimensional_matrix(typeof(u))

"""
```
two_by_two_independant(matrix::Matrix)
```

Indices of a set of column vectors, with a preference towards columns that have
smaller norms, such that no two column vectors are exactly colinear.
"""
function two_by_two_independant(matrix::Matrix)
    size(matrix, 1) == 0 && return collect(1:size(matrix, 2))
    size(matrix, 2) == 0 && return collect(1:2)[2:1]
    result = Int64[1]
    for i in 2:size(matrix, 2)
        const equiv = findfirst(result) do u
            const coeff = (matrix[:, i] ⋅ matrix[:, u]) //
            (matrix[:, u] ⋅ matrix[:, u])
            all((matrix[:, i] - coeff * matrix[:, u]) .== 0)
        end
        if equiv == 0
            push!(result, i)
        elseif norm(matrix[:, equiv]) > norm(matrix[:, i])
            result[equiv] == i
        end
    end
    result
end

"""
```
independant_columns(matrix::Matrix)
```

Indices of a set of linearly independant column vectors, with a preference
towards columns that have smaller norms.
"""
function independant_columns(matrix::Matrix)
    result = two_by_two_independant(matrix)
    (length(result) == 0 || size(matrix, 1) == 0) && return result

    sort!(result, by=i->norm(matrix[:, i]))
    freaking_rational_units(x) = det(convert(typeof(x), transpose(x) * x))
    while abs(freaking_rational_units(matrix[:, result])) ≈ 0
        pop!(result)
    end
    sort!(result)
    result
end

"""
```
project_on_basis(vector::Vector, matrix::Matrix; itermax=10, tolerance=0)
```

Describe a vector using a basis which may or may not be orthogonal.
"""
function project_on_basis(vector::Vector, matrix::Matrix;
                          itermax=10, tolerance=0)
    if itermax == 0 itermax = typemax(itermax); end
    const T = promote_type(eltype(vector), eltype(matrix))
    result = zeros(typeof(one(T)/one(T)), size(matrix, 2))
    current = convert(typeof(result), copy(vector))
    for iter in 1:itermax
        for i in 1:size(matrix, 2)
            const column = vec(matrix[:, i])
            const coeff = current ⋅ column / (column ⋅ column)
            result[i] += coeff
            current -= coeff * column
        end
        (current ⋅ current) == 0 && break
        tolerance > 0 && norm(current) < tolerance && break
    end
    result, current ⋅ current
end

"""
```
simplify{Us <: Units}(::Type{Us})
simplify(u::Units)
simplify(q::Quantity)
```

Figures out an equivalent but minimal set of units for the input.


```jldoctest
julia> simplify(1u"cm")
1 cm

julia> simplify(1u"cm/m")
1//100

julia> simplify(1u"m*m*km*J/cm")
100000000000//1 J cm^2

julia> simplify(1u"m*m*km*J/cm/N")
100000000000//1 cm^3
```
"""
function simplify{Us <: Units}(::Type{Us})
    dimensions_as_matrix = dimensional_matrix(Us)
    current = vec(sum(dimensions_as_matrix, 2))
    result = Units[]
    basis_indices = independant_columns(dimensions_as_matrix)
    projection, residual = project_on_basis(
        convert(Vector{Rational{BigInt}}, current),
        dimensions_as_matrix[:, basis_indices]; tolerance=1e-50, itermax=1000)

    const units = Us.parameters[1][basis_indices]
    prod(
        Units{(unit,), dimension(unit)}()^coeff
        for (unit, coeff) in zip(units, round(Rational{Int64}, projection))
    )
end

simplify(u::Units) = simplify(typeof(u))
simplify(q::Quantity) = uconvert(simplify(unit(q)), q)
