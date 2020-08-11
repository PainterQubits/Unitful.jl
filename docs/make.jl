using Documenter, Unitfu

DocMeta.setdocmeta!(Unitfu, :DocTestSetup, :(using Unitfu))

makedocs(
    sitename = "Unitfu.jl",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [Unitfu],
    workdir = joinpath(@__DIR__, ".."),
    pages = [
        "Home" => "index.md"
        "Highlighted features" => "highlights.md"
        "Types" => "types.md"
        "Defining new units" => "newunits.md"
        "Conversion/promotion" => "conversion.md"
        "Manipulating units" => "manipulations.md"
        "How units are displayed" => "display.md"
        "Logarithmic scales" => "logarithm.md"
        "Temperature scales" => "temperature.md"
        "Extending Unitfu" => "extending.md"
        "Troubleshooting" => "trouble.md"
        "License" => "LICENSE.md"
    ]
)

deploydocs(repo = "github.com/hustf/Unitfu.jl.git")
