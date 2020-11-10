using Documenter
using UnitfulEquivalences

DocMeta.setdocmeta!(UnitfulEquivalences, :DocTestSetup, :(using Unitful, UnitfulEquivalences))

makedocs(
    sitename = "UnitfulEquivalences.jl",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [UnitfulEquivalences],
    pages = [
             "Home" => "index.md",
            ]
)

deploydocs(
    repo = "github.com/sostock/UnitfulEquivalences.jl.git"
)
