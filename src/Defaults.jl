# The following three lines should be kept together.
# Second and third lines allow for Mac option-m mu
@baseunit m   "m"   _Length
const  µm = UnitData{(UnitDatum(NormalUnit(unitcount),-6,1//1),)}()
export µm

@baseunit s   "s"   _Time
@baseunit A   "A"   _Current
@baseunit K   "K"   _Temperature
@baseunit cd  "cd"  _Luminosity
@baseunit mol "mol" _Amount

# The kilogram is weird because it is the base unit, not the gram.
x = nextunit(NormalUnit)
abbr(::Type{Val{x}})       = "g"
dimension(::Type{Val{x}})  = Dict(_Mass => 1)
basefactor(::Type{Val{x}}) = (1.0, 1//1)
@uall g NormalUnit(unitcount)

# Default symbols for refering to a unit in the REPL.
#key: Symbol Display  Equivalent to        All prefixes?
@newunit mi     "mi"  (201168//125)*m         false
@newunit yd     "yd"  (9144//10000)*m         false
@newunit ft     "ft"  (3048//10000)*m         false
@newunit inch   "in"  (254//10000)*m          false
#
@newunit a      "a"   100m^2                  false
const  ha = UnitData{(UnitDatum(NormalUnit(unitcount),2,1//1),)}()
export ha

@newunit ac     "ac"  (316160658//78125)*m^2  false

@newunit minute "min" 60s                     false
@newunit h      "hr"  3600s                   false
@newunit d      "dy"  86400s                  false
@newunit wk     "wk"  604800s                 false

@baseunit rad "rad" _Angle
@newunit     °   "°"   (pi/180)*rad           false
for y in [:sin, :cos, :tan, :cot, :sec, :csc]
    @eval ($y){T}(x::Quantity{T,typeof(°)}) = ($y)(x.val*pi/180)
    @eval ($y){T}(x::Quantity{T,typeof(rad)}) = ($y)(x.val)
end

@newunit N      "N"   1kg*m/s^2               true     # GRAM problem
@newunit Pa     "Pa"  1N/m^2                  true
@newunit J      "J"   1N*m                    true
@newunit W      "W"   1J/s                    true
@newunit eV     "eV"  1.6021766208e-19*J      true     # CODATA 2014
@newunit C      "C"   1A*s                    true
@newunit V      "V"   1W/A                    true
@newunit Ω      "Ω"   1V/A                    true
@newunit S      "S"   1/Ω                     true
@newunit F      "F"   1s^4*A^2/(kg*m^2)       true
@newunit H      "H"   1J/(A^2)                true
@newunit T      "T"   1kg/(A*s^2)             true
@newunit Wb     "Wb"  1kg*m^2/(A*s^2)         true
#
@newunit °Ra    "°Ra" (5//9)*K                false

@newunit °C     "°C"  1K                      false
offsettemp(::Type{Val{TemperatureUnit(unitcount)}}) = 27315//100

@newunit °F     "°F"  (5//9)*K                false
offsettemp(::Type{Val{TemperatureUnit(unitcount)}}) = 45967//100

# Constants
export k
const  k = 1.38064852e-23*(J/K)  # 2014 CODATA value

# Default rules for addition and subtraction.
for op in [:+, :-]
    # Can change to min(x,y), x, or y
    @eval ($op)(x::UnitData, y::UnitData) = max(x,y)
end
