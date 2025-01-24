module ForwardDiffExt
using Unitful
using ForwardDiff

function Base.convert(d::Type{ForwardDiff.Dual{T, V, N}}, q::Quantity) where {T, V, N}
    if dimension(q) == NoDims
        return d(uconvert(NoUnits, q))
    else
        throw(DimensionError(NoUnits,x))
    end
end
# function convert(d::Type{ForwardDiff.Dual{T, V, N}}, q::Quantity{T,NoDims,U}) where {T, V, N, U}
#     return ForwardDiff.Dual{T, V, N}(uconvert(NoUnits, q))
# end

end
