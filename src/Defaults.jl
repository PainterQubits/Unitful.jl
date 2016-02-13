# Default symbols for refering to a unit in the REPL.
# Length
@uall m       _Meter
@u    mi      _Mile
@u    yd      _Yard
@u    ft      _Foot
@u    inch    _Inch

# Area
@u    ac      _Acre
# Special case: the hectare is 100 ares.
const  ha = UnitData{(UnitDatum(_Are,2,1),)}()
export ha

# Time
@uall s       _Second
@u    minute  _Minute
@u    h       _Hour
@u    d       _Day
@u    wk      _Week

# Mass
@uall g       _Gram

# Current
@uall A       _Ampere

# Temperature
@uall K       _Kelvin
@u    °Ra     _Rankine
@u    °C      _Celsius
@u    °F      _Fahrenheit

# Angle
@u    °       _Degree
@u    rad     _Radian

# Derived
@uall N       _Newton
@uall Pa      _Pascal
@uall W       _Watt
@uall J       _Joule
@uall eV      _eV
@uall C       _Coulomb
@uall V       _Volt
@uall Ω       _Ohm
@uall S       _Siemens
@uall F       _Farad
@uall H       _Henry
@uall T       _Tesla
@uall Wb      _Weber

# Constants
export k
const k = 1.38064852e-23*(J/K)  # 2014 CODATA value

# Default rules for addition and subtraction.
for op in [:+, :-]
    # Can change to min(x,y), x, or y
    @eval ($op)(x::UnitData, y::UnitData) = max(x,y)
end

# Default rules for unit simplification.
# WIP
