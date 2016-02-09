# Default symbols for refering to a unit in the REPL.

@uall m  _Meter
@u    ft _Foot
@u    inch _Inch

@uall s   _Second
@u    minute _Minute
@u    h   _Hour

@uall g _Gram

@uall A _Ampere
@uall C _Coulomb
@uall V _Volt

@uall K   _Kelvin
@u    °Ra _Rankine

@u    ° _Degree
@u    rad _Radian

# Default rules for addition and subtraction.
for op in [:+, :-]
    # Can change to min(x,y), x, or y
    @eval ($op)(x::UnitData, y::UnitData) = max(x,y)
end

# Default rules for simplification
#@simplify_prefixes
