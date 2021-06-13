# How units are displayed

By default, exponents on units or dimensions are indicated using Unicode superscripts on
all operating systems. You can set the environment
variable `UNITFUL_FANCY_EXPONENTS` to either `true` or `false` to force using or not using
the exponents. You can also set the `:fancy_exponent` IO context property to either `true`
or `false` to force using or not using the exponents.

```@docs
Unitfu.BracketStyle
Unitfu.abbr
Unitfu.prefix
Unitfu.show(::IO, ::Quantity)
Unitfu.show(::IO, ::Unitfu.Unitlike)
Unitfu.showrep
Unitfu.showval
Unitfu.superscript
```
