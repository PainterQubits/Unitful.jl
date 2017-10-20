```@meta
DocTestSetup = quote
    using Unitful
end
```

Unitful provides a way to use logarithmically-scaled quantities as of v0.4.0. Some
compromises have been made in striving for logarithmic quantities to be both usable and
consistent. In the following discussion, for pedagogical purposes, we will assume prior
familiarity with the definitions of `dB` and `dBm`.

## Constructing logarithmic quantities

Left- or right-multiplying a pure number by a logarithmic "unit", whether dimensionful or
dimensionless, is short-hand for constructing a logarithmic quantity.

```jldoctest
julia> 3u"dB"
3 dB

julia> 3u"dBm"
3.0 dBm

julia> u"dB"*3 === 3u"dB"
true
```

Currently implemented are `dB`, `dBm`, `dBV`, `dBu`, `dBμV`, `dBSPL`, `Np`.

One can also construct logarithmic quantities using the `@dB` or `@Np` macros to use
an arbitrary reference level:

```jldoctest
julia> using Unitful: mW, V

julia> @dB 10mW/mW
10.0 dBm

julia> @dB 10V/V
20.0 dBV

julia> @dB 3V/4V
-2.498774732165999 dB (4 V)

julia> @Np e*V/V    # e = 2.71828...
1.0 Np (1 V)
```

In calculating the logarithms, the log function appropriate to the scale in question is used
(`log10` for decibels, `log` for nepers).

There is an important difference in these two approaches to constructing logarithmic
quantities. When we construct `3dBm`, ultimately the power in `mW` is being stored,
resulting in a lossy conversion. However,
`0 dBm`, the power in `mW` is calculated and stored, entailing a floating point
conversion. This can be avoided by constructing `0 dBm` as `@dB 1mW/mW`.

Note that logarithmic "units" can only multiply or be multiplied by pure numbers, not
other units or quantities. This is done to avoid issues with commutativity and associativity,
e.g. `3*dB*m^-1 == (3dB)/m`, but `3*m^-1*dB == (3m^-1)*dB` does not make much sense. This
is because `dB` acts more like a constructor than a proper unit. In this package and in the
documentation, we take some pains to avoid using the term "logarithmic units" where possible,
and the usage and design of this package reflects that.

### Logarithmic quantities with no reference level specified

The `@dB` and `@Np` macros will fail if either a dimensionless number or a ratio of
dimensionless numbers is used. This is because the ratio could be of power quantities or of
root-power quantities, leading to ambiguities.

Logarithmic quantities with no reference level specified typically represent some amount of
gain or attenuation, i.e. a ratio which is dimensionless. These can be constructed as,
for example, `10*dB`, which displays similarly (`10 dB`). The type of this kind of
logarithmic quantity is:

```@docs
    Unitful.Gain
```

One might expect that any dimensionless quantity should be convertible to a pure number,
that is, to `x` if you had `10*log10(x)` dB. However, it turns out that in dB, a ratio of
powers is defined as `10*log10(x)`, but a ratio of voltages or other root-power quantities
is defined as `20*log10(x)`. Clearly, converting back from decibels to a real number is
ambiguous, and so we have not implemented automatic promotion to avoid incorrect results.
You can use [`Unitful.powerratio`](@ref) to interpret a `Gain` as a ratio of power
quantities, or [`Unitful.rootpowerratio`](@ref) (equivalently `fieldratio`) to interpret
as a ratio of field quantities.

### "Dimensionful" logarithmic quantities?

In this package, quantities with units like `dBm` are considered to have the dimension of
power, even though the expression `P(dBm) = 10*log10(P/1mW)` is dimensionless and formed
from a dimensionless ratio. Practically speaking, these kinds of logarithmic quantities are
fungible whenever they share the same dimensions, so it is more convenient to adopt this
convention (people refer to `dBm/Hz` as a power spectral density, etc.) Presumably, one
would like to have `10dBm isa Unitful.Power` for dispatch too. Therefore, in the following
discussion, we will shamelessly (okay, with some shame) speak of dimensionful logarithmic
quantities, or `Level`s for short:

```@docs
    Unitful.Level
```

Finally, for completeness we note that both `Level` and `Gain` are subtypes of `LogScaled`:

```@docs
    Unitful.LogScaled
```

## Multiplication rules

Multiplying a dimensionless logarithmic quantity by a pure number acts as like it does for
linear quantities:

```jldoctest
julia> 3u"dB" * 2
6 dB

julia> 2 * 0u"dB"
0 dB
```

Justification by example: consider the example of the exponential attenuation of a signal on
a lossy transmission line. If the attenuation goes like $10^{-kx}$, then the (power)
attenuation in dB is $-10kx$. We see that the attenuation in dB is linear in length. For an
attenuation constant of 3dB/m, we better calculate 6dB for a length of 2m.

Multiplying a dimensionful logarithmic quantity by a pure number acts differently than
multiplying a gain/attenuation by a pure number. Since `0dBm == 1mW`, we better have that
`0dBm * 2 == 2mW`, implying:

```jldoctest
julia> 0u"dBm" * 2
3.010299956639812 dBm
```

Logarithmic quantities can only be multiplied by pure numbers, linear units, or quantities,
but not logarithmic "units" or quantities.  When a logarithmic quantity is multiplied by a
linear quantity, the logarithmic quantity is linearized and multiplication proceeds as
usual:

```jldoctest
julia> (0u"dBm") * (1u"W")
1.0 mW W
```

The previous example returns a floating point value because in constructing the level
`0 dBm`, the power in `mW` is calculated and stored, entailing a floating point
conversion. This can be avoided by constructing `0 dBm` as `@dB 1mW/mW`:

```jldoctest
julia> (@dB 1u"mW"/u"mW") * (1u"W")
1 mW W
```

We refer to a quantity with both logarithmic "units" and linear units as a mixed quantity.
For mixed quantities, the numeric value associates with the logarithmic unit, and the
quantity is displayed in a way that makes this explicit:

```jldoctest
julia> (0u"dBm")/u"Hz"
[0.0 dBm] Hz^-1

julia> (0u"dB")/u"Hz"
[0 dB] Hz^-1

julia> 0u"dB/Hz"
[0 dB] Hz^-1
```

Mathematical operations are forwarded to the logarithmic part, so that for example,
`100*((0dBm)/s) == (20dBm)/s`. We allow linear units to commute with logarithmic quantities
for convenience, though the association is understood (e.g. `s^-1*(3dBm) == (3dBm)/s`).

The behavior of multiplication is summarized in the following table, with entries marked by
† indicate prohibited operations. This table is populated automatically whenever the docs
are built.

<table>
<thead>
<tr>
<th align="right">\*</th>
<th align="right">10</th>
<th align="right">Hz^-1</th>
<th align="right">dB</th>
<th align="right">dBm</th>
<th align="right">1/Hz</th>
<th align="right">1mW</th>
<th align="right">3dB</th>
<th align="right">3dBm</th>
</tr>
</thead>
<tbody>
<tr>
<td align="right"><strong>10</strong></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 10*10
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 10*u"Hz^-1"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 10*u"dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 10*u"dBm"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 10*u"1/Hz"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 10*u"1mW"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 10*u"3dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 10*u"3dBm"
```
</td>
</tr>
<tr>
<td align="right"><strong>Hz^-1</strong></td>
<td align="right" />
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"Hz^-1"*u"Hz^-1"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"Hz^-1"*u"dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"Hz^-1"*u"dBm"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"Hz^-1"*u"1/Hz"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"Hz^-1"*u"1mW"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"Hz^-1"*u"3dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"Hz^-1"*u"3dBm"
```
</td>
</tr>
<tr>
<td align="right"><strong>dB</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dB"*u"dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dB"*u"dBm"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dB"*u"1/Hz"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dB"*u"1mW"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dB"*u"3dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dB"*u"3dBm"
```
</td>
</tr>
<tr>
<td align="right"><strong>dBm</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dBm"*u"dBm"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dBm"*u"1/Hz"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dBm"*u"1mW"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dBm"*u"3dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"dBm"*u"3dBm"
```
</td>
</tr>
<tr>
<td align="right"><strong>1/Hz</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1/Hz"*u"1/Hz"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1/Hz"*u"1mW"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1/Hz"*u"3dB"
```
‡
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1/Hz"*u"3dBm"
```
</td>
</tr>
<tr>
<td align="right"><strong>1mW</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1mW"*u"1mW"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1mW"*u"3dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1mW"*u"3dBm"
```
</td>
</tr>
<tr>
<td align="right"><strong>3dB</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"3dB"*u"3dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"3dB"*u"3dBm"
```
</td>
</tr>
<tr>
<td align="right"><strong>3dBm</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"3dBm"*u"3dBm"
```
</td>
</tr>
</tbody>
</table>

‡: `1/Hz * 3dB` is technically allowed but dumb things can happen when its unclear if a quantity
is a root-power or power quantity:

```jldoctest
julia> u"1/Hz" * u"3dB"
WARNING: result may be incorrect. Define `Unitful.isrootpower(::Type{<:Unitful.LogInfo}, ::typeof(𝐓))` to fix.
1.9952623149688795 Hz^-1
```

On the other hand, if it can be determined that a power quantity or root-power quantity
is being multiplied by a gain, then the gain is interpreted as a power ratio or root-power
ratio, respectively:

```jldoctest
julia> 1u"mW" * 20u"dB"
100.0 mW

julia> 1u"V" * 20u"dB"
10.0 V
```

## Addition rules

We can add logarithmic quantities without reference levels specified (`Gain`s):

```jldoctest
julia> 20u"dB" + 20u"dB"
40 dB
```

The numbers out front of the `dB` just add: when we talk about gain or attenuation,
we work in logarithmic units so that we can add rather than multiply gain factors. The same
behavior holds when we add a `Gain` to a `Level` or vice versa:

```jldoctest
julia> 20u"dBm" + 20u"dB"
40.0 dBm
```

In the case where you have differing logarithmic scales for the `Level` and the `Gain`,
the logarithmic scale of the `Level` is used for the result:

```jldoctest
julia> 10u"dBm" - 1u"Np"
1.3141103619349632 dBm
```

For logarithmic quantities with the same reference levels, the numbers out in front do not
simply add:

```jldoctest
julia> 20u"dBm" + 20u"dBm"
23.010299956639813 dBm

julia> 2 * 20u"dBm"
23.010299956639813 dBm
```

This is because `dBm` represents a power, ultimately. If we have some amount of power and
we double it, we'd better get roughly `3 dB` more power. Note that the juxtaposition `20dBm`
will ensure that 20 dBm is constructed before multiplication by 2 in the above example.
If you were to type `2*20*dBm`, you'd get 40 dBm.

If the reference levels differ but both levels represent a power, we fall back to linear
quantities:

```jldoctest
julia> 20u"dBm" + @dB 1u"W"/u"W"
1.1 kg m^2 s^-3
```
i.e. `1.1 W`.

Rules for addition are summarized in the following table, with entries marked by †
indicating prohibited operations. This table is populated automatically whenever the docs
are built.

<table>
<thead>
<tr>
<th align="right">+</th>
<th align="right">100</th>
<th align="right">20dB</th>
<th align="right">1Np</th>
<th align="right">10.0dBm</th>
<th align="right">10.0dBv</th>
<th align="right">1mW</th>
</tr>
</thead>
<tbody>
<tr>
<td align="right"><strong>100</strong></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 100+100
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 100+u"20dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 100+u"1Np"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 100+u"10.0dBm"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 100+u"10.0dBV"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables 100+u"1mW"
```
</td>
</tr>
<tr>
<td align="right"><strong>20dB</strong></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"20dB"+u"20dB"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"20dB"+u"1Np"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"20dB"+u"10.0dBm"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"20dB"+u"10.0dBV"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"20dB"+u"1mW"
```
</td>
</tr>
<tr>
<td align="right"><strong>1Np</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1Np"+u"1Np"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1Np"+u"10.0dBm"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1Np"+u"10.0dBV"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1Np"+u"1mW"
```
</td>
</tr>
<tr>
<td align="right"><strong>10.0dBm</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"10.0dBm"+u"10.0dBm"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"10.0dBm"+u"10.0dBV"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"10.0dBm"+u"1mW"
```
</td>
</tr>
<tr>
<td align="right"><strong>10.0dBV</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"10.0dBV"+u"10.0dBV"
```
</td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"10.0dBV"+u"1mW"
```
</td>
</tr>
<tr>
<td align="right"><strong>1mW</strong></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right"></td>
<td align="right">
```@eval
using Unitful
Unitful.@_doctables u"1mW"+u"1mW"
```
</td>
</tr>
</tbody>
</table>

Notice that we disallow implicit conversions between dimensionless logarithmic quantities
and real numbers. This is because the results can depend on promotion rules in addition to
being ambiguous because of the root-power vs. power ratio issue. If `100 + 10dB` were
evaluated as `20dB + 10dB == 30dB`, then we'd get `1000`, but if it were evaluated as
`100+10`, we'd get `110`.

Also, although it is possible in principle to add e.g. `20dB + 1Np`, notice that we have
not implemented that because it is unclear whether the result should be in nepers or
decibels, and it is also unclear how to handle that question more generally as other
logarithmic scales are introduced.

## Conversion

As alluded to earlier, conversions can be tricky because so-called logarithmic units are not
units in the conventional sense.

You may use [`linear`](@ref) to convert to a linear scale when you have a `Level` or
`Quantity{<:Level}` type. There is a fallback for `Number`, which just returns the number.

```jldoctest
julia> linear(@dB 10u"mW"/u"mW")
10 mW

julia> linear(20u"dBm/Hz")
100.0 Hz^-1 mW

julia> linear(30u"W")
30 W

julia> linear(12)
12
```

Linearizing a `Quantity{<:Gain}` or a `Gain` to a real number is ambiguous, because the real
number may represent a ratio of powers or a ratio of root-power (field) quantities. We
implement [`Unitful.powerratio`](@ref) and [`Unitful.rootpowerratio`](@ref) which may be
thought of as disambiguated `uconvert` functions. There is a one argument version that
assumes you are converting to a unitless number. These functions can take either a `Gain`
or a `Real` so that they may be used somewhat generically.

```jldoctest
julia> fieldratio(NoUnits, 20u"dB")    # the first argument is optional when it is `NoUnits`
10.0

julia> fieldratio(20u"dB")
10.0

julia> powerratio(NoUnits, 20u"dB")  
100.0

julia> powerratio(u"dB", 100)
20.0 dB

julia> powerratio(u"Np", e^2)
1.0 Np

julia> fieldratio(u"Np", e)
1//1 Np
```

To save typing you can use `fieldratio` instead of `rootpowerratio`,
although according to the infallible source
[Wikipedia](https://en.wikipedia.org/wiki/Decibel#Field_quantities_and_root-power_quantities):

> The term root-power quantity is introduced by ISO Standard 80000-1:2009 as a substitute
> of field quantity. The term field quantity is deprecated by that standard.

I would check the primary source but I'm too cheap to pay for the ISO standard. Sorry!

## Notation

This package displays logarithmic quantities using shorthand like `dBm` where available.
This should probably not be done in polite company. To quote "Guide for the Use of the
International System of Units (SI)," NIST Special Pub. 811 (2008):

> The rules of Ref. [5: IEC 60027-3] preclude, for example, the use of the symbol dBm to
> indicate a reference level of power of 1 mW. This restriction is based on the rule of Sec.
> 7.4, which does not permit attachments to unit symbols.

The authorities say the reference level should always specified. In practice, this hasn't
stopped the use of `dBm` and the like on commercially available test equipment. Dealing with
these units is unavoidable in practice. When no shorthand exists, we follow NIST's advice in
displaying logarithmic quantities:

> When such data are presented in a table or in a figure, the following condensed notation
> may be used instead: -0.58 Np (1 μV/m); 25 dB (20 μPa).

## Custom logarithmic scales

```@docs
    Unitful.@logscale
```

## API

```@docs
    Unitful.linear
    Unitful.reflevel
    Unitful.powerratio
    Unitful.rootpowerratio
```
