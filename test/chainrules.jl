using ChainRulesCore: rrule, ProjectTo, NoTangent

@testset "ProjectTo" begin
    real_test(proj, val) = proj(val) == real(val)
    complex_test(proj, val) = proj(val) == val
    uval = 8.0*u"W"
    p_uval = ProjectTo(uval)
    cuval = (1.0+im)*u"kg"
    p_cuval = ProjectTo(cuval)

    p_real = ProjectTo(1.0)
    p_complex = ProjectTo(1.0+im)

    δval = 6.0*u"m"
    δcval = (2.0+3.0im)*u"L"

    # Test projection onto real unitful quantities
    for δ in (δval, δcval, 1.0, 1.0+im)
        @test real_test(p_uval, δ)
    end

    # Test projection onto complex unitful quantities
    for δ in (δval, δcval, 1.0, 1.0+im)
        @test complex_test(p_cuval, δ)
    end 

    # Projecting Unitful quantities onto real values
    @test p_real(δval) == δval
    @test p_real(δcval) == real(δcval)

    # Projecting Unitful quantities onto complex values
    @test p_complex(δval) == δval
    @test p_complex(δcval) == δcval
end

@testset "rrules" begin
    @testset "Quantity rrule" begin
        UT = typeof(1.0*u"W")
        x = 5.0
        Ω, pb = rrule(UT, x)
        @test Ω == 5.0 * u"W"
        @test pb(3.0) == (NoTangent(), 3.0 * u"W")
    end
    @testset "* rrule" begin
        x = 5.0*u"W" 
        y = u"m"
        z = u"L"
        Ω, pb = rrule(*, x, y, z)
        @test Ω == x*y*z
        @test pb(3.0) == (NoTangent(), 3.0*y*z, NoTangent(), NoTangent())
    end
end