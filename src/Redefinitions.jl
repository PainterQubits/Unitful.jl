# # range.jl release-0.4 l346
# start{T,U}(r::UnitRange{Quantity{T,U}})  = oftype(r.start+one(r.start),r.start)
# # range.jl release-0.4 l347
# next{T,U}(r::UnitRange{Quantity{T,U}}, i) = (convert(Quantity{T,U}, i), i+one(i))
# # range.jl release-0.4 l348
# done{T,U}(r::UnitRange{Quantity{T,U}}, i) = i == oftype(i, r.stop) + one(r.stop)

# range.jl release-0.4 l271; commit 2bb94d6 l323
length(r::UnitRange) = Integer(r.stop - r.start) + 1

# range.jl release-0.4 l84; commit 2bb94d6 l85
range(a::Real, len::Integer) =
    UnitRange{typeof(a)}(a, oftype(a, a + oftype(a, len-1)))

# range.jl commit 2bb94d6 l432
function unsafe_getindex{T<:Integer}(r::UnitRange, s::UnitRange{T})
    st = oftype(r.start, r.start + oftype(r.start, s.start - oftype(s.start,1)))
    range(st, length(s))
end

# range.jl commit 2bb94d6 l438
function unsafe_getindex{T<:Integer}(r::UnitRange, s::StepRange{T})
    st = oftype(r.start, r.start + oftype(r.start, s.start - oftype(s.start,1)))
    range(st, oftype(r.start, step(s)), length(s))
end
