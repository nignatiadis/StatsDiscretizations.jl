module JuMPExt

using JuMP, StatsDiscretizations, Dictionaries

struct DiscretizedFunctionVariable{S<:AbstractRealLineDiscretizer,V,M}
    discretizer::S
    finite_param::V
    model::M
end

function Base.show(io::IO,  discvar::DiscretizedFunctionVariable)
    println(io, "DiscretizedFunctionVariable with JuMP param:")
    Base.show(io, discvar.finite_param)
end

function StatsDiscretizations.add_discretized_function!(model, discretizer)
    n = length(discretizer)
    tmp_vars = @variable(model, [i = 1:n])
    DiscretizedFunctionVariable(discretizer, tmp_vars, model)
end

function (f::DiscretizedFunctionVariable)(z)
    idx = findfirst(f.discretizer, z)
    f.finite_param[idx]
end

function JuMP.value(f::DiscretizedFunctionVariable)
    dictfun(f.discretizer, JuMP.value.(f.finite_param))
end


function JuMP.value(f::DiscretizedFunctionVariable, flift)
    dictfun(f.discretizer, JuMP.value.(f.finite_param), flift)
end



end
