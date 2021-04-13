using LinearAlgebra

# This function is re-defined during testing, to check we hit the fast path:
linearalgebra_count() = nothing

function LinearAlgebra.mul!(C::StridedVecOrMat{<:AbstractQuantity{T}}, 
        A::StridedMatrix{<:AbstractQuantity{T}}, 
        B::StridedVecOrMat{<:AbstractQuantity{T}},
        alpha::Bool, beta::Bool) where {T<:Base.HWNumber}
    # This is exactly how A * B creates C = similar(B, T, ...)
    eltype(C) == Base.promote_op(LinearAlgebra.matprod, eltype(A), eltype(B)) || error("bad eltypes")
    C0 = ustrip(C)
    A0 = ustrip(A)
    B0 = ustrip(B)
    mul!(C0, A0, B0)
    linearalgebra_count()
    return C
end

function LinearAlgebra.mul!(C::StridedVecOrMat{<:AbstractQuantity{T}}, 
        A::LinearAlgebra.AdjOrTransAbsMat{<:AbstractQuantity{T}, <:StridedMatrix}, 
        B::StridedVecOrMat{<:AbstractQuantity{T}},
        alpha::Bool, beta::Bool) where {T<:Base.HWNumber}

    eltype(C) == Base.promote_op(LinearAlgebra.matprod, eltype(A), eltype(B)) || error("bad eltypes")
    C0 = ustrip(C)
    A0 = A isa Adjoint ? adjoint(ustrip(parent(A))) : transpose(ustrip(parent(A)))
    B0 = ustrip(B)
    mul!(C0, A0, B0)
    linearalgebra_count()
    return C
end

function LinearAlgebra.dot(A::StridedArray{<:AbstractQuantity{T}}, 
                           B::StridedArray{<:AbstractQuantity{T}}) where {T<:Base.HWNumber}
    A0 = ustrip(A)
    B0 = ustrip(B)
    C0 = dot(A0, B0)
    linearalgebra_count()
    C = C0 * oneunit(eltype(A)) * oneunit(eltype(B))  # surely there is an official way
    return C
end
