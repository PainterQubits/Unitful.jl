using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(path=(joinpath(@__DIR__, "../") |> normpath))

using Documenter, Unitful, Dates

const ci = get(ENV, "CI", nothing) == "true"

function check_defaultunits_version()
    vfile = "docs/src/assets/vfile.txt"
    r = readline(vfile)
    docs_v = VersionNumber(r)
    pkg_v = pkgversion(Unitful)
    docs_v == pkg_v || error("Docs chapter on default units built with the wrong version of Unitful \
        (docs built for $docs_v vs current Unitful version $pkg_v). \
        Please run the script on the local computer with the proper Unitful version")
    return nothing
end

# on local computer, (re-)create the documentation file defaultunits.md
if !ci
    ENV["UNITFUL_FANCY_EXPONENTS"] = false
    include("make_def-units_docs.jl")
    MakeDefUnitsDocs.make_chapter()
end

DocMeta.setdocmeta!(Unitful, :DocTestSetup, :(using Unitful))

makedocs(
    sitename = "Unitful.jl",
    format = Documenter.HTML(prettyurls = ci),
    warnonly = [:missing_docs, :doctest],
    modules = [Unitful],
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
        "Interoperability with `Dates`" => "dates.md"
        "Extending Unitful" => "extending.md"
        "Troubleshooting" => "trouble.md"
        "Pre-defined units and constants" => "defaultunits.md"
        "License" => "LICENSE.md"
    ]
)

if ci
    check_defaultunits_version()
    deploydocs(repo = "github.com/PainterQubits/Unitful.jl.git")
end
