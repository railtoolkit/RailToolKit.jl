# Paths and constants for catalogue page generation.

const REPO_EDIT_BASE = "https://github.com/railtoolkit/RailToolKit.jl/edit/main"
const HARNESS_PROJECT_PATH = normpath(joinpath(@__DIR__, "..", "..", "Project.toml"))
const GENERATED_PACKAGES_TOML = "generated/packages.toml"
const USECASES_IO = normpath(joinpath(@__DIR__, "..", "..", "src", "usecases_io.jl"))
