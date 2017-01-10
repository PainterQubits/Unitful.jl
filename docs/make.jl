using Documenter, Unitful

makedocs()

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    julia  = "nightly",
    os     = "linux",
    repo   = "github.com/ajkeller34/Unitful.jl.git"
)
