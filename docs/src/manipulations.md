```@meta
DocTestSetup = quote
    using Unitful
end
```

```@docs
Unitful.@u_str
Unitful.unit
Unitful.ustrip
Unitful.dimension(::Number)
Unitful.dimension{U,D}(::Unitful.Units{U,D})
Unitful.dimension{T,D,U}(x::Quantity{T,D,U})
Unitful.dimension{T<:Unitful.Units}(x::AbstractArray{T})
*(::Unitful.Unitlike, ::Unitful.Unitlike...)
```
