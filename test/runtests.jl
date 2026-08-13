# Use-case test orchestration: catalogue gates + each active UC-*/test.jl.

using Test

include(joinpath(@__DIR__, "catalogue.jl"))

@testset "use cases" begin
    @testset "catalogue" begin
        current, checks = validate_all_usecases()
        @test current ≥ 1
        for check in checks
            @test ok(check)
            for warning in check.warnings
                @info "$(check.case): $warning"
            end
        end
    end

    # Active cases are optional while the catalogue is empty (WIP / no UC-* on the branch).
    for test_jl in active_usecase_test_files()
        case = basename(dirname(test_jl))
        @testset "$case" begin
            include(test_jl)
        end
    end
end
