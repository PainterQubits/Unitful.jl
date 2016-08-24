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
*(::Unitful.Unitlike, ::Unitful.Unitlike...)
```
