using StatsDiscretizations
using Documenter

DocMeta.setdocmeta!(StatsDiscretizations, :DocTestSetup, :(using StatsDiscretizations); recursive=true)

makedocs(;
    modules=[StatsDiscretizations],
    authors="Nikos Ignatiadis <nikos.ignatiadis01@gmail.com> and contributors",
    repo="https://github.com/nignatiadis/StatsDiscretizations.jl/blob/{commit}{path}#{line}",
    sitename="StatsDiscretizations.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://nignatiadis.github.io/StatsDiscretizations.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/nignatiadis/StatsDiscretizations.jl",
)
