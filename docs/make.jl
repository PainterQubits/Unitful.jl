using Documenter, Unitful

makedocs()

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo   = "github.com/ajkeller34/Unitful.jl.git",
)
