using Documenter, Unitful

makedocs(
    sitename = "Unitful.jl",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
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
        "Extending Unitful" => "extending.md"
        "Troubleshooting" => "trouble.md"
        "License" => "LICENSE.md"
    ]
)

deploydocs(repo = "github.com/PainterQubits/Unitful.jl.git")
