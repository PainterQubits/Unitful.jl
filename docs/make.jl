using Documenter, Unitful

makedocs()

deploydocs(
    deps   = Deps.pip("mkdocs", "mkdocs-material", "python-markdown-math"),
    julia  = "nightly",
    osname = "linux",
    repo   = "github.com/ajkeller34/Unitful.jl.git"
)
