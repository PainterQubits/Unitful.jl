# Default dimensions and their abbreviations.
# The dimension symbols are generated by tab completion: \bfL is 𝐋, etc.
# At the expense of easy typing, this gives a visual cue to distinguish
# dimensions from units, and also helps prevent common namespace collisions.
"    Unitful.𝐋
\nA dimension representing length."
@dimension 𝐋 "𝐋" Length      true
"    Unitful.𝐌
\nA dimension representing mass."
@dimension 𝐌 "𝐌" Mass       true
"    Unitful.𝐓
\nA dimension representing time."
@dimension 𝐓 "𝐓" Time        true
"    Unitful.𝐈
\nA dimension representing electric current."
@dimension 𝐈 "𝐈" Current      true
"    Unitful.𝚯
\nA dimension representing thermodynamic temperature."
@dimension 𝚯 "𝚯" Temperature true   # This one is \bfTheta
"    Unitful.𝐉
\nA dimension representing luminous intensity."
@dimension 𝐉 "𝐉" Luminosity   true
"    Unitful.𝐍
\nA dimension representing amount of substance."
@dimension 𝐍 "𝐍" Amount      true
const RelativeScaleTemperature = Quantity{T, 𝚯, <:AffineUnits} where T
const AbsoluteScaleTemperature = Quantity{T, 𝚯, <:ScalarUnits} where T

# Define derived dimensions.
@derived_dimension Area                     𝐋^2 true
@derived_dimension Volume                   𝐋^3 true
@derived_dimension Density                  𝐌/𝐋^3 true
@derived_dimension Frequency                inv(𝐓) true
@derived_dimension Velocity                 𝐋/𝐓 true
@derived_dimension Acceleration             𝐋/𝐓^2 true
@derived_dimension Force                    𝐌*𝐋/𝐓^2 true
@derived_dimension Pressure                 𝐌*𝐋^-1*𝐓^-2 true
@derived_dimension Energy                   𝐌*𝐋^2/𝐓^2 true
@derived_dimension Momentum                 𝐌*𝐋/𝐓 true
@derived_dimension Power                    𝐋^2*𝐌*𝐓^-3 true
@derived_dimension Charge                   𝐈*𝐓 true
@derived_dimension Voltage                  𝐈^-1*𝐋^2*𝐌*𝐓^-3 true
@derived_dimension ElectricalResistance     𝐈^-2*𝐋^2*𝐌*𝐓^-3 true
@derived_dimension ElectricalResistivity    𝐈^-2*𝐋^3*𝐌*𝐓^-3 true
@derived_dimension ElectricalConductance    𝐈^2*𝐋^-2*𝐌^-1*𝐓^3 true
@derived_dimension ElectricalConductivity   𝐈^2*𝐋^-3*𝐌^-1*𝐓^3 true
@derived_dimension Capacitance              𝐈^2*𝐋^-2*𝐌^-1*𝐓^4 true
@derived_dimension Inductance               𝐈^-2*𝐋^2*𝐌*𝐓^-2 true
@derived_dimension MagneticFlux             𝐈^-1*𝐋^2*𝐌*𝐓^-2 true
@derived_dimension DField                   𝐈*𝐓/𝐋^2 true
@derived_dimension EField                   𝐋*𝐌*𝐓^-3*𝐈^-1 true
@derived_dimension HField                   𝐈/𝐋 true
@derived_dimension BField                   𝐈^-1*𝐌*𝐓^-2 true
@derived_dimension Action                   𝐋^2*𝐌*𝐓^-1 true
@derived_dimension DynamicViscosity         𝐌*𝐋^-1*𝐓^-1 true
@derived_dimension KinematicViscosity       𝐋^2*𝐓^-1 true
@derived_dimension Wavenumber               inv(𝐋) true
@derived_dimension ElectricDipoleMoment     𝐋*𝐓*𝐈 true
@derived_dimension ElectricQuadrupoleMoment 𝐋^2*𝐓*𝐈 true
@derived_dimension MagneticDipoleMoment     𝐋^2*𝐈 true
@derived_dimension Molarity                 𝐍/𝐋^3 true
@derived_dimension Molality                 𝐍/𝐌 true
@derived_dimension MassFlow                 𝐌/𝐓 true
@derived_dimension MolarFlow                𝐍/𝐓 true
@derived_dimension VolumeFlow               𝐋^3/𝐓 true

# Define base units. This is not to imply g is the base SI unit instead of kg.
# See the documentation for further details.
# #key:   Symbol  Display  Name      Dimension   Prefixes?
"    Unitful.m
\nThe meter, the SI base unit of length.
\nDimension: [`Unitful.𝐋`](@ref)."
@refunit  m       "m"      Meter     𝐋           true true
"    Unitful.s
\nThe second, the SI base unit of time.
\nDimension: [`Unitful.𝐓`](@ref)."
@refunit  s       "s"      Second    𝐓           true true
"    Unitful.A
\nThe ampere, the SI base unit of electric current.
\nDimension: [`Unitful.𝐈`](@ref)."
@refunit  A       "A"      Ampere    𝐈            true true
"    Unitful.K
\nThe kelvin, the SI base unit of thermodynamic temperature.
\nDimension: [`Unitful.𝚯`](@ref)."
@refunit  K       "K"      Kelvin    𝚯           true true
"    Unitful.cd
\nThe candela, the SI base unit of luminous intensity.
\nDimension: [`Unitful.𝐉`](@ref)."
@refunit  cd      "cd"     Candela   𝐉            true true
# the docs for all gram-based units are defined later, to ensure kg is the base unit.
@refunit  g       "g"      Gram      𝐌           true
"    Unitful.mol
\nThe mole, the SI base unit for amount of substance.
\nDimension: [`Unitful.𝐍`](@ref)."
@refunit  mol     "mol"    Mole      𝐍           true true

# Angles and solid angles
"    Unitful.sr
\nThe steradian, a unit of spherical angle. There are 4π sr in a sphere.
\nDimension: [`Unitful.NoDims`](@ref)."
@unit sr      "sr"      Steradian   1                       true true
"    Unitful.rad
\nThe radian, a unit of angle. There are 2π rad in a circle.
\nDimension: [`Unitful.NoDims`](@ref)."
@unit rad     "rad"     Radian      1                       true true
"    Unitful.°
\nThe degree, a unit of angle. There are 360° in a circle.
\nDimension: [`Unitful.NoDims`](@ref)."
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
"    Unitful.Hz
\nThe hertz, an SI unit of frequency, defined as 1 s^-1.
\nDimension: 𝐓^-1.
\nSee also: [`Unitful.s`](@ref)."
@unit Hz              "Hz"   Hertz           1/s                true true
"    Unitful.N
\nThe newton, an SI unit of force, defined as 1 kg × m / s^2.
\nDimension: 𝐋 𝐌 𝐓^-2.
\nSee also: [`Unitful.kg`](@ref), [`Unitful.m`](@ref), [`Unitful.s`](@ref)."
@unit N               "N"    Newton          1kg*m/s^2          true true
"    Unitful.Pa
\nThe pascal, an SI unit of pressure, defined as 1 N / m^2.
\nDimension: 𝐌 𝐋^-1 𝐓^-2.
\nSee also: [`Unitful.N`](@ref), [`Unitful.m`](@ref)."
@unit Pa              "Pa"   Pascal          1N/m^2             true true
"    Unitful.J
\nThe joule, an SI unit of energy, defined as 1 N × m.
\nDimension: 𝐋^2 𝐌 𝐓^-2.
\nSee also: [`Unitful.N`](@ref), [`Unitful.m`](@ref)."
@unit J               "J"    Joule           1N*m               true true
"    Unitful.W
\nThe watt, an SI unit of power, defined as 1 J / s.
\nDimension: 𝐋^2 𝐌 𝐓^-3.
\nSee also: [`Unitful.J`](@ref), [`Unitful.s`](@ref)."
@unit W               "W"    Watt            1J/s               true true
"    Unitful.C
\nThe coulomb, an SI unit of electric charge, defined as 1 A × s.
\nDimension: 𝐈 𝐓.
\nSee also: [`Unitful.A`](@ref), [`Unitful.s`](@ref)."
@unit C               "C"    Coulomb         1A*s               true true
"    Unitful.V
\nThe volt, an SI unit of electric potential, defined as 1 W / A.
\nDimension: 𝐋^2 𝐌 𝐈^-1 𝐓^-3.
\nSee also: [`Unitful.W`](@ref), [`Unitful.A`](@ref)"
@unit V               "V"    Volt            1W/A               true true
"    Unitful.Ω
\nThe ohm, an SI unit of electrical resistance, defined as 1 V / A.
\nDimension: 𝐋^2 𝐌 𝐈^-2 𝐓^-3.
\nSee also: [`Unitful.V`](@ref), [`Unitful.A`](@ref)."
@unit Ω               "Ω"    Ohm             1V/A               true true
"    Unitful.S
\nThe siemens, an SI unit of electrical conductance, defined as 1 Ω^-1.
\nDimension: 𝐈^2 𝐓^3 𝐋^-2 𝐌^-1.
\nSee also: [`Unitful.Ω`](@ref)"
@unit S               "S"    Siemens         1/Ω                true true
"    Unitful.F
\nThe farad, an SI unit of electrical capacitance, defined as 1 s^4 × A^2 / (kg × m^2).
\nDimension: 𝐈^2 𝐓^4 𝐋^-2 𝐌^-1.
\nSee also: [`Unitful.s`](@ref), [`Unitful.A`](@ref), [`Unitful.kg`](@ref), [`Unitful.m`](@ref)."
@unit F               "F"    Farad           1s^4*A^2/(kg*m^2)  true true
"    Unitful.H
\nThe henry, an SI unit of electrical inductance, defined as 1 J / A^2.
\nDimension: 𝐋^2 𝐌 𝐈^-2 𝐓^-2.
\nSee also: [`Unitful.J`](@ref), [`Unitful.A`](@ref)."
@unit H               "H"    Henry           1J/(A^2)           true true
"    Unitful.T
\nThe tesla, an SI unit of magnetic B-field strength, defined as 1 kg / (A × s^2).
\nDimension: 𝐌 𝐈^-1 𝐓^-2.
\nSee also: [`Unitful.kg`](@ref), [`Unitful.A`](@ref), [`Unitful.s`](@ref)."
@unit T               "T"    Tesla           1kg/(A*s^2)        true true
"    Unitful.Wb
\nThe weber, an SI unit of magnetic flux, defined as 1 kg × m^2 / (A × s^2).
\nDimension: 𝐋^2 𝐌 𝐈^-1 𝐓^-2.
\nSee also: [`Unitful.kg`](@ref), [`Unitful.m`](@ref), [`Unitful.A`](@ref), [`Unitful.s`](@ref)."
@unit Wb              "Wb"   Weber           1kg*m^2/(A*s^2)    true true
"    Unitful.lm
\nThe lumen, an SI unit of luminous flux, defined as 1 cd × sr.
\nDimension: [`Unitful.𝐉`](@ref).
\nSee also: [`Unitful.cd`](@ref), [`Unitful.sr`](@ref)."
@unit lm              "lm"   Lumen           1cd*sr             true true
"    Unitful.lx
\nThe lux, an SI unit of illuminance, defined as 1 lm / m^2.
\nDimension: 𝐉 𝐋^-2.
\nSee also: [`Unitful.lm`](@ref), [`Unitful.m`](@ref)."
@unit lx              "lx"   Lux             1lm/m^2            true true
"    Unitful.Bq
\nThe becquerel, an SI unit of radioactivity, defined as 1 nuclear decay per s.
\nDimension: 𝐓^-1.
\nSee also: [`Unitful.s`](@ref)."
@unit Bq              "Bq"   Becquerel       1/s                true true
"    Unitful.Gy
\nThe gray, an SI unit of ionizing radiation dose, defined as the absorption of 1 J per kg of matter.
\nDimension: 𝐋^2 𝐓^-2.
\nSee also: [`Unitful.lm`](@ref), [`Unitful.m`](@ref)."
@unit Gy              "Gy"   Gray            1J/kg              true true
"    Unitful.Sv
\nThe sievert, an SI unit of the biological effect of an ionizing radiation dose.
Defined as the health effect of 1 Gy of radiation, scaled by a quality factor.
\nDimension: 𝐋^2 𝐓^-2.
\nSee also: [`Unitful.Gy`](@ref)."
@unit Sv              "Sv"   Sievert         1J/kg              true true
"    Unitful.kat
\nThe katal, an SI unit of catalytic activity, defined as 1 mol of catalyzed
substrate per s.
\nDimension: 𝐍 𝐓^-1.
\nSee also: [`Unitful.mol`](@ref), [`Unitful.s`](@ref)."
@unit kat             "kat"  Katal           1mol/s             true true
"    Unitful.percent
\nPercent, a unit meaning parts per hundred. Printed as \"%\".
\nDimension: [`Unitful.NoDims`](@ref)."
@unit percent         "%"    Percent         1//100             false
"    Unitful.permille
\nPermille, a unit meaning parts per thousand. Printed as \"‰\".
\nDimension: [`Unitful.NoDims`](@ref)."
@unit permille        "‰"    Permille        1//1000            false
"    Unitful.pertenthousand
\nPermyriad, a unit meaning parts per ten thousand. Printed as \"‱\".
\nDimension: [`Unitful.NoDims`](@ref)."
@unit pertenthousand  "‱"    Pertenthousand  1//10000           false

# Temperature
"    Unitful.°C
\nThe degree Celsius, an SI unit of temperature, defined such that 0 °C = 273.15 K.
\nDimension: [`Unitful.𝚯`](@ref).
\nSee also: [`Unitful.K`](@ref)."
@affineunit °C "°C"     (27315//100)K

# Common units of time
"    Unitful.minute
\nThe minute, a unit of time defined as 60 s. The full name `minute` is used instead of the symbol `min`
to avoid confusion with the Julia function `min`.
\nDimension: [`Unitful.𝐓`](@ref).
\nSee Also: [`Unitful.s`](@ref)."
@unit minute "minute"   Minute                60s           false
"    Unitful.hr
\nThe hour, a unit of time defined as 60 minutes.
\nDimension: [`Unitful.𝐓`](@ref).
\nSee Also: [`Unitful.minute`](@ref)."
@unit hr     "hr"       Hour                  3600s         false
"    Unitful.d
\nThe day, a unit of time defined as 24 hr.
\nDimension: [`Unitful.𝐓`](@ref).
\nSee Also: [`Unitful.hr`](@ref)."
@unit d      "d"        Day                   86400s        false
"    Unitful.wk
\nThe week, a unit of time, defined as 7 d.
\nDimension: [`Unitful.𝐓`](@ref).
\nSee Also: [`Unitful.d`](@ref)."
@unit wk     "wk"       Week                  604800s       false
"    Unitful.yr
\nThe year, a unit of time, defined as 365.25 d.
\nDimension: [`Unitful.𝐓`](@ref).
\nSee Also: [`Unitful.hr`](@ref)."
@unit yr     "yr"       Year                  31557600s     true true
"    Unitful.rps
\nRevolutions per second, a unit of rotational speed, defined as 2π rad / s.
\nDimension: 𝐓^-1.
\nSee Also: [`Unitful.rad`](@ref), [`Unitful.s`](@ref)."
@unit rps    "rps"      RevolutionsPerSecond  2π*rad/s      false
"    Unitful.rpm
\nRevolutions per minute, a unit of rotational speed, defined as 2π rad / minute.
\nDimension: 𝐓^-1.
\nSee Also: [`Unitful.minute`](@ref), [`Unitful.rad`](@ref)."
@unit rpm    "rpm"      RevolutionsPerMinute  2π*rad/minute false

# Area
# The hectare is used more frequently than any other power-of-ten of an are.
"    Unitful.a
\nThe are, a metric unit of area, defined as 100 m^2.
\nDimension: 𝐋^2.
\nSee Also: [`Unitful.m`](@ref)."
@unit a      "a"        Are         100m^2                  false
"    Unitful.ha
\nThe hectare, a metric unit of area, defined as 100 a.
\nDimension: 𝐋^2.
\nSee Also: [`Unitful.a`](@ref)."
const ha = Unitful.FreeUnits{(Unitful.Unit{:Are, 𝐋^2}(2, 1//1),), 𝐋^2}()
"    Unitful.b
\nThe barn, a metric unit of area, defined as 100 fm^2.
\nDimension: 𝐋^2.
\nSee Also: [`Unitful.fm`](@ref)."
@unit b      "b"        Barn        100fm^2                 true true

# Volume
# `l` is also an acceptable symbol for liters
"    Unitful.L
    Unitful.l
\nThe liter, a metric unit of volume, defined as 1000 cm^3.
\nDimension: 𝐋^3.
\nSee Also: [`Unitful.cm`](@ref)."
@unit L      "L"        Liter       m^3//1000                true
for p in (:y, :z, :a, :f, :p, :n, :μ, :m, :c, :d,
    Symbol(""), :da, :h, :k, :M, :G, :T, :P, :E, :Z, :Y)
    Core.eval(Unitful, :(const $(Symbol(p,:l)) = $(Symbol(p,:L))))
end
@doc @doc(L) l
for (k,v) in prefixdict
    if k != 0
        sym_L = Symbol(v,:L)
        sym_l = Symbol(v,:l)
        docstring = """
                        Unitful.$sym_L
                        Unitful.$sym_l

                    A prefixed unit, equal to 10^$k L.

                    Dimension: 𝐋^3.

                    See also: [`Unitful.L`](@ref).
                    """
        run = quote @doc $docstring $sym_l; @doc $docstring $sym_L end
        eval(run)
    end
end

# Molarity
"    Unitful.M
\nA unit for measuring molar concentration, equal to 1 mol/L.
\nDimension: 𝐍 𝐋^-3.
\nSee Also: [`Unitful.L`](@ref), [`Unitful.mol`](@ref)."
@unit M      "M"        Molar       1mol/L                  true true

# Energy
"    Unitful.q
\nA quantity equal to the elementary charge, the charge of a single electron,
with a value of exactly 1.602,176,634 × 10^-19 C. The letter `q` is used instead of `e` to avoid
confusion with Euler's number.
\nDimension: 𝐈 𝐓.
\nSee Also: [`Unitful.C`](@ref)."
const q = 1.602_176_634e-19*C        # CODATA 2018; `e` means 2.718...
"    Unitful.eV
\nThe electron-volt, a unit of energy, defined as q*V.
\nDimension: 𝐋^2 𝐌 𝐓^-2.
\nSee also: [`Unitful.q`](@ref), [`Unitful.V`](@ref)."
@unit eV     "eV"       eV          q*V                     true true

# For convenience
"    Unitful.Hz2π
\nA unit for convenience in angular frequency, equal to 2π Hz.
\nDimension: 𝐓^-1.
\nSee also: [`Unitful.Hz`](@ref)."
@unit Hz2π   "Hz2π"     AngHertz    2π/s                    true true
"    Unitful.bar
\nThe bar, a metric unit of pressure, defined as 100 kPa.
\nDimension: 𝐌 𝐋^-1 𝐓^-2.
\nSee also: [`Unitful.kPa`](@ref)."
@unit bar    "bar"      Bar         100000Pa                true true
"    Unitful.atm
\nThe standard atmosphere, a unit of pressure, defined as 101,325 Pa.
\nDimension: 𝐌 𝐋^-1 𝐓^-2.
\nSee also: [`Unitful.Pa`](@ref)."
@unit atm    "atm"      Atmosphere  101325Pa                true true
"    Unitful.Torr
\nThe torr, a unit of pressure, defined as 1/760 atm.
\nDimension: 𝐌 𝐋^-1 𝐓^-2.
\nSee also: [`Unitful.atm`](@ref)."
@unit Torr   "Torr"     Torr        101325Pa//760           true true

# Constants (2018 CODATA values)        (uncertainties in final digits)
"    Unitful.c0
\nA quantity representing the speed of light in a vacuum, defined as exactly
2.997,924,58 × 10^8 m/s.
\n`Unitful.c0` is a quantity (with units `m/s`) whereas [`Unitful.c`](@ref) is a unit equal to `c0`.
\nDimension: 𝐋 𝐓^-1.
\nSee also: [`Unitful.m`](@ref), [`Unitful.s`](@ref)."
const c0 = 299_792_458*m/s              # exact
"    Unitful.c
\nThe speed of light in a vacuum, a unit of speed, defined as exactly
2.997,924,58 × 10^8 m/s.
\n[`Unitful.c0`](@ref) is a quantity (with units `m/s`) whereas `Unitful.c` is a unit equal to `c0`.
\nDimension: 𝐋 𝐓^-1.
\nSee also: [`Unitful.m`](@ref), [`Unitful.s`](@ref)."
@unit c      "c"        SpeedOfLight 1c0                    false
"    Unitful.μ0
\nA quantity representing the vacuum permeability constant, defined as 4π × 10^-7 H / m.
\nDimension: 𝐋 𝐌 𝐈^-2 𝐓^-2.
\nSee also: [`Unitful.H`](@ref), [`Unitful.m`](@ref)."
const μ0 = 4π*(1//10)^7*H/m         # exact (but gets promoted to Float64...), magnetic constant
"    Unitful.ε0
    Unitful.ϵ0
\nA quantity representing the vacuum permittivity constant, defined as 1 / (μ0 × c^2).
\nDimension: 𝐈^2 𝐓^4 𝐋^-3 𝐌^-1.
\nSee also: [`Unitful.μ0`](@ref), [`Unitful.c`](@ref)."
const ε0 = 1/(μ0*c^2)               # exact, electric constant; changes here may affect
@doc @doc(ε0) const ϵ0 = ε0         # test of issue 79.
"    Unitful.Z0
\nA quantity representing the impedance of free space, a constant defined as μ0 × c.
\nDimension: 𝐋^2 𝐌 𝐈^-2 𝐓^-3.
\nSee also: [`Unitful.μ0`](@ref), [`Unitful.c`](@ref)."
const Z0 = μ0*c                     # exact, impedance of free space
"    Unitful.G
\nA quantity representing the universal gravitational constant, equal to
6.674,30 × 10^-11 m^3 / (kg × s^2) (the CODATA 2018 recommended value).
\nDimension: 𝐋^3 𝐌^-1 𝐓^-2.
\nSee also: [`Unitful.m`](@ref), [`Unitful.kg`](@ref), [`Unitful.s`](@ref)."
const G  = 6.674_30e-11*m^3/kg/s^2  # (15) gravitational constant
"    Unitful.gn
\nA quantity representing the nominal acceleration due to gravity in a vacuum
near the surface of the earth, defined by standard to be exactly 9.806,65 m / s^2.
\n`Unitful.gn` is a quantity (with units `m/s^2`) whereas [`Unitful.ge`](@ref) is a unit equal to `gn`.
\nDimension: 𝐋 𝐓^-2.
\nSee also: [`Unitful.m`](@ref), [`Unitful.s`](@ref)."
const gn = 9.80665*m/s^2            # exact, standard acceleration of gravity
"    Unitful.h
\nA quantity representing Planck's constant, defined as exactly
6.626,070,15 × 10^-34 J × s.
\nDimension: 𝐋^2 𝐌 𝐓^-1.
\nSee also: [`Unitful.J`](@ref), [`Unitful.s`](@ref)."
const h  = 6.626_070_15e-34*J*s     # exact, Planck constant
"    Unitful.ħ
\nA quantity representing the reduced Planck constant, defined as h / 2π.
\nDimension: 𝐋^2 𝐌 𝐓^-1.
\nSee also: [`Unitful.h`](@ref)."
const ħ  = h/2π                     # hbar
"    Unitful.Φ0
\nA quantity representing the superconducting magnetic flux quantum, defined as
h / (2 × q).
\nDimension: 𝐋^2 𝐌 𝐈^-1 𝐓^-2.
\nSee also: [`Unitful.h`](@ref), [`Unitful.q`](@ref)."
const Φ0 = h/(2q)                   # Superconducting magnetic flux quantum
"    Unitful.me
\nA quantity representing the rest mass of an electron, equal to 9.109,383,7015
× 10^-31 kg (the CODATA 2018 recommended value).
\nDimension: [`Unitful.𝐌`](@ref).
\nSee also: [`Unitful.kg`](@ref)."
const me = 9.109_383_7015e-31*kg    # (28) electron rest mass
"    Unitful.mn
\nA quantity representing the rest mass of a neutron, equal to 1.674,927,498,04
× 10^-27 kg (the CODATA 2018 recommended value).
\nDimension: [`Unitful.𝐌`](@ref).
\nSee also: [`Unitful.kg`](@ref)."
const mn = 1.674_927_498_04e-27*kg  # (95) neutron rest mass
"    Unitful.mp
\nA quantity representing the rest mass of a proton, equal to 1.672,621,923,69
× 10^-27 kg (the CODATA 2018 recommended value).
\nDimension: [`Unitful.𝐌`](@ref).
\nSee also: [`Unitful.kg`](@ref)."
const mp = 1.672_621_923_69e-27*kg  # (51) proton rest mass
"    Unitful.μB
\nA quantity representing the Bohr magneton, equal to q × ħ / (2 × me).
\nDimension: 𝐈 𝐋^2.
\nSee also: [`Unitful.q`](@ref), [`Unitful.ħ`](@ref), [`Unitful.me`](@ref)."
const μB = q*ħ/(2*me)               # Bohr magneton
"    Unitful.Na
\nA quantity representing Avogadro's constant, defined as exactly
6.022,140,76 × 10^23 / mol.
\nDimension: 𝐍^-1.
\nSee also: [`Unitful.mol`](@ref)."
const Na = 6.022_140_76e23/mol      # exact, Avogadro constant
"    Unitful.k
\nA quantity representing the Boltzmann constant, defined as exactly
1.380,649 × 10^-23 J / K.
\nDimension: 𝐋^2 𝐌 𝚯^-1 𝐓^-2.
\nSee also: [`Unitful.J`](@ref), [`Unitful.K`](@ref)."
const k  = 1.380_649e-23*(J/K)      # exact, Boltzmann constant
"    Unitful.R
\nA quantity representing the molar gas constant, defined as
Na × k.
\nDimension: 𝐋^2 𝐌 𝐍^-1 𝚯^-1 𝐓^-2.
\nSee also: [`Unitful.Na`](@ref), [`Unitful.k`](@ref)."
const R  = Na*k                     # molar gas constant
"    Unitful.σ
\nA quantity representing the Stefan-Boltzmann constant, defined as
π^2 × k^4 / (60 × ħ^3 × c^2).
\nDimension: 𝐌 𝚯^-4 𝐓^-3.
\nSee also: [`Unitful.k`](@ref), [`Unitful.ħ`](@ref), [`Unitful.c`](@ref)."
const σ  = π^2*k^4/(60*ħ^3*c^2)     # Stefan-Boltzmann constant
"    Unitful.R∞
\nA quantity representing the Rydberg constant, equal to 1.097,373,156,8160 × 10^-7 / m
(the CODATA 2018 recommended value).
\nDimension: 𝐋^-1.
\nSee also: [`Unitful.m`](@ref)."
const R∞ = 10_973_731.568_160/m     # (21) Rydberg constant
"    Unitful.u
\nThe unified atomic mass unit, or dalton, a unit of mass defined as 1/12 the
mass of an unbound neutral atom of carbon-12, equal to 1.660,539,066,60 × 10^-27 kg
(the CODATA 2018 recommended value).
\nDimension: [`Unitful.𝐌`](@ref).
\nSee Also: [`Unitful.kg`](@ref)."
@unit u      "u" UnifiedAtomicMassUnit 1.660_539_066_60e-27*kg false # (50)

# Acceleration
"    Unitful.ge
\nThe nominal acceleration due to gravity in a vacuum near the surface of the
earth, a unit of acceleration, defined by standard to be exactly 9.806,65 m / s^2.
\n[`Unitful.gn`](@ref) is a quantity (with units `m/s^2`) whereas `Unitful.ge` is a unit equal to `gn`.
\nDimension: 𝐋 𝐓^-2.
\nSee also: [`Unitful.m`](@ref), [`Unitful.s`](@ref)."
@unit ge     "ge"       EarthGravity gn                     false


# CGS units
"    Unitful.Gal
\nThe gal, a CGS unit of acceleration, defined as 1 cm / s^2.
\nDimension: 𝐋 𝐓^-2.
\nSee also: [`Unitful.cm`](@ref), [`Unitful.s`](@ref)."
@unit Gal    "Gal"      Gal         1cm/s^2                 true true
"    Unitful.dyn
\nThe dyne, a CGS unit of force, defined as 1 g × cm / s^2.
\nDimension: 𝐋 𝐌 𝐓^-2.
\nSee also: [`Unitful.cm`](@ref), [`Unitful.s`](@ref), [`Unitful.g`](@ref)."
@unit dyn    "dyn"      Dyne        1g*cm/s^2               true true
"    Unitful.erg
\nThe erg, a CGS unit of energy, defined as 1 dyn × cm.
\nDimension: 𝐋^2 𝐌 𝐓^-2.
\nSee also: [`Unitful.cm`](@ref), [`Unitful.dyn`](@ref)"
@unit erg    "erg"      Erg         1g*cm^2/s^2             true true
"    Unitful.Ba
\nThe barye, a CGS unit of pressure, defined as 1 dyn / cm^2.
\nDimension: 𝐌 𝐋^-1 𝐓^-2.
\nSee also: [`Unitful.cm`](@ref), [`Unitful.dyn`](@ref)"
@unit Ba     "Ba"       Barye       1g/cm/s^2               true true
"    Unitful.P
\nThe poise, a CGS unit of dynamic viscosity, defined as 1 dyn × s / cm^2.
\nDimension: 𝐌 𝐋^-1 𝐓^-1.
\nSee also: [`Unitful.cm`](@ref), [`Unitful.dyn`](@ref), [`Unitful.s`](@ref)"
@unit P      "P"        Poise       1g/cm/s                 true true
"    Unitful.St
\nThe stokes, a CGS unit of kinematic viscosity, defined as 1 cm^2 / s.
\nDimension: 𝐌^2 𝐓^-1.
\nSee also: [`Unitful.cm`](@ref), [`Unitful.s`](@ref)"
@unit St     "St"       Stokes      1cm^2/s                 true true
"    Unitful.Gauss
\nThe gauss, a CGS unit of magnetic B-field strength, defined as 1 Mx / cm^2.
\nDimension: 𝐌 𝐈^-1 𝐓^-2.
\nSee also: [`Unitful.cm`](@ref), [`Unitful.Mx`](@ref)"
@unit Gauss  "Gauss"    Gauss       (1//10_000)*T           true true
"    Unitful.Oe
\nThe oersted, a CGS unit of magnetic H-field strength, defined as 1000 A / (4π × m).
\nDimension: 𝐈 𝐋^-1.
\nSee also: [`Unitful.A`](@ref), [`Unitful.m`](@ref)"
@unit Oe     "Oe"       Oersted     (1_000/4π)*A/m          true true
"    Unitful.Mx
\nThe maxwell, a CGS unit of magnetic flux, defined as 1 Gauss × cm^2.
\nDimension: 𝐋^2 𝐌 𝐈^-1 𝐓^-2.
\nSee also: [`Unitful.cm`](@ref), [`Unitful.Gauss`](@ref)"
@unit Mx     "Mx"       Maxwell     (1//100_000_000)*Wb     true true


#########
# Shared Imperial / US customary units

# Length
#key: Symbol    Display    Name                 Equivalent to           10^n prefixes?
"    Unitful.inch
\nThe inch, a US customary unit of length defined as 2.54 cm.
\nDimension: [`Unitful.𝐋`](@ref).
\nSee Also: [`Unitful.cm`](@ref)."
@unit inch      "inch"     Inch                 (254//10000)*m          false
"    Unitful.mil
\nThe mil, a US customary unit of length defined as 1/1000 inch.
\nDimension: [`Unitful.𝐋`](@ref).
\nSee Also: [`Unitful.inch`](@ref)."
@unit mil       "mil"      Mil                  (1//1000)*inch          false
"    Unitful.ft
\nThe foot, a US customary unit of length defined as 12 inch.
\nDimension: [`Unitful.𝐋`](@ref).
\nSee Also: [`Unitful.inch`](@ref)."
@unit ft        "ft"       Foot                 12inch                  false
"    Unitful.yd
\nThe yard, a US customary unit of length defined as 3 ft.
\nDimension: [`Unitful.𝐋`](@ref).
\nSee Also: [`Unitful.ft`](@ref)."
@unit yd        "yd"       Yard                 3ft                     false
"    Unitful.mi
\nThe mile, a US customary unit of length defined as 1760 yd.
\nDimension: [`Unitful.𝐋`](@ref).
\nSee Also: [`Unitful.yd`](@ref)."
@unit mi        "mi"       Mile                 1760yd                  false
"    Unitful.angstrom
    Unitful.Å
\nThe angstrom, a metric unit of length defined as 1/10 nm.
\nDimension: [`Unitful.𝐋`](@ref).
\nSee Also: [`Unitful.nm`](@ref)."
@unit angstrom  "Å"        Angstrom             (1//10)*nm      false
@doc @doc(angstrom) const Å = angstrom

# Area
"    Unitful.ac
\nThe acre, a US customary unit of area defined as 4840 yd^2.
\nDimension: 𝐋^2.
\nSee Also: [`Unitful.yd`](@ref)."
@unit ac        "ac"       Acre                 (316160658//78125)*m^2  false

# Temperatures
"    Unitful.Ra
\nThe rankine, a US customary unit of temperature defined as 5/9 K.
\nDimension: [`Unitful.𝚯`](@ref).
\nSee Also: [`Unitful.K`](@ref)."
@unit Ra        "Ra"      Rankine               (5//9)*K                false
"    Unitful.°F
\nThe degree Fahrenheit, a US customary unit of temperature, defined such that 0 °F = 459.67 Ra.
\nDimension: [`Unitful.𝚯`](@ref).
\nSee also: [`Unitful.Ra`](@ref)."
@affineunit °F  "°F"      (45967//100)Ra

# Masses
"    Unitful.lb
\nThe pound-mass, a US customary unit of mass defined as exactly 0.453,592,37 kg.
\nDimension: [`Unitful.𝐌`](@ref).
\nSee Also: [`Unitful.kg`](@ref)."
@unit lb        "lb"       Pound                0.45359237kg            false # is exact
"    Unitful.oz
\nThe ounce, a US customary unit of mass defined as 1/16 lb.
\nDimension: [`Unitful.𝐌`](@ref).
\nSee Also: [`Unitful.lb`](@ref)."
@unit oz        "oz"       Ounce                lb//16                  false
"    Unitful.slug
\nThe slug, a US customary unit of mass defined as 1 lbf × s^2 / ft.
\nDimension: [`Unitful.𝐌`](@ref).
\nSee Also: [`Unitful.lbf`](@ref), [`Unitful.s`](@ref), [`Unitful.ft`](@ref)."
@unit slug      "slug"     Slug                 1lb*ge*s^2/ft           false
"    Unitful.dr
\nThe dram, a US customary unit of mass defined as 1/16 oz.
\nDimension: [`Unitful.𝐌`](@ref).
\nSee Also: [`Unitful.oz`](@ref)."
@unit dr        "dr"       Dram                 oz//16                  false
"    Unitful.gr
\nThe grain, a US customary unit of mass defined as 1/7000 lb.
\nDimension: [`Unitful.𝐌`](@ref).
\nSee Also: [`Unitful.lb`](@ref)."
@unit gr        "gr"       Grain                (32//875)*dr            false

# Force
"    Unitful.lbf
\nThe pound-force, a US customary unit of force defined as 1 lb × ge.
\nDimension: 𝐋 𝐌 𝐓^-2.
\nSee Also: [`Unitful.lb`](@ref), [`Unitful.ge`](@ref)."
@unit lbf       "lbf"      PoundsForce          1lb*ge                  false

# Energy
# Use ISO 31-4 for BTU definition
"    Unitful.cal
\nThe calorie, a unit of energy defined as exactly 4.184 J.
\nDimension: 𝐋^2 𝐌 𝐓^-2.
\nSee Also: [`Unitful.J`](@ref)."
@unit cal       "cal"      Calorie              4.184J                  true true
"    Unitful.btu
\nThe British thermal unit, a US customary unit of heat defined by ISO 31-4 as exactly 1055.06 J.
\nDimension: 𝐋^2 𝐌 𝐓^-2.
\nSee Also: [`Unitful.J`](@ref)."
@unit btu       "btu"      BritishThermalUnit   1055.06J                false

# Pressure
"    Unitful.psi
\nPounds per square inch, a US customary unit of pressure defined as 1 lbf / inch^2.
\nDimension: 𝐌 𝐋^-1 𝐓^-2.
\nSee Also: [`Unitful.lbf`](@ref), [`Unitful.inch`](@ref)."
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
isrootpower_dim(::typeof(𝐋^3))                  = false     # reflectivity
isrootpower_dim(::typeof(dimension(Ω)))         = true
isrootpower_dim(::typeof(dimension(S)))         = true
isrootpower_dim(::typeof(dimension(Hz)))        = false
isrootpower_dim(::typeof(dimension(J)))         = false

#########

# `using Unitful.DefaultSymbols` will bring the following into the calling namespace:
# - Dimensions 𝐋,𝐌,𝐓,𝐈,𝚯,𝐉,𝐍
# - Base and derived SI units, with SI prefixes
#   - Candela conflicts with `Base.cd` so it is not brought in (issue #102)
# - Degrees: °

const si_prefixes = (:y, :z, :a, :f, :p, :n, :μ, :m, :c, :d,
    Symbol(""), :da, :h, :k, :M, :G, :T, :P, :E, :Z, :Y)

const si_no_prefix = (:m, :s, :A, :K, :g, :mol, :rad, :sr, :Hz, :N, :Pa, #:cd,
    :J, :W, :C, :V, :F, :Ω, :S, :Wb, :T, :H, :lm, :lx, :Bq, :Gy, :Sv, :kat)

baremodule DefaultSymbols
    import Unitful

    for u in (:𝐋,:𝐌,:𝐓,:𝐈,:𝚯,:𝐉,:𝐍)
        Core.eval(DefaultSymbols, Expr(:import, Expr(:(.), :Unitful, u)))
        Core.eval(DefaultSymbols, Expr(:export, u))
    end

    for p in Unitful.si_prefixes
        for u in Unitful.si_no_prefix
            Core.eval(DefaultSymbols, Expr(:import, Expr(:(.), :Unitful, Symbol(p,u))))
            Core.eval(DefaultSymbols, Expr(:export, Symbol(p,u)))
        end
    end

    Core.eval(DefaultSymbols, Expr(:import, Expr(:(.), :Unitful, :°C)))
    Core.eval(DefaultSymbols, Expr(:export, :°C))

    Core.eval(DefaultSymbols, Expr(:import, Expr(:(.), :Unitful, :°)))
    Core.eval(DefaultSymbols, Expr(:export, :°))
end

#########

preferunits(kg) # others done in @refunit
# Fix documentation for all kg based units
for (k,v) in prefixdict
    if k != 3
        sym = Symbol(v,:g)
        docstring = """
                        Unitful.$sym

                    A prefixed unit, equal to 10^$(k-3) kg. Note that `kg`, not `g`, is the base unit.

                    Dimension: [`Unitful.𝐌`](@ref).

                    See also: [`Unitful.kg`](@ref).
                    """
        run = quote @doc $docstring $sym end
        eval(run)
    end
end
@doc "    Unitful.kg
\nThe kilogram, the SI base unit of mass.
Note that `kg`, not `g`, is the base unit.
\nDimension: [`Unitful.𝐌`](@ref)." kg

"""
    Unitful.promote_to_derived()
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

If you want this as default behavior (it was for versions of Unitful prior to 0.1.0),
consider invoking this function in your `startup.jl` file which is loaded when
you open Julia. This function is not exported.
"""
function promote_to_derived()
    eval(quote
         Unitful.promote_unit(::S, ::T) where
         {S<:EnergyFreeUnits, T<:EnergyFreeUnits} = Unitful.J
         Unitful.promote_unit(::S, ::T) where
         {S<:ForceFreeUnits, T<:ForceFreeUnits} = Unitful.N
         Unitful.promote_unit(::S, ::T) where
         {S<:PowerFreeUnits, T<:PowerFreeUnits} = Unitful.W
         Unitful.promote_unit(::S, ::T) where
         {S<:PressureFreeUnits, T<:PressureFreeUnits} = Unitful.Pa
         Unitful.promote_unit(::S, ::T) where
         {S<:ChargeFreeUnits, T<:ChargeFreeUnits} = Unitful.C
         Unitful.promote_unit(::S, ::T) where
         {S<:VoltageFreeUnits, T<:VoltageFreeUnits} = Unitful.V
         Unitful.promote_unit(::S, ::T) where
         {S<:ElectricalResistanceFreeUnits, T<:ElectricalResistanceFreeUnits} = Unitful.Ω
         Unitful.promote_unit(::S, ::T) where
         {S<:CapacitanceFreeUnits, T<:CapacitanceFreeUnits} = Unitful.F
         Unitful.promote_unit(::S, ::T) where
         {S<:InductanceFreeUnits, T<:InductanceFreeUnits} = Unitful.H
         Unitful.promote_unit(::S, ::T) where
         {S<:MagneticFluxFreeUnits, T<:MagneticFluxFreeUnits} = Unitful.Wb
         Unitful.promote_unit(::S, ::T) where
         {S<:BFieldFreeUnits, T<:BFieldFreeUnits} = Unitful.T
         Unitful.promote_unit(::S, ::T) where
         {S<:ActionFreeUnits, T<:ActionFreeUnits} = Unitful.J * Unitful.s
        end)
    nothing
end
