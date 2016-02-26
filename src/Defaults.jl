# Default symbols for refering to a unit in the REPL.
# Length
@uall m       _Meter
const µm = UnitData{(UnitDatum(_Meter,-6,1),)}()    # allow for Mac option-m mu
export µm
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

# Constants (2014 CODATA values unless otherwise noted)
export 𝛼, 𝛼⁻¹,  𝑐, ℎ, ℏ, 𝑘, k, Φ₀, mₑₚ, mₚₑ, mₑ, mₚ, mᵤ,
       alpha, invalpha, c, h, hbar, k, m_ep, m_pe, m_e, m_p, m_u
                                                                    # standard uncertainty  
const 𝛼    = 7.293_525_664e-3         # fine-structure constant        0.000_000_0017e-3
const alpha = 𝛼      
const 𝛼⁻¹  = 137.035_999_139          # inverse fine-structure const   0.000_000_031 
const invalpha = 𝛼⁻¹ 
const 𝑐    = 299_792_458*(m/s)        # speed of light in a vacuum     exact
const c    = 𝑐 
const ℎ    = 6.626_070_040e-34*(Js)   # Planck constant                0.000_000_081e-34*(Js)
const h    = ℎ  
const ℏ    = 1.054_571_800e-34*(Js)   # Planck constant / 2pi          0.000_000_013e-34*(Js)
const hbar = ℏ  
const 𝑘    = 1.38064852e-23*(J/K)     # Boltzmann constant             0.000_000_79e-23*(J/K)
const k    =  𝑘 
const Φ₀   = 2.067_833_831e-15*(Wb)   # magnetic flux quantum          0.000_000_013e-15(Wb)
const mₑₚ  = 5.446_170_213_52e-4      # electron-proton mass ratio     0.000_000_000_52e-4      
const m_ep = mₑₚ
const mₚₑ  = 1836.152_673_89          # proton-electron mass ratio     0.000_000_17 
const m_pe = mₚₑ
const mₑ   = 9.109_383_56e-31*(kg)    # electron mass                  0.000_000_11e-31*(kg)
const m_e  = mₑ  
const mₚ   = 1.672_621_898e-27*(kg)   # proton mass                    0.000_000_021e-27*(kg)
const m_p  = mₚ 
const mᵤ   = 1.660_539_040e-27*(kg)   # atomic mass constant           0.000_000_020_e-27*(kg)
const m_u  = mᵤ


# Default rules for addition and subtraction.
for op in [:+, :-]
    # Can change to min(x,y), x, or y
    @eval ($op)(x::UnitData, y::UnitData) = max(x,y)
end

# Default rules for unit simplification.
# WIP
