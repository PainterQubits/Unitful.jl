```@meta
DocTestSetup = quote
    using Unitful
end
```

```@docs
Unitful.@u_str
Unitful.unit
Unitful.dimension(::Number)
Unitful.dimension{N}(::Unitful.Units{N})
Unitful.dimension{T,D,U}(x::Quantity{T,D,U})
Unitful.dimension{T<:Unitful.Units}(x::AbstractArray{T})
Unitful.dimension{T<:AbstractQuantity}(x::AbstractArray{T})
*(::Unitful.Unitlike, ::Unitful.Unitlike...)
```
