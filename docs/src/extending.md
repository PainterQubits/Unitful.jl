# Extending Unitful

## Making your own units package

New units or dimensions can be defined from the Julia REPL or from within
other packages. To avoid duplication of code and effort, it is advised to put
new unit definitions into a Julia package that is then published for others to
use. For an example of how to do this, examine the code in
[`UnitfulUS.jl`](https://github.com/ajkeller34/UnitfulUS.jl), which defines
U.S. customary units. It's actually very easy! Just make sure you read the
cautionary notes below.

If you make a units package for Unitful, please submit a pull request so that
I can provide a link from Unitful's README!

## Some limitations

### Precompilation

When creating new units in a precompiled package that need to persist into
run-time (usually true), it is important that the following or something very
similar make it into your code:

```jl
const localunits = Unitful.basefactors
const localpromotion = Unitful.promotion # only if you've used @dimension
function __init__()
    merge!(Unitful.basefactors, localunits)
    merge!(Unitful.promotion, localpromotion) # only if you've used @dimension
end
```

The definition of `localunits` (`localpromotion`) must happen
*after all new units (dimensions) have been defined*.

The problem is that the [`@unit`](@ref) macro needs to add some information to
a dictionary defined in Unitful, regardless of where the macro is executed
(the use of this dictionary does not lead to run-time penalties, if you were
wondering). However, because Unitful is precompiled, changes made to it from
another module at compile-time will not persist.

The `const localunits = Unitful.basefactors` line makes a copy of the
compile-time-modified dictionary, which can be precompiled into the module where
this code appears, and then the dictionary is merged into Unitful's dictionary
at runtime.

If you'd like, you can also consider adding a call to [`Unitful.register`](@ref)
in your `__init__` function, which will make your units accessible using
Unitful's [`@u_str`](@ref) macro. Your unit symbols should ideally be distinctive
to avoid colliding with symbols defined in other packages or in Unitful. If
there is a collision, the [`@u_str`](@ref) macro will still work, but it will
use the unit found in whichever package was registered most recently, and it will
omit a warning every time.

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
