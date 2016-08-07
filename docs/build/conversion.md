
<a id='Conversion-and-promotions-1'></a>

## Conversion and promotions


Conversions between units are rejected if the units have different dimensions.


We decide the result units for addition and subtraction operations based on looking at the unit types only. We can't take runtime values into account without compromising runtime performance. By default, if we have `x (A) + y (B) = z (C)` where `x,y,z` are numbers and `A,B,C` are units, then `C = max(1A, 1B)`. This is an arbitrary choice and can be changed at the end of `src/Unitful.jl` (although the package will become dirty). For example, `101cm + 1m = 2.01m` because `1m > 1cm`.


Although quantities could be integrated with Julia's promotion mechanisms, we instead simply define how to add or subtract the units themselves, and have addition of quantities rely on those definitions. The concern is that implicit promotion operations that were written with pure numbers in mind may give rise to surprising behavior without returning errors. The operations on the numeric values of quantities of course utilize Julia's promotion mechanisms.


Some of our `convert` syntax breaks Julia conventions in that the first argument is not a type. For example, `convert(ft, 1m)` converts 1 meter to feet. This may rub people the wrong way and could change. A neat alternative would be to override other syntax: `3m in cm` would be succinct and intuitive. Overriding `in` is simple, but the parsing rules aren't intended for this. For example, `0°C in °F == 32°F` fails to evaluate, but `(0°C in °F) == 32°F` returns `true`.


Exact conversions between units are respected where possible. If rational arithmetic would result in an overflow, then floating-point conversion will proceed.


<a id='Temperature-conversion-1'></a>

## Temperature conversion


If the dimension of a `Quantity` is purely temperature, then conversion respects scale offsets. For instance, converting 0°C to °F returns the expected result, 32°F. If instead temperature appears in combination with other units, scale offsets don't make sense and we consider temperature *intervals*.

