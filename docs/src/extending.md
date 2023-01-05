# Extending Unitful

## Making your own units package

New units or dimensions can be defined from the Julia REPL or from within
other packages. To avoid duplication of code and effort, it is advised to put
new unit definitions into a Julia package that is then published for others to
use. For an example of how to do this, examine the code in
[`UnitfulUS.jl`](https://github.com/PainterQubits/UnitfulUS.jl), which defines
U.S. customary units. It's actually very easy! Just make sure you read all of
the cautionary notes on this page. If you make a units package for Unitful,
please submit a pull request so that I can provide a link from Unitful's README!

## Some limitations

### Precompilation

When creating new units in a precompiled package that need to persist into
run-time (usually true), it is important that the following make it into your
code:

```julia
function __init__()
    Unitful.register(YourModule)
end
```

By calling [`Unitful.register`](@ref) in your `__init__` function, you tell
Unitful about some internal data required to make Unit conversions work and
also make your units accessible to Unitful's [`@u_str`](@ref) macro. Your unit
symbols should ideally be distinctive to avoid colliding with symbols defined
in other packages or in Unitful. If there is a collision, the [`@u_str`](@ref)
macro will still work, but it will use the unit found in whichever package was
registered most recently, and it will emit a warning every time.

If you use the `@u_str` macro with the units defined in your package, you'll
also need to call `Unitful.register()` at the top level of your package at
compile time.

In the unlikely case that you've used `@dimension`, you will also need the
following incantation:

```julia
const localpromotion = copy(Unitful.promotion)
function __init__()
    Unitful.register(YourModule)
    merge!(Unitful.promotion, localpromotion)
end
```

The definition of `localpromotion` must happen *after all new units
(dimensions) have been defined*.

### Type uniqueness

Currently, when the [`@dimension`](@ref), [`@derived_dimension`](@ref),
[`@refunit`](@ref), or [`@unit`](@ref) macros are used, some unique symbols
must be provided which are used to differentiate types in dispatch. These
are typically the names of dimensions or units (e.g. `Length`, `Meter`, etc.)
One problem that could occur is that if multiple units or dimensions are defined
with the same name, then they will be indistinguishable in dispatch and errors
will result.

I don't expect a flood of units packages to come out, so probably the likelihood
of name collision is pretty small. When defining units yourself, do take care to
use unique symbols, perhaps with the aid of `Base.gensym()` if creating units at
runtime. When making packages, look and see what symbols are used by existing
units packages to avoid trouble.

## Archaic or fictitious unit systems

In the rare event that you want to define physical units which are not
convertible to SI units, you need to do a bit of extra work. To be clear,
such a conversion should always exist, in principle. One can imagine, however,
archaic or fictitious unit systems for which a precise conversion to SI units
is unknown. For example, a [cullishigay](https://en.wikipedia.org/wiki/Cullishigay)
is one-third of a mudi, but only *approximately* 1.25 imperial bushels. There may
be cases where you don't even have an approximate conversion to imperial bushels.
At such a time, you may feel uncomfortable specifying the "base unit" of this
hypothetical unit system in terms of an SI quantity, and may want to
explicitly forbid any attempt to convert to SI units.

One can achieve this by defining new dimensions with the [`@dimension`](@ref) or
[`@derived_dimension`](@ref) macros. The trick is to define dimensions that display
suggestively like physical dimensions, like `𝐋*`, `𝐓*` etc., but are distinct as far
as Julia's type system is concerned. Then, you can use [`@refunit`](@ref) to
base units for these new dimensions without reference to SI. The result will be
that attempted conversion between the hypothetical unit system and SI will fail
with a `DimensionError`, so be sure you provide some hints in how your
new dimensions are displayed to avoid confusing users. It would be confusing
to throw a `DimensionError` when attempting to convert between lengths which are
incompatible in the sense of the previous paragraph, when both lengths display their
dimension as `𝐋`.
