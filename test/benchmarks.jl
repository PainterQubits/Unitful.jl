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
    bench_units = @benchmarkable $units
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
    as, ops, bs = (2u"m", 2.1u"m"), (:*, :/), (3u"kg", 3.5u"kg", 2u"m^-1")
    # @testset "$a $op $b" for a = as, b = bs, op = ops
    #     @test test_benchmark(:($op($a, $b)))
    # end

    @testset "dimensionless to unitless" begin
        @test test_benchmark(:(1u"m" / 2u"m"))
        @test test_benchmark(:(1u"m" * 2u"m^-1"))
    end
end
