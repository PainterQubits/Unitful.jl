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
    benchs = run(suite)
    result = DataFrame(op=Symbol[], expression=String[], performance=Float64[])
    for op in keys(benchs)
        for expression in keys(benchs[op])
            units = benchs[op][expression][:units]
            nounits = benchs[op][expression][:nounits]
            push!(
                result,
                [op, expression, ratio(median(units), median(nounits)).time]
            )
        end
    end
    result
end
