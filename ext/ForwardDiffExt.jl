module ForwardDiffExt
using Unitful
using ForwardDiff

function Base.convert(d::Type{ForwardDiff.Dual{T, V, N}}, q::Quantity{T2, NoDims,U}) where {T, V, N, T2, U}
    return d(uconvert(NoUnits, q))
end

end
