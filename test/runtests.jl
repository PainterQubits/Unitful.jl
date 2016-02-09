using Unitful
using Base.Test

# Conversion
@testset "Conversion" begin
    @testset "Unitless <--> unitful" begin
        @test convert(typeof(3m),1) === 1m
        @test convert(Float64, 3m) === Float64(3.0)
        @test float(3m) == 3.0
        @test Integer(3m) == 3
    end

    @testset "Unitful <--> unitful" begin
        @testset "Intra-unit conversion" begin
            @test 1kg == 1000g                    # Equivalence implies unit conversion
            @test !(1kg === 1000g)                # ...and yet we can distinguish these...
            @test 1kg === 1kg                     # ...and these are indistinguishable.
        end
        @testset "Inter-unit conversion" begin
            @test 1inch == 2.54cm                 # Exact because an SI unit is involved.
            @test 1ft ≈ 12inch                    # Approx because of an error O(ϵ)...
        end
    end
end

@testset "Mathematics" begin
    @testset "Equality, comparison" begin
        @test 1m == 1m                        # Identity
        @test 3mm != 3*(m*m)                  # mm not interpreted as m*m
        @test 3*(m*m) != 3mm
        @test 1m != 1                         # w/ units distinct from w/o units
        @test 1 != 1m
        @test min(1h, 1s) == 1s               # take scale of units into account
        @test max(1ft, 1m) == 1m
        @test max(km, m) == km        # implicit ones to compare units directly
    end

    @testset "Addition and subtraction" begin
        @test +(1A) == 1A                     # Unary addition
        @test 3m + 3m == 6m                   # Binary addition
        @test -(1kg) == (-1)*kg               # Unary subtraction
        @test 3m - 2m == 1m                   # Binary subtraction
    end

    @testset "Multiplication" begin
        @test *(1s) == 1s                     # Unary multiplication
        @test 3m * 2cm == 3cm * 2m            # Binary multiplication
        @test (3m)*m == 3*(m*m)               # Associative multiplication
        @test true*1kg == 1kg                 # Boolean multiplication (T)
        @test false*1kg == 0kg                # Boolean multiplication (F)
    end

    @testset "Division" begin
        @test 2m // 5s == (2//5)*(m/s)        # Units propagate through rationals
        @test (2//3)*m // 5 == (2//15)*m      # Quantity // Real
        @test (m//2) === 1//2 * m             # Unit // Real
        @test (2//m) === (2//1) / m           # Real // Unit
        @test (m//s) === m/s                  # Unit // Unit
        @test div(10m, -3cm) == -333.0
        @test fld(10m, -3cm) == -334.0
        @test rem(10m, -3cm) == 1.0cm
        @test mod(10m, -3cm) == -2.0cm
        @test mod(1h+3minute+5s, 24s) == 17s
        @test inv(s) == s^-1
    end

    @test sqrt(4m^2) == 2m                # sqrt works
    @test sqrt(4m^(2//3)) == 2m^(1//3)    # less trivial example
    @test sin(90°) == 1                   # sin(degrees) works
    @test cos(π*rad) == -1                # ...radians work

    @test isinteger(1.0m)
    @test !isinteger(1.4m)
    @test isfinite(1.0m)
    @test !isfinite(Inf*m)

    @test frexp(1.5m) == (0.75m, 1.0)
    @test unit(nextfloat(0.0m)) == m
    @test unit(prevfloat(0.0m)) == m
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

    @testset "Ranges" begin

        @testset "Some test/ranges.jl tests, with units" begin
            @test size(10m:1m:0m) == (0,)
            @test length(1m:.2m:2m) == 6
            @test length(1.m:.2m:2.m) == 6
            @test length(2m:-.2m:1m) == 6
            @test length(2.m:-.2m:1.m) == 6
            @test length(2m:.2m:1m) == 0
            @test length(2.m:.2m:1.m) == 0

            @test length(1m:0m) == 0
            @test length(0.0m:-0.5m) == 0
            @test length(1m:2m:0m) == 0

            # L32 = linspace(Int32(1)*m, Int32(4)*m, 4)
            # L64 = linspace(Int64(1)*m, Int64(4)*m, 4)
            # @test L32[1] == 1 && L64[1] == 1
            # @test L32[2] == 2 && L64[2] == 2
            # @test L32[3] == 3 && L64[3] == 3
            # @test L32[4] == 4 && L64[4] == 4
        end

        @testset "UnitRange" begin
            @test isa((1m:5m), UnitRange{typeof(1m)})
            @test length(1m:5m) === 5
            @test step(1m:5m) === 1m
        end

        @testset "StepRange" begin
            @test isa((1m:1m:5m), StepRange)
            @test length(1m:1m:5m) === 5
            @test step(1m:1m:5m) === 1m
        end

        @testset "FloatRange" begin
            @test isa((1.0m:1m:5m), FloatRange{typeof(1.0m)})
            @test length(1.0m:1m:5m) === 5
            @test step(1.0m:1m:5m) === 1.0m
        end

        @testset "LinSpace" begin
            @test isa(linspace(1.0m, 3.0m, 5), LinSpace{typeof(1.0m)})
        end

        @testset "Range → Range" begin
            @test isa((1m:5m)*2, StepRange)
            @test isa((1m:5m)/2, FloatRange)
            @test isa((1m:2m:5m)/2, FloatRange)
        end

        @testset "Range → Array" begin
            @test isa(collect(1m:5m), Array{typeof(1m),1})
            @test isa(collect(1m:2m:10m), Array{typeof(1m),1})
            @test isa(collect(1.0m:2m:10m), Array{typeof(1.0m),1})
            @test isa(collect(linspace(1.0m,10.0m,5)), Array{typeof(1.0m),1})
        end
    end

    @testset "Array math" begin
        @test @inferred([1m, 2m]' * [3m, 4m]) == [11m^2]
        @test @inferred([1m, 2m, 3m] .* 5m)   == [5m^2, 10m^2, 15m^2]
        @test @inferred(5m .* [1m, 2m, 3m])   == [5m^2, 10m^2, 15m^2]
        @test @inferred(5m .+ [1m, 2m, 3m])   == [6m, 7m, 8m]
        @test @inferred([1m, 2m] + [3m, 4m])  == [4m, 6m]
    end
end

nothing
