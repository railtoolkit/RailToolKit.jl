using Documenter
using RailToolKit

function sync_root_markdown!(root_name::String, docs_name::String)
    src = normpath(joinpath(@__DIR__, "..", root_name))
    dst = joinpath(@__DIR__, "src", docs_name)
    isfile(src) || error("missing $root_name at repo root")
    cp(src, dst; force=true)
end

sync_root_markdown!("CONTRIBUTING.md", "contributing.md")
sync_root_markdown!("CODE_OF_CONDUCT.md", "code_of_conduct.md")

include(joinpath(@__DIR__, "catalogue", "build.jl"))

generated = generate_docs_pages!(joinpath(@__DIR__, "src"))

package_pages = vcat(
    ["Overview" => "generated/packages.md"],
    generated.package_pages,
)

pages = Any[
    "Home" => "index.md",
    "Catalogue" => "generated/catalogue_table.md",
]
if !isempty(generated.usecase_pages)
    push!(pages, "Use cases" => generated.usecase_pages)
end
push!(pages, "Packages" => package_pages)
push!(pages, "Harness API" => "api.md")
push!(pages, "Contributing" => "contributing.md")
push!(pages, "Code of Conduct" => "code_of_conduct.md")

makedocs(
    modules=[RailToolKit],
    sitename="RailToolKit.jl",
    authors="Martin Scheidt and contributors",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", nothing) == "true",
        repolink="https://github.com/railtoolkit/RailToolKit.jl",
    ),
    pagesonly=true,
    checkdocs=:exports,
    pages=pages,
)

deploydocs(
    repo="github.com/railtoolkit/RailToolKit.jl.git",
    devbranch="main",
)
