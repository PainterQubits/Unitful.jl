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
    length(directions) == 0 && return Dimension[]
    collect(Dimension,
		typeof(prod(Dimensions{(d,)}() for d in directions)).parameters[1])
end
dimensional_space(u::Units) = dimensional_space(typeof(u))

"""
```
dimensional_space(units::Vararg{Units})
```

```jldoctest
julia> dimensional_space(u"m/km", u"m")
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}

julia> dimensional_space(u"m", u"s")
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),Unitful.Dimension{:Time}(1//1))}
```
"""
function dimensional_space(args::Vararg{Units})
	directions = Set{Dimension}()
	for u in args
		for param in typeof(u).parameters[1]
			for d in typeof(dimension(param)).parameters[1]
				push!(directions, typeof(d)(1))
			end
		end
    end
	length(directions) == 0 && return Dimensions{()}
	collect(Dimension,
		typeof(prod(Dimensions{(d,)}() for d in directions)).parameters[1])
end

"""
```
dimensional_vector(unit::Unit, dspace::Vector{Dimension})
```

Transforms the input unit into a vector in the space of dimensions.
"""
function dimensional_vector(unit::Unit, dspace::Vector{Dimension})
	const rtype = typeof(Dimension{:Length}(1).power)
	const ndims = length(dspace)
	result = zeros(rtype, ndims)
	length(result) == 0 && return result

	for dim in typeof(dimension(unit)).parameters[1]
		const index = findfirst(dspace, typeof(dim)(1))
		index ≠ 0 || error("$dim not found in input dimensional space")
		result[index] = dim.power
	end
	result
end
dimensional_vector{Us <: Units}(::Type{Us}, dspace::Vector{Dimension}) =
	sum(dimensional_vector(u, dspace) for u in Us.parameters[1])

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
dimensional_matrix{Us <: Units}(::Type{Us}, dspace::Vector{Dimension}) =
	dimensional_matrix(collect(Unit, Us.parameters[1]), dspace)

dimensional_matrix{Us <: Units}(::Type{Us}) =	
	dimensional_matrix(Us, dimensional_space(Us))
dimensional_matrix(u::Units) = dimensional_matrix(typeof(u))

function dimensional_matrix(units::Vector{Unit}, dspace::Vector{Dimension})
	length(units) == 0 && return Matrix{typeof(Dimension{:Length}(1).power)}()
	hcat(collect(dimensional_vector(u, dspace) for u in units)...)
end
function dimensional_matrix(units::Vector{Units}, dspace::Vector{Dimension})
	length(units) == 0 && return Matrix{typeof(Dimension{:Length}(1).power)}()
	hcat(collect(dimensional_matrix(typeof(u), dspace) for u in units)...)
end

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
function independant_columns(matrix::Matrix; dosort=true)
    result = two_by_two_independant(matrix)
    (length(result) == 0 || size(matrix, 1) == 0) && return result

    dosort && sort!(result, by=i->norm(matrix[:, i]))
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

""" Private implementation function for simplify """
function simplify_impl{Us <: Units}(::Type{Us}, asmatrix::Matrix,
                                    dspace::Vector{Dimension},
                                    uspace::Vector{Unit})
    current = dimensional_vector(Us, dspace)
    result = Units[]
    const basis_indices = independant_columns(asmatrix, dosort=false)
    const projection, residual = project_on_basis(
        convert(Vector{Rational{BigInt}}, current),
        asmatrix[:, basis_indices]; tolerance=1e-50, itermax=1000)

	const units = uspace[basis_indices]
    prod(
        Units{(unit,), dimension(unit)}()^coeff
        for (unit, coeff) in zip(units, round(Rational{Int64}, projection))
    )
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
	const dspace = dimensional_space(Us)
	const matrix = dimensional_matrix(Us, dspace)
    const indices = sort(1:size(matrix, 2), by=i->norm(matrix[:, i]))
	simplify_impl(Us, matrix[:, indices], dspace,
                  collect(Unit, Us.parameters[1])[indices])
end
function simplify{Us <: Units}(::Type{Us}, preferred::Vector{Units})
	const dspace = dimensional_space(Us(), preferred...)
	const matrix_Us = dimensional_matrix(Us, dspace)
	const indices = sort(1:size(matrix_Us, 2), by=i->norm(matrix_Us[:, i]))
	const matrix = hcat(dimensional_matrix(preferred, dspace), matrix_Us)
    const uspace = vcat(
        (collect(Unit, typeof(u).parameters[1]) for u in preferred)...,
		collect(Unit, Us.parameters[1])[indices]
    )
    simplify_impl(Us, matrix, dspace, uspace)
end


simplify{Us <: Units}(::Type{Us}, preferred::Tuple) =
	simplify(Us, collect(Units, preferred))
simplify(u::Units, args...) = simplify(typeof(u), args...)
simplify(q::Quantity, args...) = uconvert(simplify(unit(q), args...), q)
