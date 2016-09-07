using Unitful
using Base.Test

import Unitful: m, ac, g, A, kg, cm, inch, mi, ft, °Ra, °F, °C, μm,
    s, A, K, mol, cd, rad, V, cm, hr, mm, km, minute, °, J

import Unitful: 𝐋, 𝐓, 𝐍

import Unitful:
    Length, Area, Volume,
    Luminosity,
    Time, Frequency,
    Mass,
    Current,
    Temperature,
    Angle

import Unitful:
    LengthUnit, AreaUnit, MassUnit

@testset "Type construction" begin
    @test typeof(𝐋) == Unitful.Dimensions{(Unitful.Dimension{:Length}(1),)}
    @test typeof(1.0m) ==
        Unitful.Quantity{Float64,
            typeof(𝐋),
            Unitful.Units{(Unitful.Unit{:Meter}(0, 1),), typeof(𝐋)}}
    @test typeof(1m^2) ==
        Unitful.Quantity{Int,
            typeof(𝐋^2),
            Unitful.Units{(Unitful.Unit{:Meter}(0, 2),), typeof(𝐋^2)}}
    @test typeof(1ac) ==
        Unitful.Quantity{Int,
            typeof(𝐋^2),
            Unitful.Units{(Unitful.Unit{:Acre}(0, 1),), typeof(𝐋^2)}}
end

@testset "Conversion" begin
    @testset "> Unitless ↔ unitful conversion" begin
        @test_throws MethodError convert(typeof(3m),1)
        @test_throws ErrorException convert(Float64, 3m)
        @test 3m/unit(3m) === 3
        @test 3.0g/unit(3.0g) === 3.0
    end

    @testset "> Unitful ↔ unitful conversion" begin
        @testset ">> Numeric conversion" begin
            @test float(3m) === 3.0m
            @test Integer(3.0A) === 3A
            @test Rational(3.0m) === (3//1)*m
        end
        @testset ">> Intra-unit conversion" begin
            @test uconvert(g,1g) == 1g
            # an essentially no-op uconvert should not disturb numeric type
            @test uconvert(m,0x01*m) == 0x01*m
            # test special case of temperature
            @test uconvert(°C, 0x01*°C) == 0x01*°C
            @test 1kg === 1kg
        end
        @testset ">> Inter-unit conversion" begin
            @test 1kg == 1000g
            @test !(1kg === 1000g)
            @test 1inch == (254//100)*cm
            @test 1ft == 12inch
            @test 1/mi == 1//(5280ft)
            @test 1J == 1u"kg*m^2/s^2"
        end
        @testset ">> Temperature conversion" begin
            # When converting a pure temperature, offsets in temperature are
            # taken into account. If you like °Ra seek help
            @test uconvert(°Ra, 4.2K) ≈ 7.56°Ra
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
        @test promote(1.0m, 1m) == (1.0m, 1.0m)
        @test promote(1m, 1.0m) == (1.0m, 1.0m)
        @test promote(1.0m, 1kg) == (1.0m, 1.0kg)
        @test promote(1kg, 1.0m) == (1.0kg, 1.0m)
        @test promote(1.0m, 1) == (1.0m, UnitlessQuantity(1.0))
    end

    @testset "> Promotion during array creation" begin
        @test typeof([1.0m,1.0m]) == Array{typeof(1.0m),1}
        @test typeof([1.0m,1m]) == Array{typeof(1.0m),1}
        @test typeof([1.0m,1cm]) == Array{typeof(1.0m),1}
        @test typeof([1kg,1g]) == Array{typeof(1kg//1),1}
        @test typeof([1.0m,1]) == Array{Number,1}
        @test typeof([1.0m,1kg]) == Array{Number,1}
        @test typeof([1.0m/s 1; 1 0]) == Array{Number,2}
    end
end

@testset "Unit and dimensional analysis" begin
    @test unit(1m^2) == m^2
    @test unit(typeof(1m^2)) == m^2
    @test dimension(1m^2) == 𝐋^2
    @test dimension(typeof(1m^2)) == 𝐋^2
    @test dimension(m^2) == 𝐋^2
    @test dimension(1m/s) == 𝐋/𝐓
    @test dimension(m/s) == 𝐋/𝐓
    @test dimension(1u"mol") == 𝐍
    @test dimension(μm/m) == Unitful.Dimensions{()}()
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
    @test isa(1rad, Angle)
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
    end

    @testset "> Addition and subtraction" begin
        @test +(1A) == 1A                     # Unary addition
        @test 3m + 3m == 6m                   # Binary addition
        @test -(1kg) == (-1)*kg               # Unary subtraction
        @test 3m - 2m == 1m                   # Binary subtraction
        @test zero(1m) === 0m                 # Additive identity
        @test zero(typeof(1m)) === 0m
        @test zero(typeof(1.0m)) === 0.0m
        @test_throws ErrorException 1+1m
        @test_throws ErrorException 1-1m
    end

    @testset "> Multiplication" begin
        @test *(1s) == 1s                     # Unary multiplication
        @test 3m * 2cm == 3cm * 2m            # Binary multiplication
        @test (3m)*m == 3*(m*m)               # Associative multiplication
        @test true*1kg == 1kg                 # Boolean multiplication (T)
        @test false*1kg == 0kg                # Boolean multiplication (F)
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
        @test m^3/m == m^2
        @test 𝐋^3/𝐋 == 𝐋^2
        @test sqrt(4m^2) == 2m                # sqrt works
        @test sqrt(4m^(2//3)) == 2m^(1//3)    # less trivial example
        @test sqrt(𝐋^2) == 𝐋
        @test sqrt(m^2) == m
        @test (2m)^3 == 8*m^3
        @test (8m)^(1//3) == 2*m^(1//3)
    end

    @testset "> Trigonometry" begin
        @test sin(90°) == 1                   # sin(degrees) works
        @test cos(π*rad) == -1                # ...radians work
    end

    @testset "> Is functions" begin
        @test isinteger(1.0m)
        @test !isinteger(1.4m)
        @test isfinite(1.0m)
        @test !isfinite(Inf*m)
    end

    @testset "> Floating point tests" begin
        @test frexp(1.5m) == (0.75m, 1.0)
        @test unit(nextfloat(0.0m)) == m
        @test unit(prevfloat(0.0m)) == m
    end
end

@testset "Rounding" begin
    @test trunc(3.7m) == 3.0m
    @test trunc(-3.7m) == -3.0m
    @test floor(3.7m) == 3.0m
    @test floor(-3.7m) == -4.0m
    @test ceil(3.7m) == 4.0m
    @test ceil(-3.7m) == -3.0m
    @test round(3.7m) == 4.0m
    @test round(-3.7m) == -4.0m
end

@testset "Sgn, abs, &c." begin
    @test abs(3V+4V*im) == 5V
    @test norm(3V+4V*im) == 5V
    @test abs2(3V+4V*im) == 25V^2
    @test abs(-3m) == 3m
    @test abs2(-3m) == 9m^2
    @test sign(-3.3m) == -1.0
    @test signbit(0.0m) == false
    @test signbit(-0.0m) == true
    @test copysign(3.0m, -4.0s) == -3.0m
    @test copysign(3.0m, 4) == 3.0m
    @test flipsign(3.0m, -4) == -3.0m
    @test flipsign(-3.0m, -4) == 3.0m
end

@testset "Collections" begin

    @testset "> Ranges" begin

        @testset ">> Some of test/ranges.jl, with units" begin
            @test size(10m:1m:0m) == (0,)
            # @test length(1m:.2m:2m) == 6
            # @test length(1.0m:.2m:2.0m) == 6
            # @test length(2m:-.2m:1m) == 6
            # @test length(2.0m:-.2m:1.0m) == 6
            @test length(2m:.2m:1m) == 0
            @test length(2.0m:.2m:1.0m) == 0

            @test length(1m:2m:0m) == 0
    #         L32 = linspace(Int32(1)*m, Int32(4)*m, 4)
    #         L64 = linspace(Int64(1)*m, Int64(4)*m, 4)
    #         @test L32[1] == 1m && L64[1] == 1m
    #         @test L32[2] == 2m && L64[2] == 2m
    #         @test L32[3] == 3m && L64[3] == 3m
    #         @test L32[4] == 4m && L64[4] == 4m

            r = 5m:-1m:1m
            @test r[1]==5m
            @test r[2]==4m
            @test r[3]==3m
            @test r[4]==2m
            @test r[5]==1m

            # @test length(.1m:.1m:.3m) == 3
            # @test length(1.1m:1.1m:3.3m) == 3
            @test length(1.1m:1.3m:3m) == 2
            @test length(1m:1m:1.8m) == 1

            @test (1m:2m:13m)[2:6] == 3m:2m:11m
            @test typeof((1m:2m:13m)[2:6]) == typeof(3m:2m:11m)
            @test (1m:2m:13m)[2:3:7] == 3m:6m:13m
            @test typeof((1m:2m:13m)[2:3:7]) == typeof(3m:6m:13m)
        end

        @testset ">> StepRange" begin
            r = 1m:1m:5m
            @test isa(r, StepRange)
            @test length(r) === 5
            @test step(r) === 1m
        end

        @testset ">> Float StepRange" begin
            @test isa((1.0m:1m:5m), StepRange{typeof(1.0m)})
            @test length(1.0m:1m:5m) === 5
            @test step(1.0m:1m:5m) === 1.0m

            @test_throws ArgumentError 1.0m:0.0m:5.0m
        end
    #     @testset ">> LinSpace" begin
    #         @test isa(linspace(1.0m, 3.0m, 5), LinSpace{typeof(1.0m)})
    #         @test isa(linspace(1.0m, 10m, 5), LinSpace{typeof(1.0m)})
    #         @test isa(linspace(1m, 10.0m, 5), LinSpace{typeof(1.0m)})
    #         @test isa(linspace(1m, 10m, 5), LinSpace{typeof(1.0m)})
    #         @test_throws ErrorException linspace(1m, 10, 5)
    #         @test_throws ErrorException linspace(1, 10m, 5)
    #     end
    #
    #     @testset ">> Range → Range" begin
    #         @test isa((1m:5m)*2, StepRange)
    #         @test isa((1m:5m)/2, FloatRange)
    #         @test isa((1m:2m:5m)/2, FloatRange)
    #     end
    #
    #     @testset ">> Range → Array" begin
    #         @test isa(collect(1m:5m), Array{typeof(1m),1})
    #         @test isa(collect(1m:2m:10m), Array{typeof(1m),1})
    #         @test isa(collect(1.0m:2m:10m), Array{typeof(1.0m),1})
    #         @test isa(collect(linspace(1.0m,10.0m,5)), Array{typeof(1.0m),1})
    #     end
    end

    @testset "> Array math" begin
        @testset ">> Array multiplication" begin
            @test @inferred([1m, 2m]' * [3m, 4m])    == [11m^2]
            @test @inferred([1V,2V]*[0.1/m, 0.4/m]') == [0.1V/m 0.4V/m; 0.2V/m 0.8V/m]
            @test @inferred([1m, 2m]' * [3/m, 4/m])  == [11]
            @test typeof([1m, 2m]' * [3/m, 4/m])     == Array{Int,1}
            @test @inferred([1m, 2V]' * [3/m, 4/V])  == [11]
            @test typeof([1m, 2V]' * [3/m, 4/V])     == Array{Int,1}
            @test @inferred([1m, 2V] * [3/m, 4/V]')  == [3 4u"m*V^-1"; 6u"V*m^-1" 8]
        end

        @testset ">> Element-wise multiplication" begin
            @test @inferred([1m, 2m, 3m] .* 5m)      == [5m^2, 10m^2, 15m^2]
            @test @inferred(5m .* [1m, 2m, 3m])      == [5m^2, 10m^2, 15m^2]
            @test @inferred(eye(2).*V)               == [1.0V 0.0V; 0.0V 1.0V]
            @test @inferred(V.*eye(2))               == [1.0V 0.0V; 0.0V 1.0V]
            @test @inferred([1V 2V; 0V 3V].*2)       == [2V 4V; 0V 6V]
        end

        @testset ">> Array addition" begin
            @test @inferred([1m, 2m] + [3m, 4m])     == [4m, 6m]
            @test @inferred([1m, 2m] + [1m, 1cm])    == [2m, 201m//100]
            @test @inferred([1m] + [1cm])            == [(101//100)*m]
            @test_throws ErrorException [1m] + [2V]
            @test_throws ErrorException [1] + [1m]
        end

        @testset ">> Element-wise addition" begin
            @test @inferred(5m .+ [1m, 2m, 3m])      == [6m, 7m, 8m]
        end
    end
end

nothing
