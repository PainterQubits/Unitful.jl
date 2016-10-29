using Base.Test
using Unitful: dimensional_space, Dimensions, Dimension, dimensional_matrix,
    two_by_two_independant, independant_columns, project_on_basis, @u_str,
    simplify
@testset "Type simplification" begin
    @testset "> Actual simplification" begin
        @test simplify(u"cm") === u"cm"
        @test simplify(2u"cm") === 2u"cm"
        @test simplify(u"cm/m") == u"m/m"
        @test simplify(1u"cm/m") == 1//100
        @test simplify(2.4u"cm/m") == 2.4 * 1//100
        @test simplify(u"m*m*km*J/cm") == u"J*cm^2"
        @test simplify(1u"m*m*km*J/cm") == 1000000000//1 * u"J*cm^2"
		@test 1u"m*m*km*J/cm" == 1000000000//1 * u"J*cm^2"
		@test simplify(u"m*m*km*J/cm/N") == u"cm^3"
		@test simplify(2u"m*m*km*J/cm/N") == 200000000000//1 *u"cm^3"
		@test 1u"m*m*km*J/cm/N" == 100000000000//1 *u"cm^3"
    end

    @testset "> Count dimensions in a unit" begin
        @test dimensional_space(u"m/m") === Dimensions{()}
        @test dimensional_space(u"m/km") ===
            Dimensions{(Dimension{:Length}(1//1),)}
        @test dimensional_space(u"m/s") ===
            Dimensions{(Dimension{:Length}(1//1), Dimension{:Time}(1//1))}
        @test dimensional_space(u"m/s*J") ===
            Dimensions{(
                    Dimension{:Length}(1//1),
                    Dimension{:Mass}(1//1),
                    Dimension{:Time}(1//1)
            )}
    end

    @testset "> Transform unit to matrix format" begin
        @test size(dimensional_matrix(u"m/m")) == (0, 0)
        @test dimensional_matrix(u"m/km") == [1//1 -1//1]
        @test dimensional_matrix(u"m/km*s") == [1//1 -1//1 0;0 0 1//1]
        @test dimensional_matrix(u"m/km*s/J") ==
            [-2//1 1//1 -1//1 0;-1//1 0 0 0; 2//1 0 0 1//1]
    end

    @testset "> Math" begin
        @testset ">> No two columns are colinear" begin
           @test two_by_two_independant(Matrix{Rational{Int}}()) == Int64[]
           @test two_by_two_independant([1 1; 1 1][2:1, :]) == [1, 2]
           @test two_by_two_independant([1 1; 1 1][:, 2:1]) == []
           @test two_by_two_independant([1 1; 1 1]) == [1]
           @test two_by_two_independant([1 1; 1 12]) == [1, 2]
           @test two_by_two_independant(transpose([1 1; 8 8; 2 12; 1 6])) ==
                    [1, 3]
           @test two_by_two_independant([1 0 1; 0 1 1]) == [1, 2, 3]
        end

        @testset ">> All the columns are linearly independant" begin
            @test independant_columns(Matrix{Rational{Int}}()) == Int64[]
            @test independant_columns([1 1; 1 1][2:1, :]) == [1, 2]
            @test independant_columns([1 1; 1 1][:, 2:1]) == []
            @test independant_columns([1 1; 1 1]) == [1]
            @test independant_columns([1 0 1; 0 1 1]) == [1, 2]
            @test independant_columns([1 0 1; 2 1 0]) == [2, 3]
        end

        @testset ">> Project a vector on an orthogonal basis" begin
            vector = [1, 2]
            matrix = [1 -1; 1 1]
            proj, res = project_on_basis(vector, matrix)
            @test res == 0
            @test sum(proj[i] * matrix[:, i] for i in 1:size(matrix, 2)) ≈
                vector
        end

        @testset ">> Project a vector on a non-orthogonal basis" begin
            vector = [1, 2]
            matrix = [1 0; 1 1]
            proj, res = project_on_basis(vector, matrix; itermax=30)
            @test_approx_eq_eps res 0 1e-12
            @test sum(proj[i] * matrix[:, i] for i in 1:size(matrix, 2)) ≈
                vector
        end
    end
end
