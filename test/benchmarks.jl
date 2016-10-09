using Unitful
using BenchmarkTools
using Base.Test
using DataFrames

function benchmark()
    suite = BenchmarkGroup(["Unitful"])
    bterms = (3u"kg", 3.5u"kg", 2u"m^-1")
    for a in (2u"m", 2.1u"m"), b in bterms, op in (:*, :/)
        benchmark!(suite, :($op($a, $b)))
    end
    for a in (2u"m", 2.1u"m"), b in (3u"m", 3.5u"m"), op in (:+, :-)
        benchmark!(suite, :($op($a, $b)))
    end

    performance_summary(suite)
end

function judge_unit_benchmark(units::Expr, nounits::Expr; kwargs...)
    op = units.args[1]
    a = eval(units.args[2])
    b = eval(units.args[3])
    bench_units = @benchmarkable $op($a, $b)
    bench_nounits = @benchmarkable $nounits
    tune!(bench_units)
    tune!(bench_nounits)
    judge(
        median(run(bench_units; kwargs...)),
        median(run(bench_nounits; kwargs...))
    )
end

function judge_unit_benchmark(units::Expr; kwargs...)
    op = units.args[1]
    a = ustrip(eval(units.args[2]))
    b = ustrip(eval(units.args[3]))
    judge_unit_benchmark(units, :($op($a, $b)); kwargs...)
end

function test_benchmark(unit::Expr...; kwargs...)
    j = judge_unit_benchmark(unit...; kwargs...)
    j.time == :invariant && j.memory == :invariant
end

@testset "Benchmarks" begin
    as, ops, bs = (2u"m", 2.1u"m"), (:*, :/), (3u"kg", 3.5u"kg")
    @testset "$a $op $b" for a = as, b = bs, op = ops
        @test test_benchmark(:($op($a, $b)), time_tolerance=0.01)
    end

    @testset "unit to unitless" begin
        @test test_benchmark(:((1u"m") / (2u"m")), time_tolerance=0.01)
        @test test_benchmark(:(1u"m" * 2u"m^-1"), time_tolerance=0.01)
        @test test_benchmark(:(1u"m" / 2u"km"), time_tolerance=0.01)
    end


    a  = 1//2 * u"m"
    bs = (1u"kg", 2//3 * u"kg")
    @testset "rational numbers: $a $op $b" for b = bs, op in (://, :*)
        @test_broken test_benchmark(:($op($a, $b)))
    end

    @testset "summations" begin
        @test test_benchmark(:(1u"m" + 2u"m"), time_tolerance=0.01)
        @test_broken test_benchmark(:(1u"km" + 2u"m"), time_tolerance=0.01)
    end

    @testset "Arrays" begin
        as, ops, bs = ([2, 1]u"m", [2.1, 3.1]u"m"), (:.*, :./, :.+, :.-),
                      (3u"kg", [3, 2]u"kg")
        @testset "$a $op $b" for a=as, b=bs, op=ops
            @test_broken test_benchmark(:($op($a, $b)), time_tolerance=0.01)
        end
    end
end
