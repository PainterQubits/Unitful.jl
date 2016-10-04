using Unitful
using BenchmarkTools
using DataFrames

function benchmark!(suite::BenchmarkGroup, expression::Expr)
    @assert expression.head == :call
    op = expression.args[1]
    a = eval(expression.args[2])
    b = eval(expression.args[3])
    if op ∉ keys(suite)
      suite[op] = BenchmarkGroup()
    end
    name = "$a $op $b"
    if name ∉ keys(suite[op])
        suite[op][name] = BenchmarkGroup([op])
    end
    suite[op][name][:units] = @benchmarkable $op($a, $b)
    suite[op][name][:nounits] =
        @benchmarkable $op($(ustrip(a)), $(ustrip(b)))
    suite
end
benchmark(expression::Expr) =
    benchmark!(BenchmarkGroup(["Unitful"]), expression)

function performance_summary(suite)
    tune!(suite)
    benchs = run(suite)
    result = DataFrame(op=Symbol[], expression=String[],
                       ratio=Float64[], time=Any[], memory=Any[])
    for op in keys(benchs)
        for expression in keys(benchs[op])
            units = median(benchs[op][expression][:units])
            nounits = median(benchs[op][expression][:nounits])
            rt = ratio(units, nounits).time
            judgment = judge(units, nounits)
            push!(
                result,
                [op, expression, rt, judgment.time, judgment.memory]
            )
        end
    end
    result
end

function benchmark()
    suite = BenchmarkGroup(["Unitful"])
    for a in (2u"m", 2.1u"m"), b in (3u"kg", 3.5u"kg"), op in (:*, :/)
      benchmark!(suite, :($op($a, $b)))
    end
    # for a in (2u"m", 1//2u"m"), b in (1//3u"kg"), op in (:*, :+, :-, ://)
    #     benchmark!(suite, :($op($a, $b)))
    # end
    performance_summary(suite)
end

