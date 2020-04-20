By default, exponents on units or dimensions are indicated using Unicode superscripts on
macOS and without superscripts on other operating systems. You can set the environment
variable `UNITFUL_FANCY_EXPONENTS` to either `true` or `false` to force using or not using
the exponents.

```@docs
Unitful.abbr
Unitful.prefix
Unitful.show(::IO, ::Quantity)
Unitful.show(::IO, ::Unitful.Unitlike)
Unitful.showrep(::IO,::Unitful.Unit)
Unitful.showrep(::IO,::Unitful.Dimension)
Unitful.superscript
```
