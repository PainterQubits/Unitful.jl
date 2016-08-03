# Default dimensions and their abbreviations.
@dimension Length       "L"
@dimension Mass         "M"
@dimension Time         "T"
@dimension Current      "I"
@dimension Temperature  "Θ"
@dimension Amount       "N"
@dimension Luminosity   "J"
@dimension Angle        "°"

@derived_dimension Area (Dimension{:Length}(2),)
@derived_dimension Volume (Dimension{:Length}(3),)
@derived_dimension Frequency (Dimension{:Time}(-1),)

# The following three lines should be kept together.
# Second and third lines allow for mu to be typed with option-m on a Mac.
@baseunit m   "m"   Meter   Length
const  µm = Units{(Unit{:Meter}(-6,1//1),)}()
export µm
#key:     Symbol  Display  Name      Dimension
@baseunit s       "s"      Second    Time
@baseunit A       "A"      Ampere    Current
@baseunit K       "K"      Kelvin    Temperature
@baseunit cd      "cd"     Candela   Luminosity
@baseunit mol     "mol"    Mole      Amount
@baseunit g       "g"      Gram      Mass

# Default symbols for refering to a unit in the REPL.
#key: Symbol Display    Name        Equivalent to           10^n prefixes?
@unit mi     "mi"       Mile        (201168//125)*m         false
@unit yd     "yd"       Yard        (9144//10000)*m         false
@unit ft     "ft"       Foot        (3048//10000)*m         false
@unit inch   "in"       Inch        (254//10000)*m          false

@unit a      "a"        Are         100m^2                  false
const  ha = Units{(Unit{:Are}(2,1//1),)}()
export ha

@unit ac     "ac"       Acre        (316160658//78125)*m^2  false

@unit minute "min"      Minute      60s                     false
@unit h      "hr"       Hour        3600s                   false
@unit d      "dy"       Day         86400s                  false
@unit wk     "wk"       Week        604800s                 false

@baseunit rad "rad"     Radian      Angle
@unit °       "°"       Degree      (pi/180)*rad           false
for y in [:sin, :cos, :tan, :cot, :sec, :csc]
    @eval ($y){T,D}(x::Quantity{T,D,typeof(°)}) = ($y)(x.val*pi/180)
    @eval ($y){T,D}(x::Quantity{T,D,typeof(rad)}) = ($y)(x.val)
end

@unit N      "N"        Newton      1kg*m/s^2               true    # GRAM problem
@unit Pa     "Pa"       Pascal      1N/m^2                  true
@unit J      "J"        Joule       1N*m                    true
@unit W      "W"        Watt        1J/s                    true
@unit eV     "eV"       eV          1.6021766208e-19*J      true    # CODATA 2014
@unit C      "C"        Coulomb     1A*s                    true
@unit V      "V"        Volt        1W/A                    true
@unit Ω      "Ω"        Ohm         1V/A                    true
@unit S      "S"        Siemens     1/Ω                     true
@unit F      "F"        Farad       1s^4*A^2/(kg*m^2)       true
@unit H      "H"        Henry       1J/(A^2)                true
@unit T      "T"        Tesla       1kg/(A*s^2)             true
@unit Wb     "Wb"       Weber       1kg*m^2/(A*s^2)         true
#
@unit °Ra    "°Ra"      Rankine     (5//9)*K                false

@unit °C     "°C"       Celsius     1K                      false
offsettemp(::Unit{:Celsius}) = 27315//100

@unit °F     "°F"       Fahrenheit  (5//9)*K                false
offsettemp(::Unit{:Fahrenheit}) = 45967//100

# Constants
const  k = 1.38064852e-23*(J/K)  # 2014 CODATA value
export k

# Default rules for addition and subtraction.
for op in [:+, :-]
    # Can change to min(x,y), x, or y
    @eval ($op)(x::Units, y::Units) = max(x,y)
end
