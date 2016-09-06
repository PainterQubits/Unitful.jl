


<a id='Why-do-unit-conversions-yield-rational-numbers-sometimes?-1'></a>

## Why do unit conversions yield rational numbers sometimes?


We use rational numbers in this package to permit exact conversions between different units where possible. As an example, one inch is exactly equal to 2.54 cm. However, in Julia, the floating-point `2.54` is not equal to `254//100`. As a consequence, `1inch != 2.54cm`, because Unitful respects exact conversions. To test for equivalence, instead use `≈` (`\approx` tab-completion).


<a id='But-I-want-a-floating-point-number...-1'></a>

### But I want a floating point number...


`float(x)` is defined for [`Unitful.Quantity`](types.md#Unitful.Quantity) types, and is forwarded to the underlying numeric type (units are not affected).


We may consider adding an option in the defaults to turn on/off use of `Rational` numbers. They permit exact conversions, but they aren't preferred as a result type in much of Julia Base (consider that `inv(2) === 0.5`, not `1//2`).


<a id='Exponentiation-1'></a>

## Exponentiation


Most operations with this package should in principle suffer little performance penalty if any at run time. An exception to this is rule is exponentiation. Since units and their powers are encoded in the type signature of a [`Unitful.Quantity`](types.md#Unitful.Quantity) object, raising a `Quantity` to some power, which is just some run-time value, necessarily results in different result types. This type instability could impact performance. Example:


```jlcon
julia> typeof((1.0u"m")^2)
Quantity{Float64, Dimensions:{𝐋^2}, Units:{m^2}}

julia> typeof((1.0u"m")^3)
Quantity{Float64, Dimensions:{𝐋^3}, Units:{m^3}}
```


Because the functions `inv` and `sqrt` are raising a `Quantity` to a fixed power (-1 and 1/2, respectively), we can use a generated function to ensure type stability in these cases. Also note that squaring a `Quantity` will be type-stable if done as `x*x` but not as `x^2`.


<a id='Other-random-problems-1'></a>

## Other random problems


If using units with some of the unsigned types... well, I'm not sure what you are doing, but you should be aware of this:


```jlcon
julia> using Unitful: m,cm

julia> uconvert(m,0x01cm)   # the user means cm, not 0x01c*m
0x001c m
```


This behavior is a consequence of [a Julia issue](https://github.com/JuliaLang/julia/issues/16356).


<a id='I-have-a-different-problem-1'></a>

## I have a different problem


Please raise an issue. This package is in development and there may be bugs. Feature requests may also be considered and pull requests are welcome.

