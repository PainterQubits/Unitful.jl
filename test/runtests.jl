module UnitfulTests

using Unitful
using Base.Test

import Unitful: DimensionError

import Unitful: m, ac, g, A, kg, cm, inch, mi, ft, °Ra, °F, °C, μm,
    s, A, K, N, mol, cd, rad, V, cm, hr, mm, km, minute, °, J

import Unitful: 𝐋, 𝐓, 𝐍

import Unitful:
    Length, Area, Volume,
    Luminosity,
    Time, Frequency,
    Mass,
    Current,
    Temperature,
    Action

import Unitful:
    LengthUnit, AreaUnit, MassUnit

if VERSION < v"0.6.0-dev.2390"  # Make LinSpace generic, PR 18777
    using Ranges
    linspace = Ranges.linspace
    LinSpace = Ranges.LinSpace
end

@testset "Type construction" begin
    @test typeof(𝐋) == Unitful.Dimensions{(Unitful.Dimension{:Length}(1),)}
    @test typeof(𝐋*𝐋) == typeof(𝐋^2)
    @test typeof(1.0m) ==
        Unitful.Quantity{Float64,
            typeof(𝐋),
            Unitful.Units{(Unitful.Unit{:Meter, typeof(𝐋)}(0, 1),),
                typeof(𝐋)}}
    @test typeof(1m^2) ==
        Unitful.Quantity{Int,
            typeof(𝐋^2),
            Unitful.Units{(Unitful.Unit{:Meter, typeof(𝐋)}(0, 2),),
                typeof(𝐋^2)}}
    @test typeof(1ac) ==
        Unitful.Quantity{Int,
            typeof(𝐋^2),
            Unitful.Units{(Unitful.Unit{:Acre, typeof(𝐋^2)}(0, 1),),
                typeof(𝐋^2)}}
end

@testset "Conversion" begin
    @testset "> Unitless ↔ unitful conversion" begin
        @test_throws DimensionError convert(typeof(3m),1)
        @test_throws DimensionError convert(Float64, 3m)
        @test @inferred(3m/unit(3m)) === 3
        @test @inferred(3.0g/unit(3.0g)) === 3.0
        @test @inferred(ustrip(3m)) === 3
        @test @inferred(ustrip(3)) === 3
        @test @inferred(ustrip(3.0m)) === 3.0
        @test convert(typeof(1mm/m),3) == 3000mm/m
        @test convert(Int, 1m/mm) === 1000

        # Issue 26
        @unit altL "altL" altLiter 1000*cm^3 true
        @test Float64(1altL/cm^3) === 1000.0
    end

    @testset "> Unitful ↔ unitful conversion" begin
        @testset ">> Numeric conversion" begin
            @test @inferred(float(3m)) === 3.0m
            @test @inferred(Integer(3.0A)) === 3A
            @test Rational(3.0m) === (3//1)*m
            @test typeof(convert(typeof(0.0°), 90°)) == typeof(0.0°)

        end
        @testset ">> Intra-unit conversion" begin
            @test @inferred(uconvert(g,1g)) === 1g
            # an essentially no-op uconvert should not disturb numeric type
            @test @inferred(uconvert(m,0x01*m)) === 0x01*m
            # test special case of temperature
            @test uconvert(°C, 0x01*°C) === 0x01*°C
            @test 1kg === 1kg
            @test typeof(1m)(1m) === 1m
        end
        @testset ">> Inter-unit conversion" begin
            @test 1kg == 1000g
            @test !(1kg === 1000g)
            @test 1inch == (254//100)*cm
            @test 1ft == 12inch
            @test 1/mi == 1//(5280ft)
            @test 1J == 1kg*m^2/s^2
            @test typeof(1cm)(1m) === 100cm
            @test @inferred(upreferred(N)) == kg*m/s^2
            @test @inferred(upreferred(dimension(N))) == kg*m/s^2
            # The following seems to have broken on the release-0.5 branch, I guess
            @static if VERSION >= v"0.6.0-dev+0" # works here, broken on 0.5.0
                @test @inferred(upreferred(1N)) === (1//1)*kg*m/s^2
            else
                @test upreferred(1N) === (1//1)*kg*m/s^2
            end
        end
        @testset ">> Temperature conversion" begin
            # When converting a pure temperature, offsets in temperature are
            # taken into account. If you like °Ra seek help
            @test @inferred(uconvert(°Ra, 4.2K)) ≈ 7.56°Ra
            @test uconvert(°F, 0°C) == 32°F
            @test uconvert(°C, 212°F) == 100°C

            # When appearing w/ other units, we calculate
            # by converting between temperature intervals (no offsets).
            # e.g. the linear thermal expansion coefficient of glass
            @test uconvert(μm/(m*°F), 9μm/(m*°C)) == 5μm/(m*°F)
        end
    end
end

@testset "Promotion" begin
    @testset "> Simple promotion" begin
        @test @inferred(promote(1.0m, 1m)) == (1.0m, 1.0m)
        @test @inferred(promote(1m, 1.0m)) == (1.0m, 1.0m)
        @test @inferred(promote(1.0m, 1kg)) == (1.0m, 1.0kg)
        @test @inferred(promote(1kg, 1.0m)) == (1.0kg, 1.0m)
        @test @inferred(promote(1.0m, 1)) == (1.0m, 1)
        @test @inferred(promote(1.0mm/m, 1.0km/m)) == (0.001,1000.0)
        @test @inferred(promote(1.0cm/m, 1.0mm/m, 1.0km/m)) == (0.01,0.001,1000.0)
        @test @inferred(promote(1.0rad,1.0°)) == (1.0,π/180.0)
    end

    @testset "> Promotion during array creation" begin
        @test typeof([1.0m,1.0m]) == Array{typeof(1.0m),1}
        @test typeof([1.0m,1m]) == Array{typeof(1.0m),1}
        @test typeof([1.0m,1cm]) == Array{typeof(1.0m),1}
        @test typeof([1kg,1g]) == Array{typeof(1kg//1),1}
        @test typeof([1.0m,1]) == Array{Quantity{Float64},1}
        @test typeof([1.0m,1kg]) == Array{Quantity{Float64},1}
        @test typeof([1.0m/s 1; 1 0]) == Array{Quantity{Float64},2}
    end
end

@testset "Unit string macro" begin
    @test macroexpand(:(u"m")) == :(Unitful.ustrcheck(Unitful.m))
    @test macroexpand(:(u"m,s")) ==
        :(Unitful.ustrcheck(Unitful.m), Unitful.ustrcheck(Unitful.s))
    @test macroexpand(:(u"1.0")) == 1.0
    @test macroexpand(:(u"m/s")) ==
        :(Unitful.ustrcheck(Unitful.m) / Unitful.ustrcheck(Unitful.s))
    @test macroexpand(:(u"1.0m/s")) ==
        :((1.0 * Unitful.ustrcheck(Unitful.m)) / Unitful.ustrcheck(Unitful.s))
    @test macroexpand(:(u"m^-1")) ==
        :(Unitful.ustrcheck(Unitful.m) ^ -1)
    @test isa(macroexpand(:(u"N m")).args[1], ParseError)
    @test isa(macroexpand(:(u"abs(2)")).args[1], ErrorException)

    # test ustrcheck(::Quantity)
    @test u"h" == Unitful.h

    # test ustrcheck(x) fallback to catch non-units / quantities
    @test_throws ErrorException u"ustrcheck"
end

@testset "Unit and dimensional analysis" begin
    @test @inferred(unit(1m^2)) == m^2
    @test @inferred(unit(typeof(1m^2))) == m^2
    @test @inferred(unit(Float64)) == NoUnits
    @test @inferred(dimension(1m^2)) == 𝐋^2
    @test @inferred(dimension(typeof(1m^2))) == 𝐋^2
    @test @inferred(dimension(Float64)) == NoDims
    @test @inferred(dimension(m^2)) == 𝐋^2
    @test @inferred(dimension(1m/s)) == 𝐋/𝐓
    @test @inferred(dimension(m/s)) == 𝐋/𝐓
    @test @inferred(dimension(1u"mol")) == 𝐍
    @test @inferred(dimension(μm/m)) == NoDims
    @test dimension([1u"m", 1u"s"]) == [𝐋, 𝐓]
    @test (𝐋/𝐓)^2 == 𝐋^2 / 𝐓^2
    @test isa(m, LengthUnit)
    @test !isa(m, AreaUnit)
    @test !isa(m, MassUnit)
    @test isa(m^2, AreaUnit)
    @test !isa(m^2, LengthUnit)
    @test isa(1m, Length)
    @test !isa(1m, LengthUnit)
    @test !isa(1m, Area)
    @test !isa(1m, Luminosity)
    @test isa(1ft, Length)
    @test isa(1m^2, Area)
    @test !isa(1m^2, Length)
    @test isa(1inch^3, Volume)
    @test isa(1/s, Frequency)
    @test isa(1kg, Mass)
    @test isa(1s, Time)
    @test isa(1A, Current)
    @test isa(1K, Temperature)
    @test isa(1cd, Luminosity)
    @test isa(2π*rad*1.0m, Length)
    @test isa(u"h", Action)
end

@testset "Mathematics" begin
    @testset "> Equality, comparison" begin
        @test 1m == 1m                        # Identity
        @test 3mm != 3*(m*m)                  # mm not interpreted as m*m
        @test 3*(m*m) != 3mm
        @test 1m != 1                         # w/ units distinct from w/o units
        @test 1 != 1m
        @test min(1hr, 1s) == 1s              # take scale of units into account
        @test max(1ft, 1m) == 1m
        @test max(10J, 1kg*m^2/s^2) === 10J
        @test max(1J//10, 1kg*m^2/s^2) === 1kg*m^2/s^2
        @test (3V+4V*im) != (3m+4m*im)
        @test (3V+4V*im) != (3+4im)
        @test (3+4im)*V == (3V+4V*im)
        @test V*(3+4im) == (3V+4V*im)
        @test (3.0+4.0im)*V == (3+4im)*V
        @test im*V == Complex(0,1)*V
        @test @inferred(2.0m < 3.0m)
        @test @inferred(2.0m .< 3.0m)
        @test !(3.0m .< 3.0m)
        @test @inferred(2.0m <= 3.0m)
        @test 3.0m <= 3.0m
        @test @inferred(2.0m .<= 3.0m)
        @test 3.0m .<= 3.0m
        @test @inferred(1μm/m < 1)
        @test @inferred(1 > 1μm/m)
        @test @inferred(1μm/m < 1mm/m)
        @test @inferred(1mm/m > 1μm/m)
        @test_throws DimensionError 1m < 1kg
        @test_throws DimensionError 1m < 1
        @test_throws DimensionError 1 < 1m
        @test_throws DimensionError 1mm/m < 1m
        @test @inferred(fma(2.0, 3.0m, 1.0m)) === 7.0m               # llvm good
        @test @inferred(fma(2.0, 3.0m, 35mm)) === 6.035m             # llvm good
        @test @inferred(fma(2.0m, 3.0, 35mm)) === 6.035m             # llvm good
        @test @inferred(fma(2.0m, 1.0/m, 3.0)) === 5.0               # llvm good
        @test @inferred(fma(2.0cm, 1.0/s, 3.0mm/s)) === .023m/s      # llvm good
        @test @inferred(fma(2m, 1/s, 3m/s)) === 5m/s                 # llvm good
        @test @inferred(fma(2, 1.0μm/m, 1)) === 1.000002             # llvm good
        @test @inferred(fma(1.0mm/m, 1.0mm/m, 1.0mm/m)) === 0.001001 # llvm good
        @test @inferred(fma(1.0mm/m, 1.0, 1.0)) ≈ 1.001              # llvm good
        @test @inferred(fma(1.0, 1.0μm/m, 1.0μm/m)) === 2.0μm/m      # llvm good
        @test @inferred(fma(2, 1.0, 1μm/m)) === 2.000001             # llvm BAD
        @static if VERSION >= v"0.6.0-dev+0"    # works here, broken on 0.5.0
            @test @inferred(fma(2, 1μm/m, 1mm/m)) === 501//500000    # llvm BAD
        else
            @test fma(2, 1μm/m, 1mm/m) === 501//500000               # llvm BAD
        end
        @test @inferred(muladd(2.0, 3.0m, 1.0m)) === 7.0m
        @test @inferred(muladd(2.0, 3.0m, 35mm)) === 6.035m
        @test @inferred(muladd(2.0m, 3.0, 35mm)) === 6.035m
        @test @inferred(muladd(2.0m, 1.0/m, 3.0)) === 5.0
        @test @inferred(muladd(2.0cm, 1.0/s, 3.0mm/s)) === .023m/s
        @test @inferred(muladd(2m, 1/s, 3m/s)) === 5m/s
        @test @inferred(muladd(2, 1.0μm/m, 1)) === 1.000002
        @test @inferred(muladd(1.0mm/m, 1.0mm/m, 1.0mm/m)) === 0.001001
        @test @inferred(muladd(1.0mm/m, 1.0, 1.0)) ≈ 1.001
        @test @inferred(muladd(1.0, 1.0μm/m, 1.0μm/m)) === 2.0μm/m
        @test @inferred(muladd(2, 1.0, 1μm/m)) === 2.000001
        @static if VERSION >= v"0.6.0-dev+0"    # works here, broken on 0.5.0
            @test @inferred(muladd(2, 1μm/m, 1mm/m)) === 501//500000
        else
            @test muladd(2, 1μm/m, 1mm/m) === 501//500000
        end
        @test_throws DimensionError fma(2m, 1/m, 1m)
        @test_throws DimensionError fma(2, 1m, 1V)
    end

    @testset "> Addition and subtraction" begin
        @test @inferred(+(1A)) == 1A                     # Unary addition
        @test @inferred(3m + 3m) == 6m                   # Binary addition
        @test @inferred(-(1kg)) == (-1)*kg               # Unary subtraction
        @test @inferred(3m - 2m) == 1m                   # Binary subtraction
        @test @inferred(zero(1m)) === 0m                 # Additive identity
        @test @inferred(zero(typeof(1m))) === 0m
        @test @inferred(zero(typeof(1.0m))) === 0.0m
        @test @inferred(π/2*u"rad" + 90u"°") ≈ π         # Dimless quantities
        @test @inferred(π/2*u"rad" - 90u"°") ≈ 0         # Dimless quantities
        @test_throws DimensionError 1+1m         # Dim mismatched
        @test_throws DimensionError 1-1m
    end

    @testset "> Multiplication" begin
        @test @inferred(*(1s)) == 1s                     # Unary multiplication
        @test @inferred(3m * 2cm) == 3cm * 2m            # Binary multiplication
        @test @inferred((3m)*m) == 3*(m*m)               # Associative multiplication
        @test @inferred(true*1kg) == 1kg                 # Boolean multiplication (T)
        @test @inferred(false*1kg) == 0kg                # Boolean multiplication (F)
    end

    @testset "> Division" begin
        @test 2m // 5s == (2//5)*(m/s)        # Units propagate through rationals
        @test (2//3)*m // 5 == (2//15)*m      # Quantity // Real
        @test 5.0m // s === 5.0m/s            # Quantity // Unit. Just pass units through
        @test s//(5m) === (1//5)*s/m          # Unit // Quantity. Will fail if denom is float
        @test (m//2) === 1//2 * m             # Unit // Real
        @test (2//m) === (2//1) / m           # Real // Unit
        @test (m//s) === m/s                  # Unit // Unit
        @test div(10m, -3cm) == -333.0
        @test fld(10m, -3cm) == -334.0
        @test rem(10m, -3cm) == 1.0cm
        @test mod(10m, -3cm) == -2.0cm
        @test mod(1hr+3minute+5s, 24s) == 17s
        @test inv(s) == s^-1
    end

    @testset "> Exponentiation" begin
        @test @inferred(m^3/m) == m^2
        @test @inferred(𝐋^3/𝐋) == 𝐋^2
        @test @inferred(sqrt(4m^2)) == 2m
        @test sqrt(4m^(2//3)) == 2m^(1//3)
        @test @inferred(sqrt(𝐋^2)) == 𝐋
        @test @inferred(sqrt(m^2)) == m
        @test @inferred(cbrt(8m^3)) == 2m
        @test cbrt(8m) == 2m^(1//3)
        @test @inferred(cbrt(𝐋^3)) == 𝐋
        @test @inferred(cbrt(m^3)) == m
        @test (2m)^3 == 8*m^3
        @test (8m)^(1//3) == 2*m^(1//3)
        @test @inferred(cis(90°)) ≈ im

        # Test inferrability of small integer literal powers
        _pow_m1(x) = x^-1
        _pow_m2(x) = x^-2
        _pow_m3(x) = x^-3
        _pow_0(x) = x^0
        _pow_1(x) = x^1
        _pow_2(x) = x^2
        _pow_3(x) = x^3
        _pow_4(x) = x^4

        @test @inferred(_pow_m1(m)) == m^-1
        @test @inferred(_pow_m2(m)) == m^-2
        @test @inferred(_pow_m3(m)) == m^-3
        @test @inferred(_pow_0(m)) == NoUnits
        @test @inferred(_pow_1(m)) == m
        @test @inferred(_pow_2(m)) == m^2
        @test @inferred(_pow_3(m)) == m^3
        @test_throws ErrorException @inferred(_pow_4(m))

        @test @inferred(_pow_m1(𝐋)) == 𝐋^-1
        @test @inferred(_pow_m2(𝐋)) == 𝐋^-2
        @test @inferred(_pow_m3(𝐋)) == 𝐋^-3
        @test @inferred(_pow_0(𝐋)) == NoDims
        @test @inferred(_pow_1(𝐋)) == 𝐋
        @test @inferred(_pow_2(𝐋)) == 𝐋^2
        @test @inferred(_pow_3(𝐋)) == 𝐋^3
        @test_throws ErrorException @inferred(_pow_4(𝐋))

        @test @inferred(_pow_m1(1.0m)) == 1.0m^-1
        @test @inferred(_pow_m2(1.0m)) == 1.0m^-2
        @test @inferred(_pow_m3(1.0m)) == 1.0m^-3
        @test @inferred(_pow_0(1.0m)) == 1.0
        @test @inferred(_pow_1(1.0m)) == 1.0m
        @test @inferred(_pow_2(1.0m)) == 1.0m^2
        @test @inferred(_pow_3(1.0m)) == 1.0m^3
        @test_throws ErrorException @inferred(_pow_4(1.0m))
    end

    @testset "> Trigonometry" begin
        @test @inferred(sin(0.0rad)) == 0.0
        @test @inferred(cos(π*rad)) == -1
        @test @inferred(tan(π*rad/4)) ≈ 1
        @test @inferred(csc(π*rad/2)) == 1
        @test @inferred(sec(0.0*rad)) == 1
        @test @inferred(cot(π*rad/4)) ≈ 1
        @test @inferred(sin(90.0°)) == 1
            # note that there is a type instability for sind(90) on 0.5.0 which
            # is gone in the nightlies, so for now I changed 90° to 90.0°
        @test @inferred(cos(0.0°)) == 1
        @test @inferred(tan(45°)) == 1
        @test @inferred(csc(90°)) == 1
        @test @inferred(sec(0°)) == 1
        @test @inferred(cot(45°)) == 1
        @test @inferred(atan2(m*sqrt(3),1m)) ≈ 60°
    end

    @testset "> Matrix inversion" begin
        @test inv([1 1; -1 1]u"nm") ≈ [0.5 -0.5; 0.5 0.5]u"nm^-1"
    end

    @testset "> Is functions" begin
        @test isinteger(1.0m)
        @test !isinteger(1.4m)
        @test isfinite(1.0m)
        @test !isfinite(Inf*m)
        @test isnan(NaN*m)
        @test !isnan(1.0m)
    end

    @testset "> Floating point tests" begin
        @test isapprox(1.0u"m",(1.0+eps(1.0))u"m")
        @test isapprox(1.0u"μm/m",1e-6)
        @test !isapprox(1.0u"μm/m",1e-7)
        @test_throws DimensionError isapprox(1.0u"m",5)
        @test frexp(1.5m) == (0.75m, 1.0)
        @test unit(nextfloat(0.0m)) == m
        @test unit(prevfloat(0.0m)) == m
    end

    @testset "> fastmath" begin
        const one32 = one(Float32)*m
        const eps32 = eps(Float32)*m
        const eps32_2 = eps32/2

        # Note: Cannot use local functions since these are not yet optimized
        fm_ieee_32(x) = x + eps32_2 + eps32_2
        fm_fast_32(x) = @fastmath x + eps32_2 + eps32_2
        @test fm_ieee_32(one32) == one32
        @test (fm_fast_32(one32) == one32 ||
            fm_fast_32(one32) == one32 + eps32 > one32)

        const one64 = one(Float64)*m
        const eps64 = eps(Float64)*m
        const eps64_2 = eps64/2

        # Note: Cannot use local functions since these are not yet optimized
        fm_ieee_64(x) = x + eps64_2 + eps64_2
        fm_fast_64(x) = @fastmath x + eps64_2 + eps64_2
        @test fm_ieee_64(one64) == one64
        @test (fm_fast_64(one64) == one64 ||
            fm_fast_64(one64) == one64 + eps64 > one64)

        # check updating operators
        fm_ieee_64_upd(x) = (r=x; r+=eps64_2; r+=eps64_2)
        fm_fast_64_upd(x) = @fastmath (r=x; r+=eps64_2; r+=eps64_2)
        @test fm_ieee_64_upd(one64) == one64
        @test (fm_fast_64_upd(one64) == one64 ||
            fm_fast_64_upd(one64) == one64 + eps64 > one64)

        for T in (Float32, Float64, BigFloat)
            _zero = convert(T, 0)*m
            _one = convert(T, 1)*m + eps(T)*m
            _two = convert(T, 2)*m + 1m//10
            _three = convert(T, 3)*m + 1m//100

            @test isapprox((@fastmath +_two), +_two)
            @test isapprox((@fastmath -_two), -_two)
            @test isapprox((@fastmath _zero+_one+_two), _zero+_one+_two)
            @test isapprox((@fastmath _zero-_one-_two), _zero-_one-_two)
            @test isapprox((@fastmath _one*_two*_three), _one*_two*_three)
            @test isapprox((@fastmath _one/_two/_three), _one/_two/_three)
            @test isapprox((@fastmath rem(_two, _three)), rem(_two, _three))
            @test isapprox((@fastmath mod(_two, _three)), mod(_two, _three))
            @test (@fastmath cmp(_two, _two)) == cmp(_two, _two)
            @test (@fastmath cmp(_two, _three)) == cmp(_two, _three)
            @test (@fastmath cmp(_three, _two)) == cmp(_three, _two)
            @test (@fastmath _one/_zero) == convert(T, Inf)
            @test (@fastmath -_one/_zero) == -convert(T, Inf)
            @test isnan(@fastmath _zero/_zero) # must not throw

            for x in (_zero, _two, convert(T, Inf)*m, convert(T, NaN)*m)
                @test (@fastmath isfinite(x))
                @test !(@fastmath isinf(x))
                @test !(@fastmath isnan(x))
                @test !(@fastmath issubnormal(x))
            end
        end

        for T in (Complex64, Complex128, Complex{BigFloat})
            _zero = convert(T, 0)*m
            _one = convert(T, 1)*m + im*eps(real(convert(T,1)))*m
            _two = convert(T, 2)*m + im*m//10
            _three = convert(T, 3)*m + im*m//100

            @test isapprox((@fastmath +_two), +_two)
            @test isapprox((@fastmath -_two), -_two)
            @test isapprox((@fastmath _zero+_one+_two), _zero+_one+_two)
            @test isapprox((@fastmath _zero-_one-_two), _zero-_one-_two)
            @test isapprox((@fastmath _one*_two*_three), _one*_two*_three)
            @test isapprox((@fastmath _one/_two/_three), _one/_two/_three)
            @test (@fastmath _three == _two) == (_three == _two)
            @test (@fastmath _three != _two) == (_three != _two)
            @test isnan(@fastmath _one/_zero)  # must not throw
            @test isnan(@fastmath -_one/_zero) # must not throw
            @test isnan(@fastmath _zero/_zero) # must not throw

            for x in (_zero, _two, convert(T, Inf)*m, convert(T, NaN)*m)
                @test (@fastmath isfinite(x))
                @test !(@fastmath isinf(x))
                @test !(@fastmath isnan(x))
                @test !(@fastmath issubnormal(x))
            end
        end


        # real arithmetic
        for T in (Float32, Float64, BigFloat)
            half = 1m/convert(T, 2)
            third = 1m/convert(T, 3)

            for f in (:+, :-, :abs, :abs2, :conj, :inv, :sign, :sqrt)
                @test isapprox((@eval @fastmath $f($half)), (@eval $f($half)))
                @test isapprox((@eval @fastmath $f($third)), (@eval $f($third)))
            end
            for f in (:+, :-, :*, :/, :%, :(==), :!=, :<, :<=, :>, :>=,
                      :atan2, :hypot, :max, :min)
                @test isapprox((@eval @fastmath $f($half, $third)),
                               (@eval $f($half, $third)))
                @test isapprox((@eval @fastmath $f($third, $half)),
                               (@eval $f($third, $half)))
            end
            for f in (:minmax,)
                @test isapprox((@eval @fastmath $f($half, $third))[1],
                               (@eval $f($half, $third))[1])
                @test isapprox((@eval @fastmath $f($half, $third))[2],
                               (@eval $f($half, $third))[2])
                @test isapprox((@eval @fastmath $f($third, $half))[1],
                               (@eval $f($third, $half))[1])
                @test isapprox((@eval @fastmath $f($third, $half))[2],
                               (@eval $f($third, $half))[2])
            end

            half = 1°/convert(T, 2)
            third = 1°/convert(T, 3)
            for f in (:cos, :sin, :tan)
                @test isapprox((@eval @fastmath $f($half)), (@eval $f($half)))
                @test isapprox((@eval @fastmath $f($third)), (@eval $f($third)))
            end
        end

        # complex arithmetic
        for T in (Complex64, Complex128, Complex{BigFloat})
            half = (1+1im)V/T(2)
            third = (1-1im)V/T(3)

            # some of these functions promote their result to double
            # precision, but we want to check equality at precision T
            rtol = Base.rtoldefault(real(T))

            for f in (:+, :-, :abs, :abs2, :conj, :inv, :sign, :sqrt)
                @test isapprox((@eval @fastmath $f($half)), (@eval $f($half)), rtol=rtol)
                @test isapprox((@eval @fastmath $f($third)), (@eval $f($third)), rtol=rtol)
            end
            for f in (:+, :-, :*, :/, :(==), :!=)
                @test isapprox((@eval @fastmath $f($half, $third)),
                               (@eval $f($half, $third)), rtol=rtol)
                @test isapprox((@eval @fastmath $f($third, $half)),
                               (@eval $f($third, $half)), rtol=rtol)
            end

            _d = 90°/T(2)
            @test isapprox((@fastmath cis(_d)), cis(_d))
        end

        # mixed real/complex arithmetic
        for T in (Float32, Float64, BigFloat)
            CT = Complex{T}
            half = 1V/T(2)
            third = 1V/T(3)
            chalf = (1+1im)V/CT(2)
            cthird = (1-1im)V/CT(3)

            for f in (:+, :-, :*, :/, :(==), :!=)
                @test isapprox((@eval @fastmath $f($chalf, $third)),
                               (@eval $f($chalf, $third)))
                @test isapprox((@eval @fastmath $f($half, $cthird)),
                               (@eval $f($half, $cthird)))
                @test isapprox((@eval @fastmath $f($cthird, $half)),
                               (@eval $f($cthird, $half)))
                @test isapprox((@eval @fastmath $f($third, $chalf)),
                               (@eval $f($third, $chalf)))
            end

            @test isapprox((@fastmath third^3), third^3)
            @test isapprox((@fastmath chalf/third), chalf/third)
            @test isapprox((@fastmath chalf^3), chalf^3)
        end
    end
end

@testset "Rounding" begin
    @test @inferred(trunc(3.7m)) == 3.0m
    @test trunc(-3.7m) == -3.0m
    @test @inferred(floor(3.7m)) == 3.0m
    @test floor(-3.7m) == -4.0m
    @test @inferred(ceil(3.7m)) == 4.0m
    @test ceil(-3.7m) == -3.0m
    @test @inferred(round(3.7m)) == 4.0m
    @test round(-3.7m) == -4.0m
end

@testset "Sgn, abs, &c." begin
    @test @inferred(abs(3V+4V*im)) == 5V
    @test @inferred(norm(3V+4V*im)) == 5V
    @test @inferred(abs2(3V+4V*im)) == 25V^2
    @test @inferred(abs(-3m)) == 3m
    @test @inferred(abs2(-3m)) == 9m^2
    @test @inferred(sign(-3.3m)) == -1.0
    @test @inferred(signbit(0.0m)) == false
    @test @inferred(signbit(-0.0m)) == true
    @test @inferred(copysign(3.0m, -4.0s)) == -3.0m
    @test @inferred(copysign(3.0m, 4)) == 3.0m
    @test @inferred(flipsign(3.0m, -4)) == -3.0m
    @test @inferred(flipsign(-3.0m, -4)) == 3.0m
    @test @inferred(real(3m)) == 3.0m
    @test @inferred(real((3+4im)V)) == 3V
    @test @inferred(imag(3m)) == 0m
    @test @inferred(imag((3+4im)V)) == 4V
    @test @inferred(conj(3m)) == 3m
    @test @inferred(conj((3+4im)V)) == (3-4im)V
    @test @inferred(typemin(1.0m)) == -Inf*m
    @test @inferred(typemax(typeof(1.0m))) == Inf*m
    @test @inferred(typemin(0x01m)) == 0x00m
    @test @inferred(typemax(typeof(0x01m))) == 0xffm
end

@testset "Collections" begin

    @testset "> Ranges" begin

        @testset ">> Some of test/ranges.jl, with units" begin
            @test @inferred(size(10m:1m:0m)) == (0,)
            @test length(1m:.2m:2m) == 6
            @test length(1.0m:.2m:2.0m) == 6
            @test length(2m:-.2m:1m) == 6
            @test length(2.0m:-.2m:1.0m) == 6
            @test @inferred(length(2m:.2m:1m)) == 0
            @test length(2.0m:.2m:1.0m) == 0

            @test length(1m:2m:0m) == 0
            L32 = linspace(Int32(1)*m, Int32(4)*m, 4)
            L64 = linspace(Int64(1)*m, Int64(4)*m, 4)
            @test L32[1] == 1m && L64[1] == 1m
            @test L32[2] == 2m && L64[2] == 2m
            @test L32[3] == 3m && L64[3] == 3m
            @test L32[4] == 4m && L64[4] == 4m

            r = 5m:-1m:1m
            @test @inferred(r[1])==5m
            @test r[2]==4m
            @test r[3]==3m
            @test r[4]==2m
            @test r[5]==1m

            @test length(.1m:.1m:.3m) == 3
            # @test length(1.1m:1.1m:3.3m) == 3
            @test @inferred(length(1.1m:1.3m:3m)) == 2
            @test length(1m:1m:1.8m) == 1

            @test (1m:2m:13m)[2:6] == 3m:2m:11m
            @test typeof((1m:2m:13m)[2:6]) == typeof(3m:2m:11m)
            @test (1m:2m:13m)[2:3:7] == 3m:6m:13m
            @test typeof((1m:2m:13m)[2:3:7]) == typeof(3m:6m:13m)
        end

        @testset ">> StepRange" begin
            r = @inferred(colon(1m, 1m, 5m)) # 1m:1m:5m
            @test isa(r, StepRange)
            @test @inferred(length(r)) === 5
            @test @inferred(step(r)) === 1m
        end

        @testset ">> Float StepRange" begin
            # @test isa(@inferred(colon(1.0m, 1m, 5m)), StepRange{typeof(1.0m)})
            @test @inferred(length(1.0m:1m:5m)) === 5
            @test @inferred(step(1.0m:1m:5m)) === 1.0m

            @test_throws ArgumentError 1.0m:0.0m:5.0m
        end
        @testset ">> LinSpace" begin
            # Behavior of `linspace` changed, so results differ depending on
            # which version of Julia you are running...
            @static if VERSION < v"0.6.0-dev.2390" # Make LinSpace generic, PR 18777
                @test isa(@inferred(linspace(1.0m, 3.0m, 5)), LinSpace{typeof(1.0m)})
                @test isa(@inferred(linspace(1.0m, 10m, 5)), LinSpace{typeof(1.0m)})
                @test isa(@inferred(linspace(1m, 10.0m, 5)), LinSpace{typeof(1.0m)})
                @test isa(@inferred(linspace(1m, 10m, 5)), LinSpace{typeof(1.0m)})
            else
                @test isa(@inferred(linspace(1.0m, 3.0m, 5)),
                    StepRangeLen{typeof(1.0m), Base.TwicePrecision{typeof(1.0m)}})
                @test isa(@inferred(linspace(1.0m, 10m, 5)),
                    StepRangeLen{typeof(1.0m), Base.TwicePrecision{typeof(1.0m)}})
                @test isa(@inferred(linspace(1m, 10.0m, 5)),
                    StepRangeLen{typeof(1.0m), Base.TwicePrecision{typeof(1.0m)}})
                @test isa(@inferred(linspace(1m, 10m, 5)),
                    StepRangeLen{typeof(1.0m), Base.TwicePrecision{typeof(1.0m)}})
            end
            @test_throws Unitful.DimensionError linspace(1m, 10, 5)
            @test_throws Unitful.DimensionError linspace(1, 10m, 5)
        end

        @testset ">> Range → Range" begin
            # @test isa((1m:5m)*2, StepRange)
            # @test isa((1m:5m)/2, FloatRange)
            # @test isa((1m:2m:5m)/2, FloatRange)
        end

        @testset ">> Range → Array" begin
            @test isa(collect(1m:1m:5m), Array{typeof(1m),1})
            @test isa(collect(1m:2m:10m), Array{typeof(1m),1})
            @test isa(collect(1.0m:2m:10m), Array{typeof(1.0m),1})
            @test isa(collect(linspace(1.0m,10.0m,5)), Array{typeof(1.0m),1})
        end

        @testset ">> unit multiplication" begin
            @test @inferred((1:5)*mm) === 1mm:1mm:5mm
            @test @inferred((1:2:5)*mm) === 1mm:2mm:5mm
            @test @inferred((1.0:2.0:5.01)*mm) === 1.0mm:2.0mm:5.0mm
        end
    end

    @testset "> Arrays" begin
        @testset ">> Array multiplication" begin
            # Quantity, quantity
            @static if VERSION >= v"0.6.0-dev.2074" # RowVector, PR 19670
                @test @inferred([1m, 2m]' * [3m, 4m])    == 11m^2
                @test @inferred([1m, 2m]' * [3/m, 4/m])  == 11
                @test typeof([1m, 2m]' * [3/m, 4/m])     == Int
                @test typeof([1m, 2V]' * [3/m, 4/V])     == Int
            else
                @test @inferred([1m, 2m]' * [3m, 4m])    == [11m^2]
                @test @inferred([1m, 2m]' * [3/m, 4/m])  == [11]
                @test typeof([1m, 2m]' * [3/m, 4/m])     == Array{Int,1}
                @test typeof([1m, 2V]' * [3/m, 4/V])     == Array{Int,1}
            end
            @test @inferred([1V,2V]*[0.1/m, 0.4/m]') == [0.1V/m 0.4V/m; 0.2V/m 0.8V/m]

            @static if VERSION >= v"0.6.0-" # Probably broken as soon as we stopped
                                            # using custom promote_op methods
                @test_broken @inferred([1m, 2V]' * [3/m, 4/V])  == [11]
                @test_broken @inferred([1m, 2V] * [3/m, 4/V]') ==
                    [3 4u"m*V^-1"; 6u"V*m^-1" 8]
            else
                @test @inferred([1m, 2V]' * [3/m, 4/V])  == [11]
                @test @inferred([1m, 2V] * [3/m, 4/V]') ==
                    [3 4u"m*V^-1"; 6u"V*m^-1" 8]
            end

            # Quantity, number or vice versa
            @test @inferred([1 2] * [3m,4m])         == [11m]
            @test typeof([1 2] * [3m,4m])            == Array{typeof(1u"m"),1}
            @test @inferred([3m 4m] * [1,2])         == [11m]
            @test typeof([3m 4m] * [1,2])            == Array{typeof(1u"m"),1}

            @test @inferred([1,2] * [3m,4m]')    == [3m 4m; 6m 8m]
            @test typeof([1,2] * [3m,4m]')       == Array{typeof(1u"m"),2}
            @test @inferred([3m,4m] * [1,2]')    == [3m 6m; 4m 8m]
            @test typeof([3m,4m] * [1,2]')       == Array{typeof(1u"m"),2}

            # re-allow vector*(1-row matrix), PR 20423
            @static if VERSION >= v"0.6.0-dev.2614" || # re-allow vector*(1-row matrix), PR 20423
                       VERSION < v"0.6.0-dev.2074"     # RowVector, PR 19670
                @test @inferred([1,2] * [3m 4m])     == [3m 4m; 6m 8m]
                @test typeof([1,2] * [3m 4m])        == Array{typeof(1u"m"),2}
                @test @inferred([3m,4m] * [1 2])     == [3m 6m; 4m 8m]
                @test typeof([3m,4m] * [1 2])        == Array{typeof(1u"m"),2}
            end
        end

        @testset ">> Element-wise multiplication" begin
            @test @inferred([1m, 2m, 3m] * 5)          == [5m, 10m, 15m]
            @test typeof([1m, 2m, 3m] * 5)             == Array{typeof(1u"m"),1}
            @test @inferred([1m, 2m, 3m] .* 5m)        == [5m^2, 10m^2, 15m^2]
            @test typeof([1m, 2m, 3m] * 5m)            == Array{typeof(1u"m^2"),1}
            @test @inferred(5m .* [1m, 2m, 3m])        == [5m^2, 10m^2, 15m^2]
            @test typeof(5m .* [1m, 2m, 3m])           == Array{typeof(1u"m^2"),1}
            @test @inferred(eye(2)*V)                  == [1.0V 0.0V; 0.0V 1.0V]
            @test @inferred(V*eye(2))                  == [1.0V 0.0V; 0.0V 1.0V]
            @static if VERSION >= v"0.6.0-dev.1632" # Make dot ops fusing, PR 17623
                @test_broken @inferred(eye(2).*V)      == [1.0V 0.0V; 0.0V 1.0V]
                @test_broken @inferred(V.*eye(2))      == [1.0V 0.0V; 0.0V 1.0V]
            else
                @test @inferred(eye(2).*V)             == [1.0V 0.0V; 0.0V 1.0V]
                @test @inferred(V.*eye(2))             == [1.0V 0.0V; 0.0V 1.0V]
            end
            @test @inferred([1V 2V; 0V 3V].*2)         == [2V 4V; 0V 6V]
            @test @inferred([1V, 2V] .* [true, false]) == [1V, 0V]
            @test @inferred([1.0m, 2.0m] ./ 3)         == [1m/3, 2m/3]
            @test @inferred([1V, 2.0V] ./ [3m, 4m])    == [1V/(3m), 0.5V/m]

            @test @inferred([1, 2]kg)                  == [1, 2] * kg
            @test @inferred([1, 2]kg .* [2, 3]kg^-1)   == [2, 6]
        end

        @testset ">> Array addition" begin
            @test @inferred([1m, 2m] + [3m, 4m])     == [4m, 6m]
            @test @inferred([1m, 2m] + [1m, 1cm])    == [2m, 201m//100]
            @test @inferred([1m] + [1cm])            == [(101//100)*m]

            # Dimensionless quantities
            @test @inferred([1mm/m] + [1.0cm/m])     == [0.011]
            @test typeof([1mm/m] + [1.0cm/m])        == Array{Float64,1}
            @test @inferred([1mm/m] + [1cm/m])       == [11//1000]
            @test typeof([1mm/m] + [1cm/m])          == Array{Rational{Int},1}
            @test @inferred([1mm/m] + [2])           == [2001//1000]
            @test typeof([1mm/m] + [2])              == Array{Rational{Int},1}
            @test_throws DimensionError [1m] + [2V]
            @test_throws DimensionError [1] + [1m]
        end

        @testset ">> Element-wise addition" begin
            @test @inferred(5m .+ [1m, 2m, 3m])      == [6m, 7m, 8m]
        end

        @testset ">> Element-wise comparison" begin
            @test @inferred([0.0m, 2.0m] .< [3.0m, 2.0μm]) == BitArray([true,false])
            @test @inferred([0.0m, 2.0m] .> [3.0m, 2.0μm]) == BitArray([false,true])
            @test @inferred([0.0m, 0.0μm] .<= [0.0mm, 0.0mm]) == BitArray([true, true])
            @test @inferred([0.0m, 0.0μm] .>= [0.0mm, 0.0mm]) == BitArray([true, true])
            @test @inferred([0.0m, 0.0μm] .== [0.0mm, 0.0mm]) == BitArray([true, true])

            # Want to make sure we play nicely with StaticArrays
            for j in (<, <=, >, >=, ==)
                @test @inferred(Base.promote_op(j, typeof(1.0m), typeof(1.0μm))) == Bool
            end
        end

        @testset ">> isapprox on arrays" begin
            @test !isapprox([1.0m], [1.0V])
            @test isapprox([1.0μm/m], [1e-6])
            @test isapprox([1cm, 200cm], [0.01m, 2.0m])
            @test !isapprox([1.0], [1.0m])
            @test !isapprox([1.0m], [1.0])
        end

        @testset ">> Unit stripping" begin
            @test @inferred(ustrip([1u"m", 2u"m"])) == [1,2]
            @test @inferred(ustrip([1,2])) == [1,2]
            @test typeof(ustrip([1u"m", 2u"m"])) == Array{Int,1}
            @test typeof(ustrip(Diagonal([1,2]u"m"))) == Diagonal{Int}
            @test typeof(ustrip(Bidiagonal([1,2,3]u"m", [1,2]u"m", true))) ==
                Bidiagonal{Int}
            @test typeof(ustrip(Tridiagonal([1,2]u"m", [3,4,5]u"m", [6,7]u"m"))) ==
                Tridiagonal{Int}
            @test typeof(ustrip(SymTridiagonal([1,2,3]u"m", [4,5]u"m"))) ==
                SymTridiagonal{Int}
        end

        @testset ">> Linear algebra" begin
            @test istril([1 1; 0 1]u"m") == false
            @test istriu([1 1; 0 1]u"m") == true
        end
    end
end

# Test that the @u_str macro will find units in other modules.
module ShadowUnits
    using Unitful
    @unit m "m" MyMeter 1u"m" false
    Unitful.register(ShadowUnits)
end

let fname = tempname()
    try
        ret = open(fname, "w") do f
            redirect_stderr(f) do
                # wrap in eval to catch the STDERR output...
                @test eval(:(typeof(u"m"))) == Unitful.Units{
                    (Unitful.Unit{:MyMeter,Unitful.Dimensions{
                    (Unitful.Dimension{:Length}(1//1),)}}(0,1//1),),
                    Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}}
            end
        end
    finally
        rm(fname, force=true)
    end
end

@static if VERSION >= v"0.6.0-dev.1980" # test_warn PR 19903
    # check for the warning...
    @test_warn "ShadowUnits" eval(:(u"m"))
end

# Test to make sure user macros are working properly
# (and incidentally, for Compat macro hygiene in @dimension, @derived_dimension)
module TUM
    using Unitful
    using Base.Test

    @dimension f "f" FakeDim12345
    @derived_dimension FakeDim212345 f^2
    @refunit fu "fu" FakeUnit12345 f false
    @unit fu2 "fu2" FakeUnit212345 1fu false
end

@testset "User macros" begin
    @test typeof(TUM.f) == Unitful.Dimensions{(Unitful.Dimension{:FakeDim12345}(1//1),)}
    @test 1(TUM.fu) == 1(TUM.fu2)
    @test isa(1(TUM.fu), TUM.FakeDim12345)
    @test isa(TUM.fu, TUM.FakeDim12345Unit)
    @test isa(1(TUM.fu)^2, TUM.FakeDim212345)
    @test isa(TUM.fu^2, TUM.FakeDim212345Unit)
end

end
