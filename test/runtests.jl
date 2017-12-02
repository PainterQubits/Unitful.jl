module UnitfulTests

using Unitful
using Compat.Test
import Unitful: DimensionError

import Unitful: LogScaled, LogInfo, Level, Gain, MixedUnits, Decibel

import Unitful: FreeUnits, ContextUnits, FixedUnits

import Unitful:
    nm, μm, mm, cm, m, km, inch, ft, mi,
    ac,
    mg, g, kg, A,
    °Ra, °F, °C, K,
    rad, °,
    ms, s, minute, hr,
    J, A, N, mol, cd, V,
    mW, W, Hz

import Unitful: dB, dBm, dBV, dBSPL, Np

import Unitful: 𝐋, 𝐓, 𝐍

import Unitful:
    Length, Area, Volume,
    Luminosity,
    Time, Frequency,
    Mass,
    Current,
    Temperature,
    Action,
    Power

import Unitful: LengthUnits, AreaUnits, MassUnits

@testset "Construction" begin
    @test isa(NoUnits, FreeUnits)
    @test typeof(𝐋) === Unitful.Dimensions{(Unitful.Dimension{:Length}(1),)}
    @test 𝐋*𝐋 === 𝐋^2
    @test typeof(1.0m) ===
        Unitful.Quantity{Float64,
            typeof(𝐋),
            Unitful.FreeUnits{(Unitful.Unit{:Meter, typeof(𝐋)}(0,1),),
                typeof(𝐋)}}
    @test typeof(1m^2) ===
        Unitful.Quantity{Int,
            typeof(𝐋^2),
            Unitful.FreeUnits{(Unitful.Unit{:Meter, typeof(𝐋)}(0,2),),
                typeof(𝐋^2)}}
    @test typeof(1ac) ===
        Unitful.Quantity{Int,
            typeof(𝐋^2),
            Unitful.FreeUnits{(Unitful.Unit{:Acre, typeof(𝐋^2)}(0,1),),
                typeof(𝐋^2)}}
    @test typeof(ContextUnits(m,μm)) ===
        ContextUnits{(Unitful.Unit{:Meter, typeof(𝐋)}(0,1),),
            typeof(𝐋),
            typeof(μm)}
    @test typeof(1.0*ContextUnits(m,μm)) ===
        Unitful.Quantity{Float64,
            typeof(𝐋),
            ContextUnits{(Unitful.Unit{:Meter, typeof(𝐋)}(0,1),),
                typeof(𝐋),
                typeof(μm)}}
    @test typeof(1.0*FixedUnits(m)) ===
        Unitful.Quantity{Float64,
            typeof(𝐋),
            FixedUnits{(Unitful.Unit{:Meter, typeof(𝐋)}(0,1),),
                typeof(𝐋)}}
    @test 3mm != 3*(m*m)                        # mm not interpreted as m*m
    @test (3+4im)*V === V*(3+4im) === (3V+4V*im)  # Complex quantity construction
    @test 3*NoUnits === 3
    @test 3*(FreeUnits(m)/FreeUnits(m)) === 3
    @test 3*(ContextUnits(m)/ContextUnits(m)) === 3
    @test 3*(FixedUnits(m)/FixedUnits(m)) === 3
    @test ContextUnits(mm) === ContextUnits(mm,m)
    @test Quantity(3, NoUnits) === 3
    @test FreeUnits(ContextUnits(mm,m)) === FreeUnits(mm)
    @test FreeUnits(FixedUnits(mm)) === FreeUnits(mm)
    @test isa(FreeUnits(m), FreeUnits)
    @test isa(ContextUnits(m), ContextUnits)
    @test isa(ContextUnits(m,mm), ContextUnits)
    @test isa(FixedUnits(m), FixedUnits)
    @test ContextUnits(m, FixedUnits(mm)) === ContextUnits(m, mm)
    @test ContextUnits(m, ContextUnits(mm, mm)) === ContextUnits(m, mm)
    @test_throws DimensionError ContextUnits(m,kg)
end

@testset "Conversion" begin
    @testset "> Unitless ↔ unitful conversion" begin
        @test_throws DimensionError convert(typeof(3m), 1)
        @test_throws DimensionError convert(Float64, 3m)
        @test @inferred(3m/unit(3m)) === 3
        @test @inferred(3.0g/unit(3.0g)) === 3.0
        @test @inferred(ustrip(3*FreeUnits(m))) === 3
        @test @inferred(ustrip(3*ContextUnits(m,μm))) === 3
        @test @inferred(ustrip(3*FixedUnits(m))) === 3
        @test @inferred(ustrip(3)) === 3
        @test @inferred(ustrip(3.0m)) === 3.0
        @test convert(typeof(1mm/m), 3) == 3000mm/m
        @test convert(typeof(1mm/m), 3*NoUnits) == 3000mm/m
        @test convert(typeof(1*ContextUnits(mm/m, NoUnits)), 3) == 3000mm/m
        @test convert(typeof(1*FixedUnits(mm/m)), 3) == 3000*FixedUnits(mm/m)
        @test convert(Int, 1*FreeUnits(m/mm)) === 1000
        @test convert(Int, 1*FixedUnits(m/mm)) === 1000
        @test convert(Int, 1*ContextUnits(m/mm, NoUnits)) === 1000

        # w/ units distinct from w/o units
        @test 1m != 1
        @test 1 != 1m
        @test (3V+4V*im) != (3+4im)

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
            @test (3.0+4.0im)*V == (3+4im)*V
            @test im*V == Complex(0,1)*V
        end
        @testset ">> Intra-unit conversion" begin
            # an essentially no-op uconvert should not disturb numeric type
            @test @inferred(uconvert(g,1g)) === 1g
            @test @inferred(uconvert(m,0x01*m)) === 0x01*m

            # test special case of temperature
            @test uconvert(°C, 0x01*°C) === 0x01*°C
            @test 1kg === 1kg
            @test typeof(1m)(1m) === 1m

            @test 1*FreeUnits(kg) == 1*ContextUnits(kg,g)
            @test 1*ContextUnits(kg,g) == 1*FreeUnits(kg)

            @test 1*FreeUnits(kg) == 1*FixedUnits(kg)
            @test 1*FixedUnits(kg) == 1*FreeUnits(kg)

            @test 1*ContextUnits(kg,g) == 1*FixedUnits(kg)
            @test 1*FixedUnits(kg) == 1*ContextUnits(kg,g)

            # No auto conversion when working with FixedUnits exclusively.
            @test_throws ErrorException 1*FixedUnits(kg) == 1000*FixedUnits(g)
        end
        @testset ">> Inter-unit conversion" begin
            @test 1g == 0.001kg                   # Issue 56
            @test 0.001kg == 1g                   # Issue 56
            @test 1kg == 1000g
            @test !(1kg === 1000g)
            @test 1inch == (254//100)*cm
            @test 1ft == 12inch
            @test 1/mi == 1//(5280ft)
            @test 1J == 1kg*m^2/s^2
            @test typeof(1cm)(1m) === 100cm
            @test (3V+4V*im) != (3m+4m*im)
            @test_throws DimensionError uconvert(m, 1kg)
            @test_throws DimensionError uconvert(m, 1*ContextUnits(kg,g))
            @test_throws DimensionError uconvert(ContextUnits(m,mm), 1kg)
            @test_throws DimensionError uconvert(m, 1*FixedUnits(kg))
            @test uconvert(g, 1*FixedUnits(kg)) == 1000g         # manual conversion okay
            # Issue 79:
            @test isapprox(upreferred(Unitful.ɛ0), 8.85e-12u"F/m", atol=0.01e-12u"F/m")
        end
        @testset ">> Temperature conversion" begin
            # When converting a pure temperature, offsets in temperature are
            # taken into account. If you like °Ra seek help
            @test @inferred(uconvert(FreeUnits(°Ra), 4.2K)) ≈ 7.56°Ra
            @test @inferred(unit(uconvert(FreeUnits(°Ra), 4.2K))) === FreeUnits(°Ra)
            @test @inferred(uconvert(FreeUnits(°Ra), 4.2*ContextUnits(K))) ≈ 7.56°Ra
            @test @inferred(unit(uconvert(FreeUnits(°Ra), 4.2*ContextUnits(K)))) ===
                FreeUnits(°Ra)
            @test @inferred(unit(uconvert(ContextUnits(°Ra), 4.2K))) ===
                ContextUnits(°Ra)

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
    @testset "> Unit preferences" begin
        # Only because we favor SI, we have the following:
        @test @inferred(upreferred(N)) === kg*m/s^2
        @test @inferred(upreferred(dimension(N))) === kg*m/s^2
        @test @inferred(upreferred(g)) === kg
        @test @inferred(upreferred(FreeUnits(g))) === FreeUnits(kg)

        # Test special units behaviors
        @test @inferred(upreferred(ContextUnits(g,mg))) === ContextUnits(mg,mg)
        @test @inferred(upreferred(FixedUnits(kg))) === FixedUnits(kg)
        @test @inferred(upreferred(upreferred(1.0ContextUnits(kg,g)))) ===
            1000.0ContextUnits(g,g)
        @test @inferred(upreferred(unit(1g |> ContextUnits(g,mg)))) === ContextUnits(mg,mg)
        @test @inferred(upreferred(1g |> ContextUnits(g,mg))) == 1000mg

        @test @inferred(upreferred(1N)) === (1//1)*kg*m/s^2
    end
    @testset "> promote_unit" begin
        @test Unitful.promote_unit(FreeUnits(m)) === FreeUnits(m)
        @test Unitful.promote_unit(ContextUnits(m,mm)) === ContextUnits(m,mm)
        @test Unitful.promote_unit(FixedUnits(kg)) === FixedUnits(kg)
        @test Unitful.promote_unit(ContextUnits(m,mm), ContextUnits(km,mm)) ===
            ContextUnits(mm,mm)
        @test Unitful.promote_unit(FreeUnits(m), ContextUnits(mm,km)) ===
            ContextUnits(km,km)
        @test Unitful.promote_unit(FixedUnits(kg), ContextUnits(g,g)) === FixedUnits(kg)
        @test Unitful.promote_unit(ContextUnits(g,g), FixedUnits(kg)) === FixedUnits(kg)
        @test Unitful.promote_unit(FixedUnits(kg), FreeUnits(g)) === FixedUnits(kg)
        @test Unitful.promote_unit(FreeUnits(g), FixedUnits(kg)) === FixedUnits(kg)
        @test_throws DimensionError Unitful.promote_unit(m,kg)

        # FixedUnits throw a promotion error
        @test_throws ErrorException Unitful.promote_unit(FixedUnits(m), FixedUnits(mm))

        # Only because we favor SI, we have the following:
        @test Unitful.promote_unit(m,km) === m
        @test Unitful.promote_unit(m,km,cm) === m
        @test Unitful.promote_unit(ContextUnits(m,mm), ContextUnits(km,cm)) ===
            FreeUnits(m)
    end
    @testset "> Simple promotion" begin
        # promotion should do nothing to units alone
        @test @inferred(promote(m, km)) === (m, km)
        @test @inferred(promote(ContextUnits(m, km), ContextUnits(mm, km))) ===
            (ContextUnits(m, km), ContextUnits(mm, km))
        @test @inferred(promote(FixedUnits(m), FixedUnits(km))) ===
            (FixedUnits(m), FixedUnits(km))

        # promote the numeric type
        @test @inferred(promote(1.0m, 1m)) === (1.0m, 1.0m)
        @test @inferred(promote(1m, 1.0m)) === (1.0m, 1.0m)
        @test @inferred(promote(1.0g, 1kg)) === (0.001kg, 1.0kg)
        @test @inferred(promote(1g, 1.0kg)) === (0.001kg, 1.0kg)
        @test @inferred(promote(1.0m, 1kg)) === (1.0m, 1.0kg)
        @test @inferred(promote(1kg, 1.0m)) === (1.0kg, 1.0m)
        @test_broken @inferred(promote(1.0m, 1)) === (1.0m, 1.0)         # issue 52

        # prefer no units for dimensionless numbers
        @test @inferred(promote(1.0mm/m, 1.0km/m)) === (0.001,1000.0)
        @test @inferred(promote(1.0cm/m, 1.0mm/m, 1.0km/m)) === (0.01,0.001,1000.0)
        @test @inferred(promote(1.0rad,1.0°)) === (1.0,π/180.0)

        # Quantities with promotion context
        # Context overrides free units
        nm2μm = ContextUnits(nm,μm)
        μm2μm = ContextUnits(μm,μm)
        μm2mm = ContextUnits(μm,mm)
        @test @inferred(promote(1.0nm2μm, 1.0m)) === (0.001μm2μm, 1e6μm2μm)
        @test @inferred(promote(1.0m, 1.0μm2μm)) === (1e6μm2μm, 1.0μm2μm)
        @test ===(upreferred.(unit.(promote(1.0nm2μm, 2nm2μm)))[1], ContextUnits(μm,μm))
        @test ===(upreferred.(unit.(promote(1.0nm2μm, 2nm2μm)))[2], ContextUnits(μm,μm))

        # Context agreement
        @test @inferred(promote(1.0nm2μm, 1.0μm2μm)) ===
            (0.001μm2μm, 1.0μm2μm)
        @test @inferred(promote(1μm2μm, 1.0nm2μm, 1.0m)) ===
            (1.0μm2μm, 0.001μm2μm, 1e6μm2μm)
        @test @inferred(promote(1μm2μm, 1.0nm2μm, 1.0s)) ===
            (1.0μm2μm, 1.0nm2μm, 1.0s)
        # Context disagreement: fall back to free units
        @test @inferred(promote(1.0nm2μm, 1.0μm2mm)) === (1e-9m, 1e-6m)
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
    @testset "> Issue 52" begin
        x,y = 10m, 1
        px,py = promote(x,y)
        ppx,ppy = promote(px,py)
        @test typeof(py) == typeof(ppy)
    end
end

@testset "Unit string macro" begin
    @test macroexpand(:(u"m")) == m
    @test macroexpand(:(u"m,s")) == (m,s)
    @test macroexpand(:(u"1.0")) == 1.0
    @test macroexpand(:(u"m/s")) == m/s
    @test macroexpand(:(u"1.0m/s")) == 1.0m/s
    @test macroexpand(:(u"m^-1")) == m^-1
    @test macroexpand(:(u"dB/Hz")) == dB/Hz
    @test macroexpand(:(u"3.0dB/Hz")) == 3.0dB/Hz
    @test isa(macroexpand(:(u"N m")).args[1], ParseError)
    @test isa(macroexpand(:(u"abs(2)")).args[1], ErrorException)

    # test ustrcheck(::Quantity)
    @test u"h" == Unitful.h

    # test ustrcheck(x) fallback to catch non-units / quantities
    @test_throws ErrorException @eval u"basefactor"
end

@testset "Unit and dimensional analysis" begin
    @test @inferred(unit(1m^2)) === m^2
    @test @inferred(unit(typeof(1m^2))) === m^2
    @test @inferred(unit(Float64)) === NoUnits
    @test @inferred(dimension(1m^2)) === 𝐋^2
    @test @inferred(dimension(1*ContextUnits(m,km)^2)) === 𝐋^2
    @test @inferred(dimension(typeof(1m^2))) === 𝐋^2
    @test @inferred(dimension(Float64)) === NoDims
    @test @inferred(dimension(m^2)) === 𝐋^2
    @test @inferred(dimension(1m/s)) === 𝐋/𝐓
    @test @inferred(dimension(m/s)) === 𝐋/𝐓
    @test @inferred(dimension(1u"mol")) === 𝐍
    @test @inferred(dimension(μm/m)) === NoDims
    @test dimension.([1u"m", 1u"s"]) == [𝐋, 𝐓]
    @test dimension.([u"m", u"s"]) == [𝐋, 𝐓]
    @test (𝐋/𝐓)^2 === 𝐋^2 / 𝐓^2
    @test isa(m, LengthUnits)
    @test isa(ContextUnits(m,km), LengthUnits)
    @test isa(FixedUnits(m), LengthUnits)
    @test !isa(m, AreaUnits)
    @test !isa(ContextUnits(m,km), AreaUnits)
    @test !isa(FixedUnits(m), AreaUnits)
    @test !isa(m, MassUnits)
    @test isa(m^2, AreaUnits)
    @test !isa(m^2, LengthUnits)
    @test isa(1m, Length)
    @test isa(1*ContextUnits(m,km), Length)
    @test isa(1*FixedUnits(m), Length)
    @test !isa(1m, LengthUnits)
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
    @test isa(3u"dBm", Power)
    @test isa(3u"dBm*Hz*s", Power)

end

@testset "Mathematics" begin
    @testset "> Comparisons" begin
        # make sure we are just picking one of the arguments, without surprising conversions
        # happening to the units...
        @test min(1FreeUnits(hr), 1FreeUnits(s)) === 1FreeUnits(s)
        @test min(1FreeUnits(hr), 1ContextUnits(s,ms)) === 1ContextUnits(s,ms)
        @test min(1ContextUnits(s,ms), 1FreeUnits(hr)) === 1ContextUnits(s,ms)
        @test min(1ContextUnits(s,minute), 1ContextUnits(hr,s)) ===
            1ContextUnits(s,minute)
        @test max(1ContextUnits(ft, mi), 1ContextUnits(m,mm)) ===
            1ContextUnits(m,mm)
        @test min(1FreeUnits(hr), 1FixedUnits(s)) === 1FixedUnits(s)
        @test min(1FixedUnits(s), 1FreeUnits(hr)) === 1FixedUnits(s)
        @test min(1FixedUnits(s), 1ContextUnits(ms,s)) === 1ContextUnits(ms,s)
        @test min(1ContextUnits(ms,s), 1FixedUnits(s)) === 1ContextUnits(ms,s)

        # automatic conversion prohibited
        @test_throws ErrorException min(1FixedUnits(s), 1FixedUnits(hr))
        @test min(1FixedUnits(s), 1FixedUnits(s)) === 1FixedUnits(s)

        # now move on, presuming that's working well.
        @test max(1ft, 1m) == 1m
        @test max(10J, 1kg*m^2/s^2) === 10J
        @test max(1J//10, 1kg*m^2/s^2) === 1kg*m^2/s^2
        @test @inferred(2.0m < 3.0m)
        @test @inferred(2.0m .< 3.0m)
        @test !(@inferred 3.0m .< 3.0m)
        @test @inferred(2.0m <= 3.0m)
        @test @inferred(3.0m <= 3.0m)
        @test @inferred(2.0m .<= 3.0m)
        @test @inferred(3.0m .<= 3.0m)
        @test @inferred(1μm/m < 1)
        @test @inferred(1 > 1μm/m)
        @test @inferred(1μm/m < 1mm/m)
        @test @inferred(1mm/m > 1μm/m)
        @test_throws DimensionError 1m < 1kg
        @test_throws DimensionError 1m < 1
        @test_throws DimensionError 1 < 1m
        @test_throws DimensionError 1mm/m < 1m
        @test Base.rtoldefault(typeof(1.0u"m")) === Base.rtoldefault(typeof(1.0))
        @test Base.rtoldefault(typeof(1u"m")) === Base.rtoldefault(Int)
    end
    @testset "> Addition and subtraction" begin
        @test @inferred(+(1A)) == 1A                    # Unary addition
        @test @inferred(3m + 3m) == 6m                  # Binary addition
        @test @inferred(-(1kg)) == (-1)*kg              # Unary subtraction
        @test @inferred(3m - 2m) == 1m                  # Binary subtraction
        @test @inferred(zero(1m)) === 0m                # Additive identity
        @test @inferred(zero(typeof(1m))) === 0m
        @test @inferred(zero(typeof(1.0m))) === 0.0m
        @test @inferred(π/2*u"rad" + 90u"°") ≈ π        # Dimless quantities
        @test @inferred(π/2*u"rad" - 90u"°") ≈ 0        # Dimless quantities
        @test_throws DimensionError 1+1m                # Dim mismatched
        @test_throws DimensionError 1-1m
    end
    @testset "> Multiplication" begin
        @test @inferred(FreeUnits(g)*FreeUnits(kg)) === FreeUnits(g*kg)
        @test @inferred(ContextUnits(m,mm)*ContextUnits(kg,g)) ===
            ContextUnits(m*kg,mm*g)
        @test @inferred(ContextUnits(m,mm)*FreeUnits(g)) ===
            ContextUnits(m*g,mm*kg)
        @test @inferred(FreeUnits(g)*ContextUnits(m,mm)) ===
            ContextUnits(m*g,mm*kg)
        @test @inferred(FixedUnits(g)*FixedUnits(kg)) === FixedUnits(g*kg)
        @test @inferred(FixedUnits(g)*FreeUnits(kg)) === FixedUnits(g*kg)
        @test @inferred(FixedUnits(g)*ContextUnits(kg,kg)) === FixedUnits(g*kg)
        @test @inferred(*(1s)) === 1s                     # Unary multiplication
        @test @inferred(3m * 2cm) === 3cm * 2m            # Binary multiplication
        @test @inferred((3m)*m) === 3*(m*m)               # Associative multiplication
        @test @inferred(true*1kg) === 1kg                 # Boolean multiplication (T)
        @test @inferred(false*1kg) === 0kg                # Boolean multiplication (F)
    end
    @testset "> Division" begin
        @test 360° / 2 === 180.0°            # Issue 110
        @test 360° // 2 === 180°//1
        @test 2m // 5s == (2//5)*(m/s)       # Units propagate through rationals
        @test (2//3)*m // 5 == (2//15)*m     # Quantity // Real
        @test 5.0m // s === 5.0m/s           # Quantity // Unit. Just pass units through
        @test s//(5m) === (1//5)*s/m         # Unit // Quantity. Will fail if denom is float
        @test (m//2) === 1//2 * m            # Unit // Real
        @test (2//m) === (2//1) / m          # Real // Unit
        @test (m//s) === m/s                 # Unit // Unit
        @test @inferred(div(10m, -3cm)) === -333
        @test @inferred(fld(10m, -3cm)) === -334
        @test rem(10m, -3cm) == 1.0cm
        @test mod(10m, -3cm) == -2.0cm
        @test mod(1hr+3minute+5s, 24s) == 17s
        @test @inferred(inv(s)) === s^-1
        @test inv(ContextUnits(m,km)) === ContextUnits(m^-1,km^-1)
        @test inv(FixedUnits(m)) === FixedUnits(m^-1)
    end
    @testset "> Exponentiation" begin
        @test @inferred(m^3/m) === m^2
        @test @inferred(𝐋^3/𝐋) === 𝐋^2
        @test @inferred(sqrt(4m^2)) === 2.0m
        @test sqrt(4m^(2//3)) === 2.0m^(1//3)
        @test @inferred(sqrt(𝐋^2)) === 𝐋
        @test @inferred(sqrt(m^2)) === m
        @test @inferred(cbrt(8m^3)) === 2.0m
        @test cbrt(8m) === 2.0m^(1//3)
        @test @inferred(cbrt(𝐋^3)) === 𝐋
        @test @inferred(cbrt(m^3)) === m
        @test (2m)^3 === 8*m^3
        @test (8m)^(1//3) === 2.0*m^(1//3)
        @test @inferred(cis(90°)) ≈ im

        # Test inferrability of integer literal powers
        _pow_m3(x) = x^-3
        _pow_0(x) = x^0
        _pow_3(x) = x^3
        _pow_2_3(x) = x^(2//3)

        @test_throws ErrorException @inferred(_pow_2_3(m))
        @test_throws ErrorException @inferred(_pow_2_3(𝐋))
        @test_throws ErrorException @inferred(_pow_2_3(1.0m))

        @test @inferred(_pow_m3(m)) == m^-3
        @test @inferred(_pow_0(m)) == NoUnits
        @test @inferred(_pow_3(m)) == m^3

        @test @inferred(_pow_m3(𝐋)) == 𝐋^-3
        @test @inferred(_pow_0(𝐋)) == NoDims
        @test @inferred(_pow_3(𝐋)) == 𝐋^3

        @test @inferred(_pow_m3(1.0m)) == 1.0m^-3
        @test @inferred(_pow_0(1.0m)) == 1.0
        @test @inferred(_pow_3(1.0m)) == 1.0m^3
    end
    @testset "> Trigonometry" begin
        @test @inferred(sin(0.0rad)) == 0.0
        @test @inferred(cos(π*rad)) == -1
        @test @inferred(tan(π*rad/4)) ≈ 1
        @test @inferred(csc(π*rad/2)) == 1
        @test @inferred(sec(0.0*rad)) == 1
        @test @inferred(cot(π*rad/4)) ≈ 1
        @test @inferred(sin(90°)) == 1
        @test @inferred(cos(0.0°)) == 1
        @test @inferred(tan(45°)) == 1
        @test @inferred(csc(90°)) == 1
        @test @inferred(sec(0°)) == 1
        @test @inferred(cot(45°)) == 1
        @test @inferred(atan2(m*sqrt(3),1m)) ≈ 60°
        @test @inferred(angle((3im)*V)) ≈ 90°
    end
    @testset "> Exponentials and logarithms" begin
        for f in (exp, exp10, exp2, expm1, log, log10, log1p, log2)
            @test f(1.0 * u"m/dm") ≈ f(10)
        end
    end
    @testset "> Matrix inversion" begin
        @test inv([1 1; -1 1]u"nm") ≈ [0.5 -0.5; 0.5 0.5]u"nm^-1"
    end
    @testset "> Is functions" begin
        @test_throws ErrorException isinteger(1.0m)
        @test isinteger(1.4m/mm)
        @test !isinteger(1.4mm/m)
        @test isfinite(1.0m)
        @test !isfinite(Inf*m)
        @test isnan(NaN*m)
        @test !isnan(1.0m)
    end
    @testset "> Floating point tests" begin
        @test isapprox(1.0u"m",(1.0+eps(1.0))u"m")
        @test isapprox(1.0u"μm/m",1e-6)
        @test !isapprox(1.0u"μm/m",1e-7)
        @test !isapprox(1.0u"m",5)
        @test frexp(1.5m) == (0.75m, 1.0)
        @test unit(nextfloat(0.0m)) == m
        @test unit(prevfloat(0.0m)) == m

        @test isapprox(1.0u"m", 1.1u"m"; atol=0.2u"m")
        @test !isapprox(1.0u"m", 1.1u"m"; atol=0.05u"m")
        @test isapprox(1.0u"m", 1.1u"m"; atol=200u"mm")
        @test !isapprox(1.0u"m", 1.1u"m"; atol=50u"mm")
        @test isapprox(1.0u"m", 1.1u"m"; rtol=0.2)
        @test !isapprox(1.0u"m", 1.1u"m"; rtol=0.05)

        # Test eps
        @test eps(1.0u"s") == eps(1.0)u"s"
        @test eps(typeof(1.0u"s")) == eps(Float64)u"s"

        # Test promotion behavior
        @test !isapprox(1.0u"m", 1.0u"s")
        @test isapprox(1.0u"m", 1000.0u"mm")
        @test_throws ErrorException isapprox(1.0*FixedUnits(u"m"), 1000.0*FixedUnits(u"mm"))
    end
end

@testset "Fast mathematics" begin
    @testset "> fma and muladd" begin
        m2cm = ContextUnits(m,cm)
        m2mm = ContextUnits(m,mm)
        mm2cm = ContextUnits(mm,cm)
        cm2cm = ContextUnits(cm,cm)
        fm, fmm = FixedUnits(m), FixedUnits(mm)
        @test @inferred(fma(2.0, 3.0m, 1.0m)) === 7.0m               # llvm good
        @test @inferred(fma(2.0, 3.0m2cm, 1.0mm2cm)) === 600.1cm2cm
        @test @inferred(fma(2.0, 3.0fm, 1.0fm)) === 7.0fm
        @test @inferred(fma(2.0, 3.0m, 35mm)) === 6.035m             # llvm good
        @test @inferred(fma(2.0, 3.0m2cm, 35mm2cm)) === 603.5cm2cm
        @test_throws ErrorException fma(2.0, 3.0fm, 35fmm)  #automatic conversion prohibited
        @test @inferred(fma(2.0m, 3.0, 35mm)) === 6.035m             # llvm good
        @test @inferred(fma(2.0m2cm, 3.0, 35mm2cm)) === 603.5cm2cm
        @test @inferred(fma(2.0m, 1.0/m, 3.0)) === 5.0               # llvm good
        @test @inferred(fma(2.0m2cm, 1.0/m2mm, 3.0)) === 5.0
        @test @inferred(fma(2.0cm, 1.0/s, 3.0mm/s)) === .023m/s      # llvm good
        @test @inferred(fma(2.0cm2cm, 1.0/s, 3.0mm/s)) === 2.3cm2cm/s
        @test @inferred(fma(2m, 1/s, 3m/s)) === 5m/s                 # llvm good
        @test @inferred(fma(2, 1.0μm/m, 1)) === 1.000002             # llvm good
        @test @inferred(fma(1.0mm/m, 1.0mm/m, 1.0mm/m)) === 0.001001 # llvm good
        @test @inferred(fma(1.0mm/m, 1.0, 1.0)) ≈ 1.001              # llvm good
        @test @inferred(fma(1.0, 1.0μm/m, 1.0μm/m)) === 2.0μm/m      # llvm good
        @test @inferred(fma(2, 1.0, 1μm/m)) === 2.000001             # llvm BAD
        @test @inferred(fma(2, 1μm/m, 1mm/m)) === 501//500000    # llvm BAD
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
        @test @inferred(muladd(2, 1μm/m, 1mm/m)) === 501//500000
        @test_throws DimensionError fma(2m, 1/m, 1m)
        @test_throws DimensionError fma(2, 1m, 1V)
    end
    @testset "> @fastmath" begin
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
    @test_throws ErrorException floor(3.7m)
    @test_throws ErrorException ceil(3.7m)
    @test_throws ErrorException trunc(3.7m)
    @test_throws ErrorException round(3.7m)
    @test_throws ErrorException floor(Integer, 3.7m)
    @test_throws ErrorException ceil(Integer, 3.7m)
    @test_throws ErrorException trunc(Integer, 3.7m)
    @test_throws ErrorException round(Integer, 3.7m)
    @test_throws ErrorException floor(Int, 3.7m)
    @test_throws ErrorException ceil(Int, 3.7m)
    @test_throws ErrorException trunc(Int, 3.7m)
    @test_throws ErrorException round(Int, 3.7m)
    @test floor(1.0314m/mm) === 1031.0
    @test ceil(1.0314m/mm) === 1032.0
    @test trunc(-1.0314m/mm) === -1031.0
    @test round(1.0314m/mm) === 1031.0
    @test floor(Integer, 1.0314m/mm) === Integer(1031.0)
    @test ceil(Integer, 1.0314m/mm) === Integer(1032.0)
    @test trunc(Integer, -1.0314m/mm) === Integer(-1031.0)
    @test round(Integer, 1.0314m/mm) === Integer(1031.0)
    @test floor(Int16, 1.0314m/mm) === Int16(1031.0)
    @test ceil(Int16, 1.0314m/mm) === Int16(1032.0)
    @test trunc(Int16, -1.0314m/mm) === Int16(-1031.0)
    @test round(Int16, 1.0314m/mm) === Int16(1031.0)
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
    @test @inferred(rand(typeof(1u"m"))) isa typeof(1u"m")
    @test @inferred(rand(MersenneTwister(0), typeof(1u"m"))) isa typeof(1u"m")
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
            r = @inferred(colon(1m, 1m, 5m))
            @test isa(r, StepRange{typeof(1m)})
            @test @inferred(length(r)) === 5
            @test @inferred(step(r)) === 1m

            @test @inferred(first(range(1mm, 2m, 4))) === 1mm
            @test @inferred(step(range(1mm, 2m, 4))) === 2m
            @test @inferred(last(range(1mm, 2m, 4))) === 6001mm
            @test_throws ArgumentError 1m:0m:5m

            @test_throws DimensionError range(1m, 2V, 5)
            try
                range(1m, 2V, 5)
            catch e
                @test e.x == 1m
                @test e.y == 2V
            end
        end
        @testset ">> StepRangeLen" begin
            @test isa(@inferred(colon(1.0m, 1m, 5m)), StepRangeLen{typeof(1.0m)})
            @test @inferred(length(1.0m:1m:5m)) === 5
            @test @inferred(step(1.0m:1m:5m)) === 1.0m
            @test @inferred(length(0:10°:360°)) == 37 # issue 111
            @test @inferred(length(0.0:10°:2pi)) == 37 # issue 111 fallout
            @test @inferred(last(0°:0.1:360°)) === 6.2 # issue 111 fallout

            @test @inferred(first(range(1mm, 0.1mm, 50))) === 1.0mm # issue 111
            @test @inferred(step(range(1mm, 0.1mm, 50))) === 0.1mm # issue 111
            @test @inferred(last(range(0,10°,37))) == 2pi
            @test @inferred(last(range(0°,2pi/36,37))) == 2pi
            @test_throws ArgumentError 1.0m:0.0m:5.0m
            @test_throws DimensionError range(1.0m, 1.0V, 5)
            @test step(range(1.0m, 1m, 5)) === 1.0m
        end
        @testset ">> LinSpace" begin
            @test isa(@inferred(linspace(1.0m, 3.0m, 5)),
                StepRangeLen{typeof(1.0m), Base.TwicePrecision{typeof(1.0m)}})
            @test isa(@inferred(linspace(1.0m, 10m, 5)),
                StepRangeLen{typeof(1.0m), Base.TwicePrecision{typeof(1.0m)}})
            @test isa(@inferred(linspace(1m, 10.0m, 5)),
                StepRangeLen{typeof(1.0m), Base.TwicePrecision{typeof(1.0m)}})
            @test isa(@inferred(linspace(1m, 10m, 5)),
                StepRangeLen{typeof(1.0m), Base.TwicePrecision{typeof(1.0m)}})
            @test_throws Unitful.DimensionError linspace(1m, 10, 5)
            @test_throws Unitful.DimensionError linspace(1, 10m, 5)
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
            r = @inferred(range(0.1, 0.1, 3) * 1.0s)
            @test r[3] === 0.3s
        end
    end
    @testset "> Arrays" begin
        @testset ">> Array multiplication" begin
            # Quantity, quantity
            @test @inferred([1m, 2m]' * [3m, 4m])    == 11m^2
            @test @inferred([1m, 2m]' * [3/m, 4/m])  == 11
            @test typeof([1m, 2m]' * [3/m, 4/m])     == Int
            @test typeof([1m, 2V]' * [3/m, 4/V])     == Int
            @test @inferred([1V,2V]*[0.1/m, 0.4/m]') == [0.1V/m 0.4V/m; 0.2V/m 0.8V/m]

            # Probably broken as soon as we stopped using custom promote_op methods
            @test_broken @inferred([1m, 2V]' * [3/m, 4/V])  == [11]
            @test_broken @inferred([1m, 2V] * [3/m, 4/V]') ==
                [3 4u"m*V^-1"; 6u"V*m^-1" 8]

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
            @test @inferred([1,2] * [3m 4m])     == [3m 4m; 6m 8m]
            @test typeof([1,2] * [3m 4m])        == Array{typeof(1u"m"),2}
            @test @inferred([3m,4m] * [1 2])     == [3m 6m; 4m 8m]
            @test typeof([3m,4m] * [1 2])        == Array{typeof(1u"m"),2}
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
            @test @inferred(eye(2).*V)                 == [1.0V 0.0V; 0.0V 1.0V]
            @test @inferred(V.*eye(2))                 == [1.0V 0.0V; 0.0V 1.0V]
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
            @test_warn "deprecated" ustrip([1,2])
            @test ustrip.([1,2]) == [1,2]
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

        @testset ">> Array initialization" begin
            Q = typeof(1u"m")
            @test @inferred(zeros(Q, 2)) == [0, 0]u"m"
            @test @inferred(zeros(Q, (2,))) == [0, 0]u"m"
            @test @inferred(zeros(Q)[]) == 0u"m"
            @test @inferred(zeros([1.0, 2.0, 3.0], Q)) == [0, 0, 0]u"m"
            @test @inferred(ones(Q, 2)) == [1, 1]u"m"
            @test @inferred(ones(Q, (2,))) == [1, 1]u"m"
            @test @inferred(ones(Q)[]) == 1u"m"
            @test @inferred(ones([1.0, 2.0, 3.0], Q)) == [1, 1, 1]u"m"
            @test size(rand(Q, 2)) == (2,)
            @test size(rand(Q, 2, 3)) == (2,3)
            @test eltype(@inferred(rand(Q, 2))) == Q
        end
    end
end

@testset "DimensionError message" begin
  function errorstr(e)
    b = IOBuffer()
    Base.showerror(b,e)
    String(b)
  end
  @test errorstr(DimensionError(1u"m",2)) == "DimensionError: 1 m and 2 are not dimensionally compatible."
  @test errorstr(DimensionError(1u"m",NoDims)) == "DimensionError: 1 m and  are not dimensionally compatible."
  @test errorstr(DimensionError(u"m",2)) == "DimensionError: m and 2 are not dimensionally compatible."
end

@testset "Logarithmic quantities" begin
    @testset "> Explicit construction" begin
        @testset ">> Level" begin
            # Outer constructor
            @test Level{Decibel,1}(2) isa Level{Decibel,1,Int}
            @test_throws DimensionError Level{Decibel,1}(2V)

            # Inner constructor
            @test Level{Decibel,1,Int}(2) === Level{Decibel,1}(2)
        end

        @testset ">> Gain" begin
            @test Gain{Decibel}(1) isa Gain{Decibel,Int}
            @test_throws MethodError Gain{Decibel}(1V)
            @test_throws TypeError Gain{Decibel,typeof(1V)}(1V)
        end

    end

    @testset "> Implicit construction" begin
        @testset ">> Level" begin
            @test 20*dBm == (@dB 100mW/mW) == (@dB 100mW/1mW) == dB(100mW,mW) == dB(100mW,1mW)
            @test 20*dBV == (@dB 10V/V) == (@dB 10V/1V) == dB(10V,V) == dB(10V,1V)
            @test_throws ArgumentError @dB 10V/V true
        end

        @testset ">> Gain" begin
            @test_throws ArgumentError @eval @dB 10
            @test 20*dB  === dB*20
        end

        @testset ">> MixedUnits" begin
            @test dBm === MixedUnits{Level{Decibel, 1mW}}()
            @test dBm/Hz === MixedUnits{Level{Decibel, 1mW}}(Hz^-1)
        end
    end

    @testset "> Unit and dimensional analysis" begin
        @testset ">> Level" begin
            @test dimension(1dBm) === dimension(1mW)
            @test dimension(typeof(1dBm)) === dimension(1mW)
            @test dimension(1dBV) === dimension(1V)
            @test dimension(typeof(1dBV)) === dimension(1V)
            @test dimension(1dB) === NoDims
            @test dimension(typeof(1dB)) === NoDims
            @test dimension(@dB 3V/2.14V) === dimension(1V)
            @test dimension(typeof(@dB 3V/2.14V)) === dimension(1V)
            @test logunit(1dBm) === dBm
            @test logunit(typeof(1dBm)) === dBm
        end

        @testset ">> Gain" begin
            @test logunit(3dB) === dB
            @test logunit(typeof(3dB)) === dB
        end

        @testset ">> Quantity{<:Level}" begin
            @test dimension(1dBm/Hz) === dimension(1mW/Hz)
            @test dimension(typeof(1dBm/Hz)) === dimension(1mW/Hz)
            @test dimension(1dB/Hz) === dimension(Hz^-1)
            @test dimension(typeof(1dB/Hz)) === dimension(Hz^-1)
            @test dimension((@dB 3V/2.14V)/Hz) === dimension(1V/Hz)
            @test dimension(typeof((@dB 3V/2.14V)/Hz)) === dimension(1V/Hz)
        end
    end

    @testset "> Conversion" begin
        @test float(3dB) == 3.0dB
        @test float(@dB 3V/1V) === @dB 3.0V/1V

        @test uconvert(V, (@dB 3V/2.14V)) === 3V
        @test uconvert(V, (@dB 3V/1V)) === 3V
        @test uconvert(mW/Hz, 0dBm/Hz) == 1mW/Hz
        @test uconvert(mW/Hz, (@dB 1mW/mW)/Hz) === 1mW/Hz
        @test uconvert(dB, 1Np) ≈ 8.685889638065037dB
        @test uconvert(dB, 10dB*m/mm) == 10000dB

        @test convert(typeof(1.0dB), 1Np) ≈ 8.685889638065037dB
        @test convert(typeof(1.0dBm), 1W) == 30.0dBm
        @test_throws DimensionError convert(typeof(1.0dBm), 1V)
        @test convert(typeof(3dB), 3dB) === 3dB
        @test convert(typeof(3.0dB), 3dB) === 3.0dB
        @test convert(Float64, 0u"dBFS") === 1.0

        @test isapprox(uconvertrp(NoUnits, 6.02dB), 2.0, atol=0.001)
        @test uconvertrp(NoUnits, 1Np) ≈ e
        @test uconvertrp(Np, e) == 1Np
        @test uconvertrp(NoUnits, 1) == 1
        @test uconvertrp(NoUnits, 20dB) == 10
        @test uconvertrp(dB, 10) == 20dB
        @test isapprox(uconvertp(NoUnits, 3.01dB), 2.0, atol=0.001)
        @test uconvertp(NoUnits, 1Np) == e^2
        @test uconvertp(Np, e^2) == 1Np
        @test uconvertp(NoUnits, 1) == 1
        @test uconvertp(NoUnits, 20dB) == 100
        @test uconvertp(dB, 100) == 20dB

        @test linear(@dB(1mW/mW)/Hz) === 1mW/Hz
        @test linear(@dB(1.4V/2.8V)/s) === 1.4V/s
    end

    @testset "> Equality" begin
        @test !(20dBm == 20dB)
        @test !(20dB == 20dBm)
    end

    @testset "> Addition and subtraction" begin
        @testset ">> Level" begin
            @test isapprox(10dBm + 10dBm, 13dBm; atol=0.02dBm)
            @test !isapprox(10dBm + 10dBm, 13dBm; atol=0.00001dBm)
            @test isapprox(13dBm, 20mW; atol = 0.1mW)
            @test @dB(10mW/mW) + 1mW === 11mW
            @test 1mW + @dB(10mW/mW) === 11mW
            @test @dB(10mW/mW) + @dB(90mW/mW) === @dB(100mW/mW)
            @test (@dB 10mW/3mW) + (@dB 11mW/2mW) === 21mW
            @test (@dB 10mW/3mW) + 2mW === 12mW
            @test (@dB 10mW/3mW) + 1W === 101u"kg*m^2/s^3"//100
            @test 20dB + 20dB == 40dB
            @test 20dB + 20.2dB == 40.2dB
            @test 1Np + 1.5Np == 2.5Np
            @test_throws DimensionError (1dBm + 1dBV)
            @test_throws DimensionError (1dBm + 1V)
        end

        @testset ">> Gain" begin
            @test 20dB + 10dB === 30dB
            @test 20dB * 20dB === 40dB # support both +*, for sake of generic programming...
            @test 20dB - 10dB === 10dB
            @test_throws ErrorException 1dB + 1Np
        end

        @testset ">> Level, meet Gain" begin
            @test 10dBm + 30dB == 40dBm
            @test 30dB + 10dBm == 40dBm
            @test 10dBm - 30dB == -20dBm
            @test isapprox(10dBm - 1Np, 1.314dBm; atol=0.001dBm)

            # cannot subtract levels from gains
            @test_throws ErrorException 1Np - 10dBm
            @test_throws ErrorException 30dB - 10dBm
        end
    end

    @testset "> Multiplication and division" begin
        @testset ">> Level" begin
            @test (0dBm) * 10 == (10dBm)
            @test @dB(10V/V)*10 == 100V
            @test @dB(10V/V)/20 == 0.5V
            @test 10*@dB(10V/V) == 100V
            @test 10/@dB(10V/V) == 1V^-1
            @test (0dBm) * (1W) == 1*mW*W
            @test (1W) * (0dBm) == 1*W*mW
            @test 100*((0dBm)/s) == (20dBm)/s
            @test isapprox((3.01dBm)*(3.01dBm), 4mW^2, atol=0.01mW^2)
            @test typeof((1dBm * big"2").val.val) == BigFloat
            @test 10dBm/10Hz == 1mW/Hz
            @test 10Hz/10dBm == 1Hz/mW
            @test true*3dBm == 3dBm
            @test false*3dBm == -Inf*dBm
            @test 3dBm*true == 3dBm
            @test 3dBm*false == -Inf*dBm
            @test (0dBV)*(1Np) ≈ 8.685889638dBV
        end

        @testset ">> Gain" begin
            @test 3dB * 2 === 6dB
            @test 2 * 3dB === 6dB
            @test 3dB * 2.1 ≈ 6.3dB
            @test 3dB * false == 0*dB
            @test false * 3dB == 0*dB
            @test 1mW * 20dB == 100mW
            @test 20dB * 1mW == 100mW
            @test 1V * 20dB == 10V
            @test 20dB * 1V == 10V
        end
    end

    @testset "> Unit stripping" begin
        @test ustrip(500.0Np) === 500.0
        @test ustrip(20dB/Hz) === 20
        @test ustrip(20dB) === 20
        @test ustrip(13dBm) ≈ 13
    end

    @testset "> Display" begin
        @test Unitful.abbr(3u"dBm") == "dBm"
        @test Unitful.abbr(@dB 3V/1.241V) == "dB (1.241 V)"
    end

    @testset "> Thanks for signing up for Log Facts!" begin
        @test_throws ErrorException 20dB == 100
        @test 20dBm ≈ 100mW
        @test 20dBV ≈ 10V
        @test 40dBV ≈ 100V

        # Maximum sound pressure level is a full swing of atmospheric pressure
        @test isapprox(uconvert(dBSPL, 1u"atm"), 194dBSPL, atol=0.1dBSPL)
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
                @test eval(:(typeof(u"m"))) == Unitful.FreeUnits{
                    (Unitful.Unit{:MyMeter,Unitful.Dimensions{
                    (Unitful.Dimension{:Length}(1//1),)}}(0,1//1),),
                    Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}}
            end
        end
    finally
        rm(fname, force=true)
    end
end

@test_warn "ShadowUnits" eval(:(u"m"))

# Test to make sure user macros are working properly
# (and incidentally, for Compat macro hygiene in @dimension, @derived_dimension)
module TUM
    using Unitful
    using Compat.Test

    @dimension f "f" FakeDim12345
    @derived_dimension FakeDim212345 f^2
    @refunit fu "fu" FakeUnit12345 f false
    @unit fu2 "fu2" FakeUnit212345 1fu false
end

@testset "User macros" begin
    @test typeof(TUM.f) == Unitful.Dimensions{(Unitful.Dimension{:FakeDim12345}(1//1),)}
    @test 1(TUM.fu) == 1(TUM.fu2)
    @test isa(1(TUM.fu), TUM.FakeDim12345)
    @test isa(TUM.fu, TUM.FakeDim12345Units)
    @test isa(1(TUM.fu)^2, TUM.FakeDim212345)
    @test isa(TUM.fu^2, TUM.FakeDim212345Units)
end

end
