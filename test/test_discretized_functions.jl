using StatsDiscretizations
using JuMP
using Test
using LinearAlgebra
using Random
using StatsBase

Random.seed!(1)
Zs = rand(1000)

_min,_max = extrema(Zs)
discr = BoundedIntervalDiscretizer{:open,:closed}((_min - 0.01):0.01:(_max + 0.01))

# these tests are actually applicable more broadly
#@test findfirst(discr, -100) == 1
@test discr[findfirst.(Ref(discr), Zs)] == discr.(Zs)


#
f = dictfun(discr, mean)

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

@test maximum(abs.(collect(_output_dict .- fsolve.dictionary))) ≈ 0.0 atol=1e-4