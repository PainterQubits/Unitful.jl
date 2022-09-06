# Default dimensions and their abbreviations.
# The dimension symbols are generated by tab completion: \^L is ᴸ, etc.
# These symbols are available in Windows terminals with e.g. fonts Consolas and
# Deja Vu Sans Mono.
# At the expense of easy typing, this gives a visual cue to distinguish
# dimensions from units, and also helps prevent common namespace collisions.
"    Unitfu.ᴸ
\nA dimension representing length."
@dimension ᴸ " ᴸ" Length      true
"    Unitfu.ᴹ
\nA dimension representing mass."
@dimension ᴹ " ᴹ" Mass       true
"    Unitfu.ᵀ
\nA dimension representing time."
@dimension ᵀ " ᵀ" Time        true
"    Unitfu.ᴵ
\nA dimension representing electric current."
@dimension ᴵ " ᴵ" Current      true
"    Unitfu.ᶿ
\nA dimension representing thermodynamic temperature."
@dimension ᶿ " ᶿ" Temperature true   # This one is \bfTheta
"    Unitfu.ᴶ
\nA dimension representing luminous intensity."
@dimension ᴶ " ᴶ" Luminosity   true
"    Unitfu.ᴺ
\nA dimension representing amount of substance."
@dimension ᴺ " ᴺ" Amount      true
const RelativeScaleTemperature = Quantity{T, ᶿ, <:AffineUnits} where T
const AbsoluteScaleTemperature = Quantity{T, ᶿ, <:ScalarUnits} where T

# Define derived dimensions.
@derived_dimension Area                     ᴸ^2 true
@derived_dimension Volume                   ᴸ^3 true
@derived_dimension Density                  ᴹ / ᴸ^3 true
@derived_dimension Frequency                inv(ᵀ) true
@derived_dimension Velocity                 ᴸ / ᵀ true
@derived_dimension Acceleration             ᴸ / ᵀ^2 true
@derived_dimension Force                    ᴹ * ᴸ / ᵀ^2 true
@derived_dimension Pressure                 ᴹ * ᴸ^-1 * ᵀ^-2 true
@derived_dimension Energy                   ᴹ * ᴸ^2 / ᵀ^2 true
@derived_dimension Momentum                 ᴹ * ᴸ / ᵀ true
@derived_dimension Power                    ᴸ^2 * ᴹ * ᵀ^-3 true
@derived_dimension Charge                   ᴵ * ᵀ true
@derived_dimension Voltage                  ᴵ^-1 * ᴸ^2 * ᴹ * ᵀ^-3 true
@derived_dimension ElectricalResistance     ᴵ^-2 * ᴸ^2 * ᴹ * ᵀ^-3 true
@derived_dimension ElectricalResistivity    ᴵ^-2 * ᴸ^3* ᴹ * ᵀ^-3 true
@derived_dimension ElectricalConductance    ᴵ^2 * ᴸ^-2 * ᴹ^-1 * ᵀ^3 true
@derived_dimension ElectricalConductivity   ᴵ^2 * ᴸ^-3 * ᴹ^-1 * ᵀ^3 true
@derived_dimension Capacitance              ᴵ^2 * ᴸ^-2 * ᴹ^-1 * ᵀ^4 true
@derived_dimension Inductance               ᴵ^-2 * ᴸ^2 * ᴹ * ᵀ^-2 true
@derived_dimension MagneticFlux             ᴵ^-1 * ᴸ^2 * ᴹ * ᵀ^-2 true
@derived_dimension DField                   ᴵ * ᵀ / ᴸ^2 true
@derived_dimension EField                   ᴸ * ᴹ * ᵀ^-3 * ᴵ^-1 true
@derived_dimension HField                   ᴵ / ᴸ true
@derived_dimension BField                   ᴵ^-1 * ᴹ * ᵀ^-2 true
@derived_dimension Action                   ᴸ^2 * ᴹ * ᵀ^-1 true
@derived_dimension DynamicViscosity         ᴹ * ᴸ^-1 * ᵀ^-1 true
@derived_dimension KinematicViscosity       ᴸ^2 * ᵀ^-1 true
@derived_dimension Wavenumber               inv(ᴸ) true
@derived_dimension ElectricDipoleMoment     ᴸ * ᵀ * ᴵ true
@derived_dimension ElectricQuadrupoleMoment ᴸ^2 * ᵀ * ᴵ true
@derived_dimension MagneticDipoleMoment     ᴸ^2 * ᴵ true
@derived_dimension Molarity                 ᴺ / ᴸ^3 true
@derived_dimension Molality                 ᴺ / ᴹ true
@derived_dimension MassFlow                 ᴹ / ᵀ true
@derived_dimension MolarFlow                ᴺ / ᵀ true
@derived_dimension VolumeFlow               ᴸ^3 / ᵀ true

# Define base units. This is not to imply g is the base SI unit instead of kg.
# See the documentation for further details.
# #key:   Symbol  Display  Name      Dimension   Prefixes?
"    Unitfu.m
\nThe meter, the SI base unit of length.
\nDimension: [`Unitfu.ᴸ`](@ref)."
@refunit  m       "m"      Meter     ᴸ           true true
"    Unitfu.s
\nThe second, the SI base unit of time.
\nDimension: [`Unitfu.ᵀ`](@ref)."
@refunit  s       "s"      Second    ᵀ           true true
"    Unitfu.A
\nThe ampere, the SI base unit of electric current.
\nDimension: [`Unitfu.ᴵ`](@ref)."
@refunit  A       "A"      Ampere    ᴵ            true true
"    Unitfu.K
\nThe kelvin, the SI base unit of thermodynamic temperature.
\nDimension: [`Unitfu.ᶿ`](@ref)."
@refunit  K       "K"      Kelvin    ᶿ           true true
"    Unitfu.cd
\nThe candela, the SI base unit of luminous intensity.
\nDimension: [`Unitfu.ᴶ`](@ref)."
@refunit  cd      "cd"     Candela   ᴶ            true true
# the docs for all gram-based units are defined later, to ensure kg is the base unit.
@refunit  g       "g"      Gram      ᴹ           true
"    Unitfu.mol
\nThe mole, the SI base unit for amount of substance.
\nDimension: [`Unitfu.ᴺ`](@ref)."
@refunit  mol     "mol"    Mole      ᴺ           true true

# Angles and solid angles
"    Unitfu.sr
\nThe steradian, a unit of spherical angle. There are 4π sr in a sphere.
\nDimension: [`Unitfu.NoDims`](@ref)."
@unit sr      "sr"      Steradian   1                       true true
"    Unitfu.rad
\nThe radian, a unit of angle. There are 2π rad in a circle.
\nDimension: [`Unitfu.NoDims`](@ref)."
@unit rad     "rad"     Radian      1                       true true
"    Unitfu.°
\nThe degree, a unit of angle. There are 360° in a circle.
\nDimension: [`Unitfu.NoDims`](@ref)."
@unit °       "°"       Degree      pi/180                  false
# For numerical accuracy, specific to the degree
import Base: sind, cosd, tand, secd, cscd, cotd
for (_x,_y) in ((:sin,:sind), (:cos,:cosd), (:tan,:tand),
        (:sec,:secd), (:csc,:cscd), (:cot,:cotd))
    @eval ($_x)(x::Quantity{T, NoDims, typeof(°)}) where {T} = ($_y)(ustrip(x))
    @eval ($_y)(x::Quantity{T, NoDims, typeof(°)}) where {T} = ($_y)(ustrip(x))
end

# conversion between degrees and radians
import Base: deg2rad, rad2deg
deg2rad(d::Quantity{T, NoDims, typeof(°)}) where {T} = deg2rad(ustrip(°, d))u"rad"
rad2deg(r::Quantity{T, NoDims, typeof(rad)}) where {T} = rad2deg(ustrip(rad, r))u"°"

# SI and related units
"    Unitfu.Hz
\nThe hertz, an SI unit of frequency, defined as 1 s^-1.
\nDimension: ᵀ^-1.
\nSee also: [`Unitfu.s`](@ref)."
@unit Hz              "Hz"   Hertz           1/s                true true
"    Unitfu.N
\nThe newton, an SI unit of force, defined as 1 kg × m / s^2.
\nDimension: ᴸ ᴹ ᵀ^-2.
\nSee also: [`Unitfu.kg`](@ref), [`Unitfu.m`](@ref), [`Unitfu.s`](@ref)."
@unit N               "N"    Newton          1kg*m/s^2          true true
"    Unitfu.Pa
\nThe pascal, an SI unit of pressure, defined as 1 N / m^2.
\nDimension: ᴹ ᴸ^-1 ᵀ^-2.
\nSee also: [`Unitfu.N`](@ref), [`Unitfu.m`](@ref)."
@unit Pa              "Pa"   Pascal          1N/m^2             true true
"    Unitfu.J
\nThe joule, an SI unit of energy, defined as 1 N × m.
\nDimension: ᴸ^2 ᴹ ᵀ^-2.
\nSee also: [`Unitfu.N`](@ref), [`Unitfu.m`](@ref)."
@unit J               "J"    Joule           1N*m               true true
"    Unitfu.W
\nThe watt, an SI unit of power, defined as 1 J / s.
\nDimension: ᴸ^2 ᴹ ᵀ^-3.
\nSee also: [`Unitfu.J`](@ref), [`Unitfu.s`](@ref)."
@unit W               "W"    Watt            1J/s               true true
"    Unitfu.C
\nThe coulomb, an SI unit of electric charge, defined as 1 A × s.
\nDimension: ᴵ ᵀ.
\nSee also: [`Unitfu.A`](@ref), [`Unitfu.s`](@ref)."
@unit C               "C"    Coulomb         1A*s               true true
"    Unitfu.V
\nThe volt, an SI unit of electric potential, defined as 1 W / A.
\nDimension: ᴸ^2 ᴹ ᴵ^-1 ᵀ^-3.
\nSee also: [`Unitfu.W`](@ref), [`Unitfu.A`](@ref)"
@unit V               "V"    Volt            1W/A               true true
"    Unitfu.Ω
\nThe ohm, an SI unit of electrical resistance, defined as 1 V / A.
\nDimension: ᴸ^2 ᴹ ᴵ^-2 ᵀ^-3.
\nSee also: [`Unitfu.V`](@ref), [`Unitfu.A`](@ref)."
@unit Ω               "Ω"    Ohm             1V/A               true true
"    Unitfu.S
\nThe siemens, an SI unit of electrical conductance, defined as 1 Ω^-1.
\nDimension: ᴵ^2 ᵀ^3 ᴸ^-2 ᴹ^-1.
\nSee also: [`Unitfu.Ω`](@ref)"
@unit S               "S"    Siemens         1/Ω                true true
"    Unitfu.F
\nThe farad, an SI unit of electrical capacitance, defined as 1 s^4 × A^2 / (kg × m^2).
\nDimension: ᴵ^2 ᵀ^4 ᴸ^-2 ᴹ^-1.
\nSee also: [`Unitfu.s`](@ref), [`Unitfu.A`](@ref), [`Unitfu.kg`](@ref), [`Unitfu.m`](@ref)."
@unit F               "F"    Farad           1s^4*A^2/(kg*m^2)  true true
"    Unitfu.H
\nThe henry, an SI unit of electrical inductance, defined as 1 J / A^2.
\nDimension: ᴸ^2 ᴹ ᴵ^-2 ᵀ^-2.
\nSee also: [`Unitfu.J`](@ref), [`Unitfu.A`](@ref)."
@unit H               "H"    Henry           1J/(A^2)           true true
"    Unitfu.T
\nThe tesla, an SI unit of magnetic B-field strength, defined as 1 kg / (A × s^2).
\nDimension: ᴹ ᴵ^-1 ᵀ^-2.
\nSee also: [`Unitfu.kg`](@ref), [`Unitfu.A`](@ref), [`Unitfu.s`](@ref)."
@unit T               "T"    Tesla           1kg/(A*s^2)        true true
"    Unitfu.Wb
\nThe weber, an SI unit of magnetic flux, defined as 1 kg × m^2 / (A × s^2).
\nDimension: ᴸ^2 ᴹ ᴵ^-1 ᵀ^-2.
\nSee also: [`Unitfu.kg`](@ref), [`Unitfu.m`](@ref), [`Unitfu.A`](@ref), [`Unitfu.s`](@ref)."
@unit Wb              "Wb"   Weber           1kg*m^2/(A*s^2)    true true
"    Unitfu.lm
\nThe lumen, an SI unit of luminous flux, defined as 1 cd × sr.
\nDimension: [`Unitfu.ᴶ`](@ref).
\nSee also: [`Unitfu.cd`](@ref), [`Unitfu.sr`](@ref)."
@unit lm              "lm"   Lumen           1cd*sr             true true
"    Unitfu.lx
\nThe lux, an SI unit of illuminance, defined as 1 lm / m^2.
\nDimension: ᴶ ᴸ^-2.
\nSee also: [`Unitfu.lm`](@ref), [`Unitfu.m`](@ref)."
@unit lx              "lx"   Lux             1lm/m^2            true true
"    Unitfu.Bq
\nThe becquerel, an SI unit of radioactivity, defined as 1 nuclear decay per s.
\nDimension: ᵀ^-1.
\nSee also: [`Unitfu.s`](@ref)."
@unit Bq              "Bq"   Becquerel       1/s                true true
"    Unitfu.Gy
\nThe gray, an SI unit of ionizing radiation dose, defined as the absorbtion of 1 J per kg of matter.
\nDimension: ᴸ^2 ᵀ^-2.
\nSee also: [`Unitfu.lm`](@ref), [`Unitfu.m`](@ref)."
@unit Gy              "Gy"   Gray            1J/kg              true true
"    Unitfu.Sv
\nThe sievert, an SI unit of the biological effect of an ionizing radiation dose.
Defined as the health effect of 1 Gy of radiation, scaled by a quality factor.
\nDimension: ᴸ^2 ᵀ^-2.
\nSee also: [`Unitfu.Gy`](@ref)."
@unit Sv              "Sv"   Sievert         1J/kg              true true
"    Unitfu.kat
\nThe katal, an SI unit of catalytic activity, defined as 1 mol of catalyzed
substrate per s.
\nDimension: ᴺ ᵀ^-1.
\nSee also: [`Unitfu.mol`](@ref), [`Unitfu.s`](@ref)."
@unit kat             "kat"  Katal           1mol/s             true true
"    Unitfu.percent
\nPercent, a unit meaning parts per hundred. Printed as \"%\".
\nDimension: [`Unitfu.NoDims`](@ref)."
@unit percent         "%"    Percent         1//100             false
"    Unitfu.permille
\nPermille, a unit meaning parts per thousand. Printed as \"‰\".
\nDimension: [`Unitfu.NoDims`](@ref)."
@unit permille        "‰"    Permille        1//1000            false
"    Unitfu.pertenthousand
\nPermyriad, a unit meaning parts per ten thousand. Printed as \"‱\".
\nDimension: [`Unitfu.NoDims`](@ref)."
@unit pertenthousand  "‱"    Pertenthousand  1//10000           false

# Temperature
"    Unitfu.°C
\nThe degree Celsius, an SI unit of temperature, defined such that 0 °C = 273.15 K.
\nDimension: [`Unitfu.ᶿ`](@ref).
\nSee also: [`Unitfu.K`](@ref)."
@affineunit °C "°C"     (27315//100)K

# Common units of time
"    Unitfu.minute
\nThe minute, a unit of time defined as 60 s. The full name `minute` is used instead of the symbol `min`
to avoid confusion with the Julia function `min`.
\nDimension: [`Unitfu.ᵀ`](@ref).
\nSee Also: [`Unitfu.s`](@ref)."
@unit minute "minute"   Minute                60s           false
"    Unitfu.hr
\nThe hour, a unit of time defined as 60 minutes.
\nDimension: [`Unitfu.ᵀ`](@ref).
\nSee Also: [`Unitfu.minute`](@ref)."
@unit hr     "hr"       Hour                  3600s         false
"    Unitfu.d
\nThe day, a unit of time defined as 24 hr.
\nDimension: [`Unitfu.ᵀ`](@ref).
\nSee Also: [`Unitfu.hr`](@ref)."
@unit d      "d"        Day                   86400s        false
"    Unitfu.wk
\nThe week, a unit of time, defined as 7 d.
\nDimension: [`Unitfu.ᵀ`](@ref).
\nSee Also: [`Unitfu.d`](@ref)."
@unit wk     "wk"       Week                  604800s       false
"    Unitfu.yr
\nThe year, a unit of time, defined as 365.25 d.
\nDimension: [`Unitfu.ᵀ`](@ref).
\nSee Also: [`Unitfu.hr`](@ref)."
@unit yr     "yr"       Year                  31557600s     true true
"    Unitfu.rps
\nRevolutions per second, a unit of rotational speed, defined as 2π rad / s.
\nDimension: ᵀ^-1.
\nSee Also: [`Unitfu.rad`](@ref), [`Unitfu.s`](@ref)."
@unit rps    "rps"      RevolutionsPerSecond  2π*rad/s      false
"    Unitfu.rpm
\nRevolutions per minute, a unit of rotational speed, defined as 2π rad / minute.
\nDimension: ᵀ^-1.
\nSee Also: [`Unitfu.minute`](@ref), [`Unitfu.rad`](@ref)."
@unit rpm    "rpm"      RevolutionsPerMinute  2π*rad/minute false

# Area
# The hectare is used more frequently than any other power-of-ten of an are.
"    Unitfu.a
\nThe are, a metric unit of area, defined as 100 m^2.
\nDimension: ᴸ^2.
\nSee Also: [`Unitfu.m`](@ref)."
@unit a      "a"        Are         100m^2                  false
"    Unitfu.ha
\nThe hectare, a metric unit of area, defined as 100 a.
\nDimension: ᴸ^2.
\nSee Also: [`Unitfu.a`](@ref)."
const ha = Unitfu.FreeUnits{(Unitfu.Unit{:Are, ᴸ^2}(2, 1//1),), ᴸ^2}()
"    Unitfu.b
\nThe barn, a metric unit of area, defined as 100 fm^2.
\nDimension: ᴸ^2.
\nSee Also: [`Unitfu.fm`](@ref)."
@unit b      "b"        Barn        100fm^2                 true true

# Volume
# `l` is also an acceptable symbol for liters
"    Unitfu.L
    Unitfu.l
\nThe liter, a metric unit of volume, defined as 1000 cm^3.
\nDimension: ᴸ^3.
\nSee Also: [`Unitfu.cm`](@ref)."
@unit L      "L"        Liter       m^3//1000                true
for p in (:y, :z, :a, :f, :p, :n, :μ, :m, :c, :d,
    Symbol(""), :da, :h, :k, :M, :G, :T, :P, :E, :Z, :Y)
    Core.eval(Unitfu, :(const $(Symbol(p,:l)) = $(Symbol(p,:L))))
end
@doc @doc(L) l
for (k,v) in prefixdict
    if k != 0
        sym_L = Symbol(v,:L)
        sym_l = Symbol(v,:l)
        docstring = """
                        Unitfu.$sym_L
                        Unitfu.$sym_l

                    A prefixed unit, equal to 10^$k L.

                    Dimension: ᴸ^3.

                    See also: [`Unitfu.L`](@ref).
                    """
        run = quote @doc $docstring $sym_l; @doc $docstring $sym_L end
        eval(run)
    end
end

# Molarityᴹ
"    Unitfu.M
\nA unit for measuring molar concentration, equal to 1 mol/L.
\nDimension: ᴺ ᴸ^-3.
\nSee Also: [`Unitfu.L`](@ref), [`Unitfu.mol`](@ref)."
@unit M      "M"        Molar       1mol/L                  true true

# Energy
"    Unitfu.q
\nA quantity equal to the elementary charge, the charge of a single electron,
with a value of exactly 1.602,176,634 × 10^-19 C. The letter `q` is used instead of `e` to avoid
confusion with Euler's number.
\nDimension: ᴵ ᵀ.
\nSee Also: [`Unitfu.C`](@ref)."
const q = 1.602_176_634e-19*C        # CODATA 2018; `e` means 2.718...
"    Unitfu.eV
\nThe electron-volt, a unit of energy, defined as q*V.
\nDimension: ᴸ^2 ᴹ ᵀ^-2.
\nSee also: [`Unitfu.q`](@ref), [`Unitfu.V`](@ref)."
@unit eV     "eV"       eV          q*V                     true true

# For convenience
"    Unitfu.Hz2π
\nA unit for convenience in angular frequency, equal to 2π Hz.
\nDimension: ᵀ^-1.
\nSee also: [`Unitfu.Hz`](@ref)."
@unit Hz2π   "Hz2π"     AngHertz    2π/s                    true true
"    Unitfu.bar
\nThe bar, a metric unit of pressure, defined as 100 kPa.
\nDimension: ᴹ ᴸ^-1 ᵀ^-2.
\nSee also: [`Unitfu.kPa`](@ref)."
@unit bar    "bar"      Bar         100000Pa                true true
"    Unitfu.atm
\nThe standard atmosphere, a unit of pressure, defined as 101,325 Pa.
\nDimension: ᴹ ᴸ^-1 ᵀ^-2.
\nSee also: [`Unitfu.Pa`](@ref)."
@unit atm    "atm"      Atmosphere  101325Pa                false
"    Unitfu.Torr
\nThe torr, a unit of pressure, defined as 1/760 atm.
\nDimension: ᴹ ᴸ^-1 ᵀ^-2.
\nSee also: [`Unitfu.atm`](@ref)."
@unit Torr   "Torr"     Torr        101325Pa//760           true true

# Constants (2018 CODATA values)        (uncertainties in final digits)
"    Unitfu.c0
\nA quantity representing the speed of light in a vacuum, defined as exactly
2.997,924,58 × 10^8 m/s.
\n`Unitfu.c0` is a quantity (with units `m/s`) whereas [`Unitfu.c`](@ref) is a unit equal to `c0`.
\nDimension: ᴸ ᵀ^-1.
\nSee also: [`Unitfu.m`](@ref), [`Unitfu.s`](@ref)."
const c0 = 299_792_458*m/s              # exact
"    Unitfu.c
\nThe speed of light in a vacuum, a unit of speed, defined as exactly
2.997,924,58 × 10^8 m/s.
\n[`Unitfu.c0`](@ref) is a quantity (with units `m/s`) whereas `Unitfu.c` is a unit equal to `c0`.
\nDimension: ᴸ ᵀ^-1.
\nSee also: [`Unitfu.m`](@ref), [`Unitfu.s`](@ref)."
@unit c      "c"        SpeedOfLight 1c0                    false
"    Unitfu.μ0
\nA quantity representing the vacuum permeability constant, defined as 4π × 10^-7 H / m.
\nDimension: ᴸ ᴹ ᴵ^-2 ᵀ^-2.
\nSee also: [`Unitfu.H`](@ref), [`Unitfu.m`](@ref)."
const μ0 = 4π*(1//10)^7*H/m         # exact (but gets promoted to Float64...), magnetic constant
"    Unitfu.ε0
    Unitfu.ϵ0
\nA quantity representing the vacuum permittivity constant, defined as 1 / (μ0 × c^2).
\nDimension: ᴵ^2 ᵀ^4 ᴸ^-3 ᴹ^-1.
\nSee also: [`Unitfu.μ0`](@ref), [`Unitfu.c`](@ref)."
const ε0 = 1/(μ0*c^2)               # exact, electric constant; changes here may affect
@doc @doc(ε0) const ϵ0 = ε0         # test of issue 79.
"    Unitfu.Z0
\nA quantity representing the impedance of free space, a constant defined as μ0 × c.
\nDimension: ᴸ^2 ᴹ ᴵ^-2 ᵀ^-3.
\nSee also: [`Unitfu.μ0`](@ref), [`Unitfu.c`](@ref)."
const Z0 = μ0*c                     # exact, impedance of free space
"    Unitfu.G
\nA quantity representing the universal gravitational constant, equal to
6.674,30 × 10^-11 m^3 / (kg × s^2) (the CODATA 2018 recommended value).
\nDimension: ᴸ^3 ᴹ^-1 ᵀ^-2.
\nSee also: [`Unitfu.m`](@ref), [`Unitfu.kg`](@ref), [`Unitfu.s`](@ref)."
const G  = 6.674_30e-11*m^3/kg/s^2  # (15) gravitational constant
"    Unitfu.gn
\nA quantity representing the nominal acceleration due to gravity in a vacuum
near the surface of the earth, defined by standard to be exactly 9.806,65 m / s^2.
\n`Unitfu.gn` is a quantity (with units `m/s^2`) whereas [`Unitfu.ge`](@ref) is a unit equal to `gn`.
\nDimension: ᴸ ᵀ^-2.
\nSee also: [`Unitfu.m`](@ref), [`Unitfu.s`](@ref)."
const gn = 9.80665*m/s^2            # exact, standard acceleration of gravity
"    Unitfu.h
\nA quantity representing Planck's constant, defined as exactly
6.626,070,15 × 10^-34 J × s.
\nDimension: ᴸ^2 ᴹ ᵀ^-1.
\nSee also: [`Unitfu.J`](@ref), [`Unitfu.s`](@ref)."
const h  = 6.626_070_15e-34*J*s     # exact, Planck constant
"    Unitfu.ħ
\nA quantity representing the reduced Planck constant, defined as h / 2π.
\nDimension: ᴸ^2 ᴹ ᵀ^-1.
\nSee also: [`Unitfu.h`](@ref)."
const ħ  = h/2π                     # hbar
"    Unitfu.Φ0
\nA quantity representing the superconducting magnetic flux quantum, defined as
h / (2 × q).
\nDimension: ᴸ^2 ᴹ ᴵ^-1 ᵀ^-2.
\nSee also: [`Unitfu.h`](@ref), [`Unitfu.q`](@ref)."
const Φ0 = h/(2q)                   # Superconducting magnetic flux quantum
"    Unitfu.me
\nA quantity representing the rest mass of an electron, equal to 9.109,383,7015
× 10^-31 kg (the CODATA 2018 recommended value).
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee also: [`Unitfu.kg`](@ref)."
const me = 9.109_383_7015e-31*kg    # (28) electron rest mass
"    Unitfu.mn
\nA quantity representing the rest mass of a neutron, equal to 1.674,927,498,04
× 10^-27 kg (the CODATA 2018 recommended value).
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee also: [`Unitfu.kg`](@ref)."
const mn = 1.674_927_498_04e-27*kg  # (95) neutron rest mass
"    Unitfu.mp
\nA quantity representing the rest mass of a proton, equal to 1.672,621,923,69
× 10^-27 kg (the CODATA 2018 recommended value).
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee also: [`Unitfu.kg`](@ref)."
const mp = 1.672_621_923_69e-27*kg  # (51) proton rest mass
"    Unitfu.μB
\nA quantity representing the Bohr magneton, equal to q × ħ / (2 × me).
\nDimension: ᴵ ᴸ^2.
\nSee also: [`Unitfu.q`](@ref), [`Unitfu.ħ`](@ref), [`Unitfu.me`](@ref)."
const μB = q*ħ/(2*me)               # Bohr magneton
"    Unitfu.Na
\nA quantity representing Avogadro's constant, defined as exactly
6.022,140,76 × 10^23 / mol.
\nDimension: ᴺ^-1.
\nSee also: [`Unitfu.mol`](@ref)."
const Na = 6.022_140_76e23/mol      # exact, Avogadro constant
"    Unitfu.k
\nA quantity representing the Boltzmann constant, defined as exactly
1.380,649 × 10^-23 J / K.
\nDimension: ᴸ^2 ᴹ ᶿ^-1 ᵀ^-2.
\nSee also: [`Unitfu.J`](@ref), [`Unitfu.K`](@ref)."
const k  = 1.380_649e-23*(J/K)      # exact, Boltzmann constant
"    Unitfu.R
\nA quantity representing the molar gas constant, defined as
Na × k.
\nDimension: ᴸ^2 ᴹ ᴺ^-1 ᶿ^-1 ᵀ^-2.
\nSee also: [`Unitfu.Na`](@ref), [`Unitfu.k`](@ref)."
const R  = Na*k                     # molar gas constant
"    Unitfu.σ
\nA quantity representing the Stefan-Boltzmann constant, defined as
π^2 × k^4 / (60 × ħ^3 × c^2).
\nDimension: ᴹ ᶿ^-4 ᵀ^-3.
\nSee also: [`Unitfu.k`](@ref), [`Unitfu.ħ`](@ref), [`Unitfu.c`](@ref)."
const σ  = π^2*k^4/(60*ħ^3*c^2)     # Stefan-Boltzmann constant
"    Unitfu.R∞
\nA quantity representing the Rydberg constant, equal to 1.097,373,156,8160 × 10^-7 / m
(the CODATA 2018 recommended value).
\nDimension: ᴸ^-1.
\nSee also: [`Unitfu.m`](@ref)."
const R∞ = 10_973_731.568_160/m     # (21) Rydberg constant
"    Unitfu.u
\nThe unified atomic mass unit, or dalton, a unit of mass defined as 1/12 the
mass of an unbound neutral atom of carbon-12, equal to 1.660,539,066,60 × 10^-27 kg
(the CODATA 2018 recommended value).
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee Also: [`Unitfu.kg`](@ref)."
@unit u      "u" UnifiedAtomicMassUnit 1.660_539_066_60e-27*kg false # (50)

# Acceleration
"    Unitfu.ge
\nThe nominal acceleration due to gravity in a vacuum near the surface of the
earth, a unit of acceleration, defined by standard to be exactly 9.806,65 m / s^2.
\n[`Unitfu.gn`](@ref) is a quantity (with units `m/s^2`) whereas `Unitfu.ge` is a unit equal to `gn`.
\nDimension: ᴸ ᵀ^-2.
\nSee also: [`Unitfu.m`](@ref), [`Unitfu.s`](@ref)."
@unit ge     "ge"       EarthGravity gn                     false


# CGS units
"    Unitfu.Gal
\nThe gal, a CGS unit of acceleration, defined as 1 cm / s^2.
\nDimension: ᴸ ᵀ^-2.
\nSee also: [`Unitfu.cm`](@ref), [`Unitfu.s`](@ref)."
@unit Gal    "Gal"      Gal         1cm/s^2                 true true
"    Unitfu.dyn
\nThe dyne, a CGS unit of force, defined as 1 g × cm / s^2.
\nDimension: ᴸ ᴹ ᵀ^-2.
\nSee also: [`Unitfu.cm`](@ref), [`Unitfu.s`](@ref), [`Unitfu.g`](@ref)."
@unit dyn    "dyn"      Dyne        1g*cm/s^2               true true
"    Unitfu.erg
\nThe erg, a CGS unit of energy, defined as 1 dyn × cm.
\nDimension: ᴸ^2 ᴹ ᵀ^-2.
\nSee also: [`Unitfu.cm`](@ref), [`Unitfu.dyn`](@ref)"
@unit erg    "erg"      Erg         1g*cm^2/s^2             true true
"    Unitfu.Ba
\nThe barye, a CGS unit of pressure, defined as 1 dyn / cm^2.
\nDimension: ᴹ ᴸ^-1 ᵀ^-2.
\nSee also: [`Unitfu.cm`](@ref), [`Unitfu.dyn`](@ref)"
@unit Ba     "Ba"       Barye       1g/cm/s^2               true true
"    Unitfu.P
\nThe poise, a CGS unit of dynamic viscosity, defined as 1 dyn × s / cm^2.
\nDimension: ᴹ ᴸ^-1 ᵀ^-1.
\nSee also: [`Unitfu.cm`](@ref), [`Unitfu.dyn`](@ref), [`Unitfu.s`](@ref)"
@unit P      "P"        Poise       1g/cm/s                 true true
"    Unitfu.St
\nThe stokes, a CGS unit of kinematic viscosity, defined as 1 cm^2 / s.
\nDimension: ᴹ^2 ᵀ^-1.
\nSee also: [`Unitfu.cm`](@ref), [`Unitfu.s`](@ref)"
@unit St     "St"       Stokes      1cm^2/s                 true true
"    Unitfu.Gauss
\nThe gauss, a CGS unit of magnetic B-field strength, defined as 1 Mx / cm^2.
\nDimension: ᴹ ᴵ^-1 ᵀ^-2.
\nSee also: [`Unitfu.cm`](@ref), [`Unitfu.Mx`](@ref)"
@unit Gauss  "Gauss"    Gauss       (1//10_000)*T           true true
"    Unitfu.Oe
\nThe oersted, a CGS unit of magnetic H-field strength, defined as 1000 A / (4π × m).
\nDimension: ᴵ ᴸ^-1.
\nSee also: [`Unitfu.A`](@ref), [`Unitfu.m`](@ref)"
@unit Oe     "Oe"       Oersted     (1_000/4π)*A/m          true true
"    Unitfu.Mx
\nThe maxwell, a CGS unit of magnetic flux, defined as 1 Gauss × cm^2.
\nDimension: ᴸ^2 ᴹ ᴵ^-1 ᵀ^-2.
\nSee also: [`Unitfu.cm`](@ref), [`Unitfu.Gauss`](@ref)"
@unit Mx     "Mx"       Maxwell     (1//100_000_000)*Wb     true true


#########
# Shared Imperial / US customary units

# Length
#key: Symbol    Display    Name                 Equivalent to           10^n prefixes?
"    Unitfu.inch
\nThe inch, a US customary unit of length defined as 2.54 cm.
\nDimension: [`Unitfu.ᴸ`](@ref).
\nSee Also: [`Unitfu.cm`](@ref)."
@unit inch      "inch"     Inch                 (254//10000)*m          false
"    Unitfu.mil
\nThe mil, a US customary unit of length defined as 1/1000 inch.
\nDimension: [`Unitfu.ᴸ`](@ref).
\nSee Also: [`Unitfu.inch`](@ref)."
@unit mil       "mil"      Mil                  (1//1000)*inch          false
"    Unitfu.ft
\nThe foot, a US customary unit of length defined as 12 inch.
\nDimension: [`Unitfu.ᴸ`](@ref).
\nSee Also: [`Unitfu.inch`](@ref)."
@unit ft        "ft"       Foot                 12inch                  false
"    Unitfu.yd
\nThe yard, a US customary unit of length defined as 3 ft.
\nDimension: [`Unitfu.ᴸ`](@ref).
\nSee Also: [`Unitfu.ft`](@ref)."
@unit yd        "yd"       Yard                 3ft                     false
"    Unitfu.mi
\nThe mile, a US customary unit of length defined as 1760 yd.
\nDimension: [`Unitfu.ᴸ`](@ref).
\nSee Also: [`Unitfu.yd`](@ref)."
@unit mi        "mi"       Mile                 1760yd                  false
"    Unitfu.angstrom
    Unitfu.Å
\nThe angstrom, a metric unit of length defined as 1/10 nm.
\nDimension: [`Unitfu.ᴸ`](@ref).
\nSee Also: [`Unitfu.nm`](@ref)."
@unit angstrom  "Å"        Angstrom             (1//10)*nm      false
# U+00c5 (opt-shift-A on macOS) and U+212b ('\Angstrom' in REPL) look identical:
@doc @doc(angstrom) const Å = Å = angstrom

# Area
"    Unitfu.ac
\nThe acre, a US customary unit of area defined as 4840 yd^2.
\nDimension: ᴸ^2.
\nSee Also: [`Unitfu.yd`](@ref)."
@unit ac        "ac"       Acre                 (316160658//78125)*m^2  false

# Temperatures
"    Unitfu.Ra
\nThe rankine, a US customary unit of temperature defined as 5/9 K.
\nDimension: [`Unitfu.ᶿ`](@ref).
\nSee Also: [`Unitfu.K`](@ref)."
@unit Ra        "Ra"      Rankine               (5//9)*K                false
"    Unitfu.°F
\nThe degree Fahrenheit, a US customary unit of temperature, defined such that 0 °F = 459.67 Ra.
\nDimension: [`Unitfu.ᶿ`](@ref).
\nSee also: [`Unitfu.Ra`](@ref)."
@affineunit °F  "°F"      (45967//100)Ra

# Masses
"    Unitfu.lb
\nThe pound-mass, a US customary unit of mass defined as exactly 0.453,592,37 kg.
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee Also: [`Unitfu.kg`](@ref)."
@unit lb        "lb"       Pound                0.45359237kg            false # is exact
"    Unitfu.oz
\nThe ounce, a US customary unit of mass defined as 1/16 lb.
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee Also: [`Unitfu.lb`](@ref)."
@unit oz        "oz"       Ounce                lb//16                  false
"    Unitfu.slug
\nThe slug, a US customary unit of mass defined as 1 lbf × s^2 / ft.
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee Also: [`Unitfu.lbf`](@ref), [`Unitfu.s`](@ref), [`Unitfu.ft`](@ref)."
@unit slug      "slug"     Slug                 1lb*ge*s^2/ft           false
"    Unitfu.dr
\nThe dram, a US customary unit of mass defined as 1/16 oz.
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee Also: [`Unitfu.oz`](@ref)."
@unit dr        "dr"       Dram                 oz//16                  false
"    Unitfu.gr
\nThe grain, a US customary unit of mass defined as 1/7000 lb.
\nDimension: [`Unitfu.ᴹ`](@ref).
\nSee Also: [`Unitfu.lb`](@ref)."
@unit gr        "gr"       Grain                (32//875)*dr            false

# Force
"    Unitfu.lbf
\nThe pound-force, a US customary unit of force defined as 1 lb × ge.
\nDimension: ᴸ ᴹ ᵀ^-2.
\nSee Also: [`Unitfu.lb`](@ref), [`Unitfu.ge`](@ref)."
@unit lbf       "lbf"      PoundsForce          1lb*ge                  false

# Energy
# Use ISO 31-4 for BTU definition
"    Unitfu.cal
\nThe calorie, a unit of energy defined as exactly 4.184 J.
\nDimension: ᴸ^2 ᴹ ᵀ^-2.
\nSee Also: [`Unitfu.J`](@ref)."
@unit cal       "cal"      Calorie              4.184J                  true true
"    Unitfu.btu
\nThe British thermal unit, a US customary unit of heat defined by ISO 31-4 as exactly 1055.06 J.
\nDimension: ᴸ^2 ᴹ ᵀ^-2.
\nSee Also: [`Unitfu.J`](@ref)."
@unit btu       "btu"      BritishThermalUnit   1055.06J                false

# Pressure
"    Unitfu.psi
\nPounds per square inch, a US customary unit of pressure defined as 1 lbf / inch^2.
\nDimension: ᴹ ᴸ^-1 ᵀ^-2.
\nSee Also: [`Unitfu.lbf`](@ref), [`Unitfu.inch`](@ref)."
@unit psi       "psi"      PoundsPerSquareInch  1lbf/inch^2             false

#########
# Logarithmic scales and units

@logscale dB    "dB"       Decibel      10      10      false
@logscale B     "B"        Bel          10      1       false
@logscale Np    "Np"       Neper        ℯ       1//2    true
@logscale cNp   "cNp"      Centineper   ℯ       50      true

@logunit  dBHz  "dB-Hz"    Decibel      1Hz
@logunit  dBm   "dBm"      Decibel      1mW
@logunit  dBV   "dBV"      Decibel      1V
@logunit  dBu   "dBu"      Decibel      sqrt(0.6)V
@logunit  dBμV  "dBμV"     Decibel      1μV
@logunit  dBSPL "dBSPL"    Decibel      20μPa
@logunit  dBFS  "dBFS"     Decibel      RootPowerRatio(1)
@logunit  dBΩ   "dBΩ"      Decibel      1Ω
@logunit  dBS   "dBS"      Decibel      1S

# TODO: some more dimensions?
isrootpower_dim(::typeof(dimension(W)))         = false
isrootpower_dim(::typeof(dimension(V)))         = true
isrootpower_dim(::typeof(dimension(A)))         = true
isrootpower_dim(::typeof(dimension(Pa)))        = true
isrootpower_dim(::typeof(dimension(W/m^2/Hz)))  = false     # spectral flux dens.
isrootpower_dim(::typeof(dimension(W/m^2)))     = false     # intensity
isrootpower_dim(::typeof(dimension(W/m^2/m)))   = false
isrootpower_dim(::typeof(dimension(m^3)))       = false     # reflectivity
isrootpower_dim(::typeof(dimension(Ω)))         = true
isrootpower_dim(::typeof(dimension(S)))         = true
isrootpower_dim(::typeof(dimension(Hz)))        = false
isrootpower_dim(::typeof(dimension(J)))         = false

#########

# `using Unitfu.DefaultSymbols` will bring the following into the calling namespace:
# - Dimensions ᴸ,ᴹ,ᵀ,ᴵ,ᶿ,ᴶ,ᴺ
# - Base and derived SI units, with SI prefixes
#   - Candela conflicts with `Base.cd` so it is not brought in (issue #102)
# - Degrees: °

const si_prefixes = (:y, :z, :a, :f, :p, :n, :μ, :m, :c, :d,
    Symbol(""), :da, :h, :k, :M, :G, :T, :P, :E, :Z, :Y)

const si_no_prefix = (:m, :s, :A, :K, :g, :mol, :rad, :sr, :Hz, :N, :Pa, #:cd,
    :J, :W, :C, :V, :F, :Ω, :S, :Wb, :T, :H, :lm, :lx, :Bq, :Gy, :Sv, :kat)

baremodule DefaultSymbols
    import Unitfu

    for u in (:ᴸ,:ᴹ,:ᵀ,:ᴵ,:ᶿ,:ᴶ,:ᴺ)
        Core.eval(DefaultSymbols, Expr(:import, Expr(:(.), :Unitfu, u)))
        Core.eval(DefaultSymbols, Expr(:export, u))
    end

    for p in Unitfu.si_prefixes
        for u in Unitfu.si_no_prefix
            Core.eval(DefaultSymbols, Expr(:import, Expr(:(.), :Unitfu, Symbol(p,u))))
            Core.eval(DefaultSymbols, Expr(:export, Symbol(p,u)))
        end
    end

    Core.eval(DefaultSymbols, Expr(:import, Expr(:(.), :Unitfu, :°C)))
    Core.eval(DefaultSymbols, Expr(:export, :°C))

    Core.eval(DefaultSymbols, Expr(:import, Expr(:(.), :Unitfu, :°)))
    Core.eval(DefaultSymbols, Expr(:export, :°))
end

#########

preferunits(kg) # others done in @refunit
# Fix documentation for all kg based units
for (k,v) in prefixdict
    if k != 3
        sym = Symbol(v,:g)
        docstring = """
                        Unitfu.$sym

                    A prefixed unit, equal to 10^$(k-3) kg. Note that `kg`, not `g`, is the base unit.

                    Dimension: [`Unitfu.ᴹ`](@ref).

                    See also: [`Unitfu.kg`](@ref).
                    """
        run = quote @doc $docstring $sym end
        eval(run)
    end
end
@doc "    Unitfu.kg
\nThe kilogram, the SI base unit of mass.
Note that `kg`, not `g`, is the base unit.
\nDimension: [`Unitfu.ᴹ`](@ref)." kg

"""
    Unitfu.promote_to_derived()
Defines promotion rules to use derived SI units in promotion for common dimensions
of quantities:

- `J` (joule) for energy
- `N` (newton) for force
- `W` (watt) for power
- `Pa` (pascal) for pressure
- `C` (coulomb) for charge
- `V` (volt) for voltage
- `Ω` (ohm) for resistance
- `F` (farad) for capacitance
- `H` (henry) for inductance
- `Wb` (weber) for magnetic flux
- `T` (tesla) for B-field
- `J*s` (joule-second) for action

If you want this as default behavior (it was for versions of Unitfu prior to 0.1.0),
consider invoking this function in your `.juliarc.jl` file which is loaded when
you open Julia. This function is not exported.
"""
function promote_to_derived()
    eval(quote
         Unitfu.promote_unit(::S, ::T) where
         {S<:EnergyFreeUnits, T<:EnergyFreeUnits} = Unitfu.J
         Unitfu.promote_unit(::S, ::T) where
         {S<:ForceFreeUnits, T<:ForceFreeUnits} = Unitfu.N
         Unitfu.promote_unit(::S, ::T) where
         {S<:PowerFreeUnits, T<:PowerFreeUnits} = Unitfu.W
         Unitfu.promote_unit(::S, ::T) where
         {S<:PressureFreeUnits, T<:PressureFreeUnits} = Unitfu.Pa
         Unitfu.promote_unit(::S, ::T) where
         {S<:ChargeFreeUnits, T<:ChargeFreeUnits} = Unitfu.C
         Unitfu.promote_unit(::S, ::T) where
         {S<:VoltageFreeUnits, T<:VoltageFreeUnits} = Unitfu.V
         Unitfu.promote_unit(::S, ::T) where
         {S<:ElectricalResistanceFreeUnits, T<:ElectricalResistanceFreeUnits} = Unitfu.Ω
         Unitfu.promote_unit(::S, ::T) where
         {S<:CapacitanceFreeUnits, T<:CapacitanceFreeUnits} = Unitfu.F
         Unitfu.promote_unit(::S, ::T) where
         {S<:InductanceFreeUnits, T<:InductanceFreeUnits} = Unitfu.H
         Unitfu.promote_unit(::S, ::T) where
         {S<:MagneticFluxFreeUnits, T<:MagneticFluxFreeUnits} = Unitfu.Wb
         Unitfu.promote_unit(::S, ::T) where
         {S<:BFieldFreeUnits, T<:BFieldFreeUnits} = Unitfu.T
         Unitfu.promote_unit(::S, ::T) where
         {S<:ActionFreeUnits, T<:ActionFreeUnits} = Unitfu.J * Unitfu.s
        end)
    nothing
end
