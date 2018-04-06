using TKPappKitchenSink
using Base.Test
using StaticArrays

@testset "similar basis vector" begin
    @test similar_basis_vector(randn(3), 1) == [1.0, 0.0, 0.0]
    @test similar_basis_vector(randn(3), 2) == [0.0, 1.0, 0.0]
    @test similar_basis_vector(SVector(1.0, 2.0), 1) ≡ SVector(1.0, 0.0)
    @test similar_basis_vector(SVector(1.0, 2.0), 2) ≡ SVector(0.0, 1.0)
end

@testset "function slice" begin
    f(x) = sum(abs2, x)
    x = randn(3)
    @test function_slice(f, x, 1)(0.3) == f(x + 0.3*[1.0, 0.0, 0.0])
end
