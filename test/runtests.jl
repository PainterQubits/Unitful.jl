using Unitful
using Base.Test

# Commented tests are failing at the moment.

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
        @test isa((1m:5m), UnitRange)
        @test isa((1.0m:5m), StepRange)
        @test isa(collect(1m:5m), Array)
    end

    @testset "Array math" begin
        @test @inferred([1m, 2m, 3m] .* 5m)  == [5m^2, 10m^2, 15m^2]
        @test @inferred(5m .* [1m, 2m, 3m])  == [5m^2, 10m^2, 15m^2]
        @test @inferred([1m, 2m] + [3m, 4m]) == [4m, 6m]
    end
end


nothing
