```@meta
DocTestSetup = quote
    using Unitful
end
```
# Troubleshooting

## Why do unit conversions yield rational numbers sometimes?

We use rational numbers in this package to permit exact conversions
between different units where possible. As an example, one inch is exactly equal
to 2.54 cm. However, in Julia, the floating-point `2.54` is not equal to
`254//100`. As a consequence, `1inch != 2.54cm`, because Unitful respects exact
conversions. To test for equivalence, instead use `≈` (`\approx`
tab-completion).

### But I want a floating point number...

`float(x)` is defined for [`Unitful.Quantity`](@ref) types,
and is forwarded to the underlying numeric type (units are not affected).

We may consider adding an option in the defaults to turn on/off use of `Rational`
numbers. They permit exact conversions, but they aren't preferred as a result
type in much of Julia Base (consider that `inv(2) === 0.5`, not `1//2`).

## Exponentiation

Most operations with this package should in principle suffer little performance
penalty if any at run time. An exception to this is rule is exponentiation.
Since units and their powers are encoded in the type signature of a
[`Unitful.Quantity`](@ref) object, raising a `Quantity` to some power, which is
just some run-time value, necessarily results in different result types.
This type instability could impact performance:

```jldoctest
julia> square(x) = (p = 2; x^p)
square (generic function with 1 method)
```

In Julia, constant literal integers are lowered specially for exponentiation.
(See Julia PR [#20530](https://github.com/JuliaLang/julia/pull/20530) for details.)
In this case, type stability can be maintained:

```jldoctest
julia> square(x) = x^2
square (generic function with 1 method)
```

Because the functions `inv`, `sqrt`, and `cbrt` are raising a `Quantity` to a fixed
power (-1, 1/2, and 1/3, respectively), we can use a generated function to ensure
type stability in these cases. Also note that squaring a `Quantity` can be
type-stable if done as `x*x`.

## Promotion with dimensionless numbers

Most of the time, you are only permitted to do sensible operations in Unitful.
With dimensionless numbers, some of the safe logic breaks down. Consider for
instance that `μm/m` and `rad` are both dimensionless units, but kind of have
nothing to do with each other. It would be a little weird to add them. Nonetheless,
we permit this to happen since they have the same dimensions. Otherwise, we
would have to special-case operations for two dimensionless quantities rather
than dispatching on the empty dimension.

The result of addition and subtraction with dimensionless but unitful numbers
is always a pure number with no units. With angles, `1 rad` is essentially just
`1`, giving sane behavior:

```jldoctest
julia> π/2*u"rad"+90u"°"
3.141592653589793
```

## Broken display of dimension characters in the REPL

On some terminals with some fonts, dimension characters such as `𝐌` are displayed as an
empty box. Setting a wider font spacing in your terminal settings can solve this problem.

## I have a different problem

Please raise an issue. This package is in development and there may be bugs.
Feature requests may also be considered and pull requests are welcome.
