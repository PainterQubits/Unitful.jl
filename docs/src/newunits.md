```@meta
DocTestSetup = quote
    using Unitful
end
```
# Defining new units

!!! note
    Logarithmic units should not be used in the `@refunit` or `@unit` macros described below.
    See the section on logarithmic scales for customization help.

The package automatically generates a useful set of units and dimensions in the
`Unitful` module in `src/pkgdefaults.jl`.

If a different set of default units or dimensions is desired, macros for
generating units and dimensions are provided. To create new units
interactively, most users will be happy with the [`@unit`](@ref) macro
and the [`Unitful.register`](@ref) function, which makes units defined in a module
available to the [`@u_str`](@ref) string macro.

An example of defining units in a module:

```jldoctest
julia> module MyUnits; using Unitful; @unit myMeter "m" MyMeter 1u"m" false; end
MyUnits

julia> using Unitful

julia> u"myMeter"
ERROR: LoadError:
[...]

julia> Unitful.register(MyUnits);

julia> u"myMeter"
m
```

You could have also called `Unitful.register` inside the `MyUnits` module; the choice is
somewhat analogous to whether or not to export symbols from a module, although the symbols
are never really exported, just made available to the `@u_str` macro. If you want to make a
precompiled units package, rather than define a module at the REPL,
see [Making your own units package](@ref).

You can also define units directly in the `Main` module at the REPL:

```jldoctest
julia> using Unitful

julia> Unitful.register(@__MODULE__);

julia> @unit M "M" Molar 1u"mol/L" true;

julia> 1u"mM"
1 mM
```

A note for the experts: Some care should be taken if explicitly creating
[`Unitful.Units`](@ref) objects. The ordering of [`Unitful.Unit`](@ref) objects
inside a tuple matters for type comparisons. Using the unary multiplication
operator on the `Units` object will return a "canonically sorted" `Units` object.
Indeed, this is how we avoid ordering issues when multiplying quantities together.

## Defining units in precompiled packages

See [Precompilation](@ref).

## Useful functions and macros
```@docs
Unitful.@dimension
Unitful.@derived_dimension
Unitful.@refunit
Unitful.@unit
Unitful.@affineunit
```

## Internals
```@docs
Unitful.@prefixed_unit_symbols
Unitful.@unit_symbols
Unitful.basefactor
```
