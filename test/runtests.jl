using Unitful
using Base.Test

# Commented tests are failing at the moment.

# Basic mathematics
@test 1m == 1m                        # Identity
@test *(1s) == 1s                     # Unary multiplication
@test +(1A) == 1A                     # Unary addition
@test -(1kg) == (-1)*kg               # Unary subtraction
@test 3m + 3m == 6m                   # Binary addition
@test 3m * 2cm == 3cm * 2m            # Binary multiplication
@test (3m)*m == 3*(m*m)               # Associative multiplication
@test 2m // 5s == (2//5)*(m/s)        # Units propagate through rationals
@test abs(-3m) == 3m
@test sqrt(4m^2) == 2m                # sqrt works
@test sqrt(4m^(2//3)) == 2m^(1//3)    # less trivial example
@test sin(90°) == 1                   # sin(degrees) works
@test cos(π*rad) == -1                # ...radians work
@test mod(1h+3minute+5s, 24s) == 17s  # mod works
@test min(1h, 1s) == 1s
@test max(1ft, 1m) == 1m
@test isinteger(1.0m)
@test !isinteger(1.4m)
@test isfinite(1.0m)
@test !isfinite(Inf*m)
@test inv(s) == s^-1
# @test 3mm != 3*(m*m)                # mm not interpreted as m*m
# @test 1m != 1                       # w/ units distinct from w/o units

# Unit conversion
    # intra-unit
@test 1kg == 1000g                    # Equivalence implies unit conversion
@test !(1kg === 1000g)                # ...and yet we can distinguish these...
@test 1kg === 1kg                     # ...and these are indistinguishable.
    # inter-unit
@test 1inch == 2.54cm                 # Exact because an SI unit is involved.
@test 1ft ≈ 12inch                    # Approx because of an error O(ϵ)...


# Ranges
@test isa((1m:5m), UnitRange)
@test isa((1.0m:5m), StepRange)
@test isa(collect(1m:5m), Array)

# Conversion
# @test convert(Float64, 3m) == 3.0
@test convert(typeof(3m),1) == 1m
