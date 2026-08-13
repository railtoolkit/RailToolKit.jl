# Build generated markdown under docs/src/generated/ from the use-case catalogue.

include("config.jl")
include(USECASES_IO)
include("links.jl")
include("usecases.jl")
include("packages.jl")

"""
    generate_docs_pages!(src_dir) -> NamedTuple

Regenerate `docs/src/generated/` from the use-case catalogue and return sidebar metadata.
"""
function generate_docs_pages!(src_dir::AbstractString)
    generated_dir = joinpath(src_dir, "generated")
    usecases_dir = joinpath(generated_dir, "usecases")
    rm(generated_dir; recursive=true, force=true)
    mkpath(usecases_dir)

    dirs = usecase_directories()
    records = UseCaseRecord[load_usecase_record(dir) for dir in dirs]

    write_usecase_pages!(src_dir, records)
    surfaces = build_package_surfaces!(records, src_dir)
    write(joinpath(generated_dir, "catalogue_table.md"), render_catalogue_table(records))
    write(joinpath(generated_dir, "packages.md"), render_packages_index(surfaces))

    usecase_pages = usecase_sidebar_pages(records)
    return (
        usecase_pages=usecase_pages,
        package_pages=package_sidebar_pages(surfaces),
        records=records,
        package_surfaces=surfaces,
    )
end
