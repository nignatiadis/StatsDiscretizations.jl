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

using JuMP
using ECOS

using SplitApplyCombine

model = Model(ECOS.Optimizer)

f = StatsDiscretizations.add_discretized_function!(model, discr)

@objective(model, Min, sum(  (f.(Zs) .-  Zs  ).^2 ))


optimize!(model)

fsolve = JuMP.value(f)


_output_dict = groupsum( z->discr(z), sort(Zs)) ./ groupcount( z->discr(z), sort(Zs))

@test maximum(abs.(collect(_output_dict .- fsolve.dictionary))) ≈ 0.0 atol=1e-5
