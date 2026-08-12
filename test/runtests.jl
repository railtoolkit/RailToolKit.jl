# Use-case test orchestration: catalogue gates + each active UC-*/test.jl.

using Test

include(joinpath(@__DIR__, "catalogue.jl"))

@testset "use cases" begin
    @testset "catalogue" begin
        current, checks = validate_all_usecases()
        @test current ≥ 1
        for check in checks
            @test ok(check)
        end
    end

    tests = active_usecase_test_files()
    @test !isempty(tests)
    for test_jl in tests
        case = basename(dirname(test_jl))
        @testset "$case" begin
            include(test_jl)
        end
    end
end
