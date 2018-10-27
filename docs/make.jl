using Documenter, Unitful

makedocs()

deploydocs(
    deps   = Deps.pip("Tornado>=4.0.0,<5.0.0", "mkdocs==0.17.5", "mkdocs-material==2.9.4", "python-markdown-math"),
    julia  = "1.0",
    osname = "linux",
    repo   = "github.com/ajkeller34/Unitful.jl.git"
)
