using StatsDiscretizations
using Test
using LinearAlgebra
using Random

Random.seed!(1)
Zs = rand(1000)

discr = StatsDiscretizations.samplehull_discretizer(Zs)

# these tests are actually applicable more broadly
#@test findfirst(discr, -100) == 1
@test discr[findfirst.(Ref(discr), Zs)] == discr.(Zs)


#
f = DiscretizedFunction(discr, mean)

#@test f(discr[1]) == -Inf
#@test f(-100) == -Inf
#@test f.(Zs) == mean.(discr.(Zs))
