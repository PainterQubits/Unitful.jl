@testset "Dates stdlib" begin
    @testset "> dimension, numtype, unit, ustrip" begin
        for (T,u) = ((Nanosecond, u"ns"), (Microsecond, u"μs"), (Millisecond, u"ms"),
                     (Second, u"s"), (Minute, u"minute"), (Hour, u"hr"), (Day, u"d"),
                     (Week, u"wk"))
            @test dimension(T) === dimension(T(1)) === 𝐓
            @test Unitful.numtype(T) === Unitful.numtype(T(1)) === typeof(Dates.value(T(1)))
            @test unit(T) === unit(T(1)) === u
            @test ustrip(T(5)) === Int64(5)
        end
        for T = (Month, Year)
            @test_throws MethodError dimension(T)
            @test_throws MethodError dimension(T(1))
            @test_throws MethodError Unitful.numtype(T)
            @test_throws MethodError Unitful.numtype(T(1))
            @test_throws MethodError unit(T)
            @test_throws MethodError unit(T(1))
            @test_throws MethodError ustrip(T(1))
        end
    end

    @testset "> Arithmetic" begin
        @testset ">> Addition/subtraction" begin
            @test Second(3) + 5u"ms" === Int64(3)u"s" + 5u"ms"
            @test Second(3) - 5u"ms" === Int64(3)u"s" - 5u"ms"
            @test 1.0u"wk" + Day(3) === 1.0u"wk" + Int64(3)u"d"
            @test 1.0u"wk" - Day(3) === 1.0u"wk" - Int64(3)u"d"
            @test_throws DimensionError 1u"m" + Second(1)
            @test_throws DimensionError 1u"m" - Second(1)
        end

        @testset ">> Multiplication" begin
            # Multiplication with quantity
            @test Int64(3)u"m" * Day(1) === Int64(3)u"m*d"
            @test 1.0f0u"m" * Microsecond(-2) === -2.0f0u"m*μs"
            @test Hour(4) * Int32(2)u"m" === Int64(8)u"hr*m"
            @test Second(5) * (3//2)u"Hz" === Rational{Int64}(15//2)u"s*Hz"
            @test Second(5) * 2u"1/s" === Int64(10)
            @test 2.5u"1/s^2" * Second(2) === 5.0u"1/s"
            @test_throws AffineError Second(1) * 1u"°C"
            @test_throws AffineError 1u"°C" * Second(1)
            # Multiplication with unit
            Week(5) * u"Hz" === 5.0u"wk*Hz"
            u"mm" * Millisecond(20) === Int64(20)u"mm*ms"
            u"ms^-1" * Millisecond(20) === Int64(20)
            @test_throws AffineError Second(1) * u"°C"
            @test_throws AffineError u"°C" * Second(1)
            # Multiple factors
            @test 3.0u"s" * Second(3) * (3//1)u"s" === 27.0u"s^3"
            @test 3.0u"s" * Second(3) * Minute(3) === 27.0u"s^2*minute"
            @test u"s" * Second(3) * u"minute" === Int64(3)u"s^2*minute"
            @test Second(3) * u"m" * u"m" === Int64(3)u"s*m^2"
        end

        @testset ">> Division" begin
            # /
            @test Nanosecond(10) / 2u"m" === 5.0u"ns/m"
            @test Nanosecond(10) / 2.0f0u"m" === 5.0f0u"ns/m"
            @test 5u"m" / Hour(2) === 2.5u"m/hr"
            @test 5.0f0u"m" / Hour(2) === 2.5f0u"m/hr"
            # //
            @test Nanosecond(10) // 2u"m" === Rational{Int64}(5//1)u"ns/m"
            @test 5u"m" // Hour(2) === Rational{Int64}(5//2)u"m/hr"
            # div
            @test div(Second(1), 2u"ms") == div(1u"s", Millisecond(2)) == 500
            @test div(Second(11), 2u"s") == div(11u"s", Second(2)) == 5
            @test div(Second(-5), 2u"s") == div(-5u"s", Second(2)) == -2
            @test_throws DimensionError div(Second(1), 1u"m")
            @test_throws DimensionError div(1u"m", Second(1))
            # fld
            @test fld(Second(1), 2u"ms") == fld(1u"s", Millisecond(2)) == 500
            @test fld(Second(11), 2u"s") == fld(11u"s", Second(2)) == 5
            @test fld(Second(-5), 2u"s") == fld(-5u"s", Second(2)) == -3
            @test_throws DimensionError fld(Second(1), 1u"m")
            @test_throws DimensionError fld(1u"m", Second(1))
            # cld
            @test cld(Second(1), 2u"ms") == cld(1u"s", Millisecond(2)) == 500
            @test cld(Second(11), 2u"s") == cld(11u"s", Second(2)) == 6
            @test cld(Second(-5), 2u"s") == cld(-5u"s", Second(2)) == -2
            @test_throws DimensionError cld(Second(1), 1u"m")
            @test_throws DimensionError cld(1u"m", Second(1))
            # mod
            @test mod(Second(11), 3_000u"ms") == mod(11u"s", Millisecond(3_000)) == 2u"s"
            @test mod(Second(11), -3u"s") == mod(11u"s", Second(-3)) == -1u"s"
            @test_throws DimensionError mod(Second(1), 1u"m")
            @test_throws DimensionError mod(1u"m", Second(1))
            # rem
            @test rem(Second(11), 3_000u"ms") == rem(11u"s", Millisecond(3_000)) == 2u"s"
            @test rem(Second(11), -3u"s") == rem(11u"s", Second(-3)) == 2u"s"
            @test_throws DimensionError rem(Second(1), 1u"m")
            @test_throws DimensionError rem(1u"m", Second(1))
        end

        @testset ">> atan" begin
            @test atan(Minute(1), 30u"s") == atan(2,1)
            @test atan(1u"ms", Millisecond(5)) == atan(1,5)
            @test_throws DimensionError atan(Second(1), 1u"m")
            @test_throws DimensionError atan(1u"m", Second(1))
        end
    end

    @testset "> Conversion" begin
        @test uconvert(u"s", Second(3)) === Int64(3)u"s"
        @test uconvert(u"hr", Minute(90)) === Rational{Int64}(3//2)u"hr"
        @test uconvert(u"ns", Millisecond(-2)) === Int64(-2_000_000)u"ns"
        @test uconvert(u"wk", Hour(1)) === Rational{Int64}(1//168)u"wk"
        @test_throws DimensionError uconvert(u"m", Second(1))

        @test convert(typeof(1.0u"s"), Second(3)) === 3.0u"s"
        @test convert(typeof((1//1)u"s"), Second(3)) === (3//1)u"s"
        @test convert(typeof(1.0u"d"), Hour(6)) === 0.25u"d"
        @test_throws DimensionError convert(typeof(1.0u"m"), Week(1))

        @test Week(4u"wk") === Week(4)
        @test Microsecond((3//2)u"ms") === Microsecond(1500)
        @test Millisecond(1.0u"s") === Millisecond(1000)
        @test_throws DimensionError Second(1u"m")

        @test convert(Second, 1.0u"s") === Second(1)
        @test convert(Day, 3u"wk") === Day(21)
        @test_throws DimensionError convert(Second, 1u"m")
        @test_throws InexactError convert(Second, 1u"ms")
        @test_throws InexactError convert(Second, 1.5u"s")
    end

    @testset "> Rounding" begin
        @test round(Second, -1.2u"s") === round(Second, -1.2u"s", RoundNearest) === Second(-1)
        @test round(Second, -1.5u"s") === round(Second, -1.5u"s", RoundNearest) === Second(-2)
        @test round(Second, -0.5u"s") === round(Second, -0.5u"s", RoundNearest) === Second(0)
        @test round(Minute,   45u"s") === round(Minute,   45u"s", RoundNearest) === Minute(1)
        @test round(Minute,   90u"s") === round(Minute,   90u"s", RoundNearest) === Minute(2)
        @test round(Minute,  150u"s") === round(Minute,  150u"s", RoundNearest) === Minute(2)
        @test round(Second, -1.2u"s", RoundNearestTiesAway) === Second(-1)
        @test round(Second, -1.5u"s", RoundNearestTiesAway) === Second(-2)
        @test round(Second, -0.5u"s", RoundNearestTiesAway) === Second(-1)
        @test round(Minute,   45u"s", RoundNearestTiesAway) === Minute(1)
        @test round(Minute,   90u"s", RoundNearestTiesAway) === Minute(2)
        @test round(Minute,  150u"s", RoundNearestTiesAway) === Minute(3)
        @test round(Second, -1.2u"s", RoundNearestTiesUp) === Second(-1)
        @test round(Second, -1.5u"s", RoundNearestTiesUp) === Second(-1)
        @test round(Second, -0.5u"s", RoundNearestTiesUp) === Second(0)
        @test round(Minute,   45u"s", RoundNearestTiesUp) === Minute(1)
        @test round(Minute,   90u"s", RoundNearestTiesUp) === Minute(2)
        @test round(Minute,  150u"s", RoundNearestTiesUp) === Minute(3)
        @test trunc(Second, -1.2u"s") === round(Second, -1.2u"s", RoundToZero) === Second(-1)
        @test trunc(Second, -1.5u"s") === round(Second, -1.5u"s", RoundToZero) === Second(-1)
        @test trunc(Second, -0.5u"s") === round(Second, -0.5u"s", RoundToZero) === Second(0)
        @test ceil(Second, -1.2u"s")  === round(Second, -1.2u"s", RoundUp) === Second(-1)
        @test ceil(Second, -1.5u"s")  === round(Second, -1.5u"s", RoundUp) === Second(-1)
        @test ceil(Second, -0.5u"s")  === round(Second, -0.5u"s", RoundUp) === Second(0)
        @test floor(Second, -1.2u"s") === round(Second, -1.2u"s", RoundDown) === Second(-2)
        @test floor(Second, -1.5u"s") === round(Second, -1.5u"s", RoundDown) === Second(-2)
        @test floor(Second, -0.5u"s") === round(Second, -0.5u"s", RoundDown) === Second(-1)
        @static if VERSION ≥ v"1.5.0-DEV.742"
            @test trunc(Minute,  45u"s") === round(Minute,   45u"s", RoundToZero) === Minute(0)
            @test trunc(Minute,  90u"s") === round(Minute,   90u"s", RoundToZero) === Minute(1)
            @test trunc(Minute, 150u"s") === round(Minute,  150u"s", RoundToZero) === Minute(2)
            @test ceil(Minute,  45u"s")  === round(Minute,   45u"s", RoundUp) === Minute(1)
            @test ceil(Minute,  90u"s")  === round(Minute,   90u"s", RoundUp) === Minute(2)
            @test ceil(Minute, 150u"s")  === round(Minute,  150u"s", RoundUp) === Minute(3)
            @test floor(Minute,  45u"s") === round(Minute,   45u"s", RoundDown) === Minute(0)
            @test floor(Minute,  90u"s") === round(Minute,   90u"s", RoundDown) === Minute(1)
            @test floor(Minute, 150u"s") === round(Minute,  150u"s", RoundDown) === Minute(2)
        end
        @test_throws DimensionError round(Second, 1u"m")
        @test_throws DimensionError round(Second, 1u"m", RoundNearestTiesUp)
        @test_throws DimensionError trunc(Second, 1u"m")
        @test_throws DimensionError ceil(Second, 1u"m")
        @test_throws DimensionError floor(Second, 1u"m")
        @test round(u"minute", Second(-50)) === round(u"minute", Second(-50), RoundNearest) === (-1//1)u"minute"
        @test round(u"minute", Second(-90)) === round(u"minute", Second(-90), RoundNearest) === (-2//1)u"minute"
        @test round(u"minute", Second(150)) === round(u"minute", Second(150), RoundNearest) === (2//1)u"minute"
        @test round(u"minute", Second(-50), RoundNearestTiesAway) === (-1//1)u"minute"
        @test round(u"minute", Second(-90), RoundNearestTiesAway) === (-2//1)u"minute"
        @test round(u"minute", Second(150), RoundNearestTiesAway) === (3//1)u"minute"
        @test round(u"minute", Second(-50), RoundNearestTiesUp) === (-1//1)u"minute"
        @test round(u"minute", Second(-90), RoundNearestTiesUp) === (-1//1)u"minute"
        @test round(u"minute", Second(150), RoundNearestTiesUp) === (3//1)u"minute"
        @static if VERSION ≥ v"1.5.0-DEV.742"
            @test trunc(u"minute", Second(-50)) === round(u"minute", Second(-50), RoundToZero) === (0//1)u"minute"
            @test trunc(u"minute", Second(-90)) === round(u"minute", Second(-90), RoundToZero) === (-1//1)u"minute"
            @test trunc(u"minute", Second(150)) === round(u"minute", Second(150), RoundToZero) === (2//1)u"minute"
            @test ceil(u"minute", Second(-50))  === round(u"minute", Second(-50), RoundUp) === (0//1)u"minute"
            @test ceil(u"minute", Second(-90))  === round(u"minute", Second(-90), RoundUp) === (-1//1)u"minute"
            @test ceil(u"minute", Second(150))  === round(u"minute", Second(150), RoundUp) === (3//1)u"minute"
            @test floor(u"minute", Second(-50)) === round(u"minute", Second(-50), RoundDown) === (-1//1)u"minute"
            @test floor(u"minute", Second(-90)) === round(u"minute", Second(-90), RoundDown) === (-2//1)u"minute"
            @test floor(u"minute", Second(150)) === round(u"minute", Second(150), RoundDown) === (2//1)u"minute"
        end
        @test_throws DimensionError round(u"m", Second(1))
        @test_throws DimensionError round(u"m", Second(1), RoundNearestTiesAway)
        @test_throws DimensionError trunc(u"m", Second(1))
        @test_throws DimensionError ceil(u"m", Second(1))
        @test_throws DimensionError floor(u"m", Second(1))
        @test round(u"wk", Day(10), digits=1) === 1.4u"wk"
        @test round(u"wk", Day(10), sigdigits=3) === 1.43u"wk"
        @test round(u"wk", Day(10), RoundUp, digits=1) === 1.5u"wk"
        @test floor(u"wk", Day(10), sigdigits=3) === round(u"wk", Day(10), RoundDown, sigdigits=3) === 1.42u"wk"
        @test ceil(u"wk", Day(10), digits=2, base=2) === round(u"wk", Day(10), RoundUp, digits=2, base=2) === 1.5u"wk"
        @test trunc(u"wk", Day(10), digits=2, base=2) === round(u"wk", Day(10), RoundToZero, digits=2, base=2) === 1.25u"wk"
        @test_throws DimensionError round(u"m", Day(10), digits=1)
        @test_throws DimensionError round(u"m", Day(10), sigdigits=3, base=2)
        @test_throws DimensionError round(u"m", Day(10), RoundUp, digits=1)
        @test_throws DimensionError trunc(u"m", Day(10), digits=1)
        @test_throws DimensionError ceil(u"m", Day(10), sigdigits=3)
        @test_throws DimensionError floor(u"m", Day(10), digits=1, base=2)
        @test round(Int, u"minute", Second(-50)) === -1u"minute"
        @static if VERSION ≥ v"1.5.0-DEV.742"
            @test floor(Int, u"minute", Second(50)) === round(Int, u"minute", Second(50), RoundDown) === 0u"minute"
            @test ceil(Int, u"minute", Second(50)) === round(Int, u"minute", Second(50), RoundUp) === 1u"minute"
            @test trunc(Int, u"minute", Second(50)) === round(Int, u"minute", Second(50), RoundToZero) === 0u"minute"
        end
        @test round(Float32, u"minute", Second(-50)) === -1.0f0u"minute"
        @static if VERSION ≥ v"1.5.0-DEV.742"
            @test floor(Float32, u"minute", Second(50)) === round(Float32, u"minute", Second(50), RoundDown) === 0.0f0u"minute"
            @test ceil(Float32, u"minute", Second(50)) === round(Float32, u"minute", Second(50), RoundUp) === 1.0f0u"minute"
            @test trunc(Float32, u"minute", Second(50)) === round(Float32, u"minute", Second(50), RoundToZero) === 0.0f0u"minute"
        end
        @test round(Float32, u"wk", Day(10), digits=1) === 1.4f0u"wk"
        @test round(Float32, u"wk", Day(10), sigdigits=3) === 1.43f0u"wk"
        @test round(Float32, u"wk", Day(10), RoundUp, digits=1) === 1.5f0u"wk"
        @test floor(Float32, u"wk", Day(10), sigdigits=3) === round(Float32, u"wk", Day(10), RoundDown, sigdigits=3) === 1.42f0u"wk"
        @test ceil(Float32, u"wk", Day(10), digits=2, base=2) === round(Float32, u"wk", Day(10), RoundUp, digits=2, base=2) === 1.5f0u"wk"
        @test trunc(Float32, u"wk", Day(10), digits=2, base=2) === round(Float32, u"wk", Day(10), RoundToZero, digits=2, base=2) === 1.25f0u"wk"
        @test_throws DimensionError round(Float32, u"m", Second(-50))
        @test_throws DimensionError round(Float32, u"m", Second(-50), RoundDown)
        @test_throws DimensionError round(Float32, u"m", Second(-50), digits=1)
        @test_throws DimensionError round(Float32, u"m", Second(-50), RoundDown, sigdigits=3)
        @test_throws DimensionError floor(Float32, u"m", Second(-50))
        @test_throws DimensionError ceil(Float32, u"m", Second(-50), digits=1)
        @test_throws DimensionError trunc(Float32, u"m", Second(-50), sigdigits=3, base=2)
        @test round(typeof(1.0f0u"minute"), Second(-50)) === -1.0f0u"minute"
        @static if VERSION ≥ v"1.5.0-DEV.742"
            @test round(typeof(1.0f0u"minute"), Second(50), RoundToZero) === 0.0f0u"minute"
        end
        @test round(typeof(1.0f0u"wk"), Day(10), digits=1) === 1.4f0u"wk"
        @test round(typeof(1.0f0u"wk"), Day(10), sigdigits=3) === 1.43f0u"wk"
        @test round(typeof(1.0f0u"wk"), Day(10), RoundUp, digits=1) === 1.5f0u"wk"
        @test floor(typeof(1.0f0u"wk"), Day(10), sigdigits=3) === round(typeof(1.0f0u"wk"), Day(10), RoundDown, sigdigits=3) === 1.42f0u"wk"
        @test ceil(typeof(1.0f0u"wk"), Day(10), digits=2, base=2) === round(typeof(1.0f0u"wk"), Day(10), RoundUp, digits=2, base=2) === 1.5f0u"wk"
        @test trunc(typeof(1.0f0u"wk"), Day(10), digits=2, base=2) === round(typeof(1.0f0u"wk"), Day(10), RoundToZero, digits=2, base=2) === 1.25f0u"wk"
        @test_throws DimensionError round(typeof(1.0u"m"), Second(1))
        @test_throws DimensionError round(typeof(1.0u"m"), Second(1), RoundToZero)
        @test_throws DimensionError round(typeof(1.0u"m"), Second(1), digits=1)
        @test_throws DimensionError round(typeof(1.0u"m"), Second(1), RoundToZero, sigdigits=2)
        @test_throws DimensionError floor(typeof(1.0u"m"), Second(1))
        @test_throws DimensionError ceil(typeof(1.0u"m"), Second(1), sigdigits=2, base=2)
        @test_throws DimensionError trunc(typeof(1.0u"m"), Second(1), digits=1)
    end

    @testset "> Comparison" begin
        # ==
        @test Second(2) == 2.0u"s"
        @test 72u"hr" == Day(3)
        @test Millisecond(0) == -0.0u"ms"
        @test !(Day(4) == 4u"hr")
        @test !(4u"cm" == Day(4))
        # isequal
        @test isequal(Second(2), 2.0u"s")
        @test isequal(72u"hr", Day(3))
        @test !isequal(Millisecond(0), -0.0u"ms") # !isequal(0.0, -0.0)
        @test !isequal((Day(4), 4u"hr"))
        @test !isequal((4u"cm", Day(4)))
        # <
        @test Second(1) < 1001u"ms"
        @test 3u"minute" < Minute(4)
        @test !(Minute(3) < 3u"minute")
        @test !(7u"d" < Week(1))
        @test !(-0.0u"d" < Day(0))
        @test_throws DimensionError 7u"kg" < Day(1)
        @test_throws DimensionError Day(1) < 7u"kg"
        # isless
        @test isless(Second(1), 1001u"ms")
        @test isless(3u"minute", Minute(4))
        @test !isless(Minute(3), 3u"minute")
        @test !isless(7u"d", Week(1))
        @test isless(-0.0u"d", Day(0))
        @test_throws DimensionError isless(7u"kg", Day(1))
        @test_throws DimensionError isless(Day(1), 7u"kg")
        # ≤
        @test Second(1) ≤ 1001u"ms"
        @test 7u"d" ≤ Week(1)
        @test !(Minute(4) ≤ 3u"minute")
        @test_throws DimensionError 7u"kg" ≤ Day(1)
        @test_throws DimensionError Day(1) ≤ 7u"kg"
        # min
        @test min(1u"s", Microsecond(100)) == Microsecond(100)
        @test min(Day(1), 1u"hr") == 1u"hr"
        @test_throws DimensionError min(1u"kg", Second(1))
        @test_throws DimensionError min(Second(1), 1u"kg")
        # max
        @test max(1u"s", Microsecond(100)) == 1u"s"
        @test max(Day(1), 1u"hr") == Day(1)
        @test_throws DimensionError max(1u"kg", Second(1))
        @test_throws DimensionError max(Second(1), 1u"kg")
    end

    @testset "> isapprox" begin
        # scalar arguments
        @test isapprox(nextfloat(1.0)u"s", Second(1))
        @test isapprox(1.0u"s", Second(1), rtol=0)
        @test isapprox(Second(2), 2500u"ms", atol=1u"s")
        @test isapprox(Second(2), 2500u"ms", atol=Second(1))
        @test isapprox(2500u"ms", Second(2), rtol=0.5)
        @test !isapprox(2500u"ms", Second(2), rtol=0.1)
        @test !isapprox(nextfloat(1.0)u"s", Second(1), rtol=0)
        @test !isapprox(Second(1), 1u"m")
        @test !isapprox(1u"m", Second(1))
        @test !isapprox(Second(1), 1u"m", atol=1u"kg")
        @test !isapprox(1u"m", Second(1), atol=Second(1))
        @test_throws DimensionError isapprox(Second(2), 2500u"ms", atol=0.5)
        @test_throws DimensionError isapprox(Second(2), 2500u"ms", atol=0.5u"m")
        # array arguments
        @test isapprox([Second(-5), Second(5)], [-5.0u"s", 5.0u"s"])
        @test isapprox([Second(-5), Second(5)], [-4.99u"s", 5.01u"s"], rtol=1e-2)
        @test_broken isapprox([1u"s", 60u"s"], Period[Second(1), Minute(1)], rtol=0)
        @test !isapprox([1.0u"kg"], [Second(1)])
    end

    @testset "> promote" begin
        @test promote(1u"d", Minute(1)) === promote(1u"d", Int64(1)u"minute")
        @test promote(Second(10), 2.0u"fs") === promote(Int64(10)u"s", 2.0u"fs")
        @test_throws ErrorException promote(1u"m", Second(1))
        @test_throws ErrorException promote(Day(1), 3u"T")
    end
end
