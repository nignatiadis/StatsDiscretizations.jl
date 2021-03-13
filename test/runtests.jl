using StatsDiscretizations
using Test
using Infinity
using Infinity.Utils

@testset "Distributions Intervals" begin
    include("test_distributions_intervals.jl")
end

@testset "Discretizers" begin
    include("test_discretizers.jl")
end

@testset "Discretized Functions" begin
    include("test_discretized_functions.jl")
end
