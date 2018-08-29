```@meta
DocTestSetup = quote
    using Unitful
end
```
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

julia> @code_warntype square(1.0u"m")
Variables:
  #self# <optimized out>
  x::Quantity{Float64, Dimensions:{𝐋}, Units:{m}}
  p <optimized out>

Body:
  begin
      return $(Expr(:invoke, MethodInstance for ^(::Quantity{Float64, Dimensions:{𝐋}, Units:{m}}, ::Int64), :(^), :(x), 2))
  end::ANY
```

In Julia 0.6, constant literal integers are lowered specially for exponentiation.
(See Julia PR [#20530](https://github.com/JuliaLang/julia/pull/20530) for details.)
In this case, type stability can be maintained:

```jldoctest
julia> square(x) = x^2
square (generic function with 1 method)

julia> @code_warntype square(1.0u"m")
Variables:
  #self# <optimized out>
  x::Quantity{Float64, Dimensions:{𝐋}, Units:{m}}

Body:
  begin
      $(Expr(:inbounds, false))
      # meta: location /Users/ajkeller/.julia/v0.6/Unitful/src/quantities.jl literal_pow 336
      SSAValue(0) = (Core.getfield)(x::Quantity{Float64, Dimensions:{𝐋}, Units:{m}}, :val)::Float64
      # meta: pop location
      $(Expr(:inbounds, :pop))
      return $(Expr(:new, Quantity{Float64, Dimensions:{𝐋^2}, Units:{m^2}}, :((Base.mul_float)(SSAValue(0), SSAValue(0))::Float64)))
  end::Quantity{Float64, Dimensions:{𝐋^2}, Units:{m^2}}
```

Because the functions `inv` and `sqrt` are raising a `Quantity` to a fixed
power (-1 and 1/2, respectively), we can use a generated function to ensure
type stability in these cases. Also note that squaring a `Quantity` can be
type-stable in either Julia 0.5 or 0.6 if done as `x*x`.

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

On some terminals with some fonts dimenstion characters such as 𝐌 are displayed as an empty box.
Setting a wider font spacing in your terminal settings can solve this problem.


## Other random problems

If using units with some of the unsigned types... well, I'm not sure what
you are doing, but you should be aware of this:

```jldoctest
julia> using Unitful: m,cm

julia> uconvert(m,0x01cm)   # the user means cm, not 0x01c*m
0x001c m
```

This behavior is a consequence of
[a Julia issue](https://github.com/JuliaLang/julia/issues/16356) that has recently
been fixed and will no longer be a problem in future Julia versions.

## I have a different problem

Please raise an issue. This package is in development and there may be bugs.
Feature requests may also be considered and pull requests are welcome.
