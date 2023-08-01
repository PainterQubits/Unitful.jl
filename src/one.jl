# Multiplication with u"One" is identity for all unitful numbers (but not for unitless)

*(q::AbstractQuantity, ::Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}) = q
function *(
    a::AbstractQuantity, b::T
) where {
    T<:AbstractQuantity{<:Number,NoDims,<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}}
}
    return a * b.val
end
function *(
    b::T, a::AbstractQuantity
) where {
    T<:AbstractQuantity{<:Number,NoDims,<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}}
}
    return b.val * a
end
