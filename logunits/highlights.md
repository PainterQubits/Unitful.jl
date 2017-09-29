


<a id='Dispatch-on-dimensions-1'></a>

## Dispatch on dimensions


Consider the following toy example, converting from voltage or power ratios to decibels:


```julia-repl
julia> whatsit(x::Unitful.Voltage) = "voltage!"
 whatsit (generic function with 1 method)

julia> whatsit(x::Unitful.Length) = "length!"
 whatsit (generic function with 2 methods)

julia> whatsit(1u"mm")
"length!"

julia> whatsit(1u"kV")
"voltage!"

julia> whatsit(1u"A" * 2.5u"Ω")
"voltage!"
```


<a id='Dimensions-in-a-type-definition-1'></a>

### Dimensions in a type definition


It may be tempting to specify the dimensions of a quantity in a type definition, e.g.


```
type Person
    height::Unitful.Length
    mass::Unitful.Mass
end
```


However, these are abstract types. If performance is important, it may be better just to pick a concrete `Quantity` type:


```
type Person
    height::typeof(1.0u"m")
    mass::typeof(1.0u"kg")
end
```


You can still create a `Person` as `Person(5u"ft"+10u"inch", 75u"kg")`; the unit conversion happens automatically.


<a id='Making-new-units-and-dimensions-1'></a>

## Making new units and dimensions


You can make new units using the [`@unit`](newunits.md#Unitful.@unit) macro on the fly:


```julia-repl
julia> @unit yd5 "yd5" FiveYards 5u"yd" false
yd5
```


<a id='Arrays-1'></a>

## Arrays


Promotion is used to create arrays of a concrete type where possible, such that arrays of unitful quantities are stored efficiently in memory. However, if necessary, arrays can hold quantities with different dimensions, even mixed with unitless numbers. Doing so will suffer a performance penalty compared with the fast performance attainable with an array of concrete type (e.g. as resulting from `[1.0u"m", 2.0u"cm", 3.0u"km"]`). However, it could be useful in toy calculations for [general relativity](https://en.wikipedia.org/wiki/Metric_tensor_(general_relativity)) where some conventions yield matrices with mixed dimensions:


```
julia> Diagonal([-1.0u"c^2", 1.0, 1.0, 1.0])
4×4 Diagonal{Unitful.Quantity{Float64,D,U}}:
 -1.0 c^2   ⋅    ⋅    ⋅
       ⋅   1.0   ⋅    ⋅
       ⋅    ⋅   1.0   ⋅
       ⋅    ⋅    ⋅   1.0
```


<a id='Logarithmic-units-1'></a>

## Logarithmic units


```julia-repl
julia> uconvert(u"mW*s", 20u"dBm/Hz")
100.0 s mW
```


<a id='Units-with-rational-exponents-1'></a>

## Units with rational exponents


```julia-repl
julia> 1.0u"V/sqrt(Hz)"
1.0 Hz^-1/2 V
```


<a id='Exact-conversions-respected-1'></a>

## Exact conversions respected


```julia-repl
julia> uconvert(u"ft",1u"inch")
1//12 ft
```

