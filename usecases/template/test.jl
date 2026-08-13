# UC-NNN: <short title>
#
# Invoked from the harness via `test/runtests.jl` → `Pkg.test()` when status: active,
# or standalone:
#   julia --project=. -e 'include("usecases/UC-NNN-short-name/test.jl")'
#
# Draft: leave this stub (or smoke-only). Active: regression constants + OUT-n / TEST-n.
# CI only includes this file when usecase.md has status: active.

using Test
# using RailToolKit  # uncomment when binding

const ASSETS = joinpath(@__DIR__, "assets")

@testset "UC-NNN short-name" begin
    @test isdir(ASSETS)
    # TODO: load assets, run the documented workflow, assert OUT-n (see usecase.md Verification)
end
