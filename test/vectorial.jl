using Base.Test
using Unitful: dimensional_space, Dimensions, Dimension, dimensional_matrix,
    two_by_two_independant, independant_columns, project_on_basis, @u_str,
    simplify, dimensional_vector, SI

@testset "Type simplification - implementation" begin
    @testset "> Count dimensions in a unit" begin
        @test length(dimensional_space(u"m/m")) == 0
        @test dimensional_space(u"m/km") == [Dimension{:Length}(1//1)]
        @test dimensional_space(u"m/s") ==
            [Dimension{:Length}(1//1), Dimension{:Time}(1//1)]
        @test dimensional_space(u"m/s*J") ==
            [
                Dimension{:Length}(1//1),
                Dimension{:Mass}(1//1),
                Dimension{:Time}(1//1)
            ]

        @test dimensional_space(u"m", u"km") == [Dimension{:Length}(1//1)]
        @test dimensional_space(u"m", u"km/km") == [Dimension{:Length}(1//1)]
        @test dimensional_space(u"m", u"m/s") ==
            [Dimension{:Length}(1//1), Dimension{:Time}(1//1)]
    end

    @testset "> Transform unit to vector format" begin
		dspace = [
			Unitful.Dimension{:Length}(1//1), Unitful.Dimension{:Mass}(1//1),
			Unitful.Dimension{:Time}(1//1), Unitful.Dimension{:yolo}(1)
        ]
    	@test dimensional_vector(typeof(u"m*J").parameters[1][1], dspace) ==
				[2//1, 1//1, -2//1, 0//1]
		@test dimensional_vector(typeof(u"m*J"), dspace) ==
				[3//1, 1//1, -2//1, 0//1]
    end

    @testset "> Transform units to matrix format" begin
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

@testset "Type simplification - usage" begin
	@testset "> No preferred units" begin
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

	@testset "With preferred units" begin
		@test simplify(u"cm", Unitful.Units[u"cm"]) === u"cm"
		@test simplify(u"cm", Unitful.Units[u"m"]) === u"m"
		@test simplify(u"cm", Unitful.Units[u"m", u"km"]) === u"m"
		@test simplify(u"cm", Unitful.Units[u"m^-1"]) === u"m"
		@test simplify(u"s", Unitful.Units[u"Hz"]) === u"Hz^-1"
		@test simplify(u"s", Unitful.Units[u"m"]) === u"s"
		@test simplify(u"J", Unitful.Units[u"Hz"]) === u"J"
		@test simplify(u"J", Unitful.Units[u"Hz", u"J"]) === u"J"
		@test simplify(u"J", Unitful.Units[u"Hz", u"nm", u"kg"]) ===
			u"kg*Hz^2*nm^2"

        # missing u"s", so u"J" is the only one that matches
		@test simplify(u"J", Unitful.Units[u"Hz", u"nm", u"J"]) === u"J"
		# J gets eliminated when creating basis for input unit, since it is not
        # linearly independent from the others.
		# Actually, the input unit is always added at the end of the preferred
        # units, so adding it again explicitly is unnecessary.
		@test simplify(u"J", Unitful.Units[u"Hz", u"nm", u"kg", u"J"]) ===
			u"kg*Hz^2*nm^2"
		# Here, however u"J" comes first, so some other unit gets squashed when
        # creating the basis of units.
		@test simplify(u"J", Unitful.Units[u"J", u"Hz", u"nm", u"kg"]) === u"J"
		@test simplify(u"J", Unitful.Units[u"Hz", u"J", u"nm", u"kg"]) === u"J"

        @test simplify(u"J", Unitful.Units[u"N", u"m"]) === u"m * N"
		@test simplify(u"J*N", Unitful.Units[u"N", u"m"]) === u"m * N^2"

		@test simplify(1u"J*N", Unitful.Units[u"N", u"m"]) == 1u"m * N^2"
		@test simplify(1u"J*N", Unitful.Units[u"N", u"cm"]) == 100u"cm * N^2"
		@test simplify(1u"J*N", (u"N", u"cm")) == 100u"cm * N^2"
		@test simplify(u"J*N", SI) === u"kg^2*m^3*s^-4"
		@test simplify(1u"J*N", SI) == 1u"J*N"
    end
end
