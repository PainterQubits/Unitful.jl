v0.0.2 - Bug fixes (`[1.0m, 2.0m] ./ 3` would throw a `Unitful.DimensionError()`).
Promotion still isn't perfect, but it is hard for me to see what `@inferred`
errors are real until https://github.com/JuliaLang/julia/issues/18465 is resolved.

Made units callable for unit conversion: `u"cm"(1u"m") == 100u"cm"//1`.
Note that `Units` objects have no fields, so this is totally unambiguous.
Moreover, it provides convenient syntax for unit conversion by function chaining:
`1u"m" |> u"cm" == 100u"cm"//1`. `uconvert` will remain supported.

v0.0.1 - Initial release
