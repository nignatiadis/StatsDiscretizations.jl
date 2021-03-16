using StatsDiscretizations
using Test
using LinearAlgebra
using Infinity
using Infinity.Utils
using SplitApplyCombine

@testset "Distributions Intervals" begin
    include("test_distributions_intervals.jl")
end

@testset "Discretizers" begin
    include("test_discretizers.jl")
end

@testset "Discretized Functions" begin
    include("test_discretized_functions.jl")
end
