struct DiscretizedFunctionVariable{S<:AbstractRealLineDiscretizer,V,M}
    discretizer::S
    finite_param::V
    model::M
end


function add_discretized_function!(model, discretizer)
    n = length(discretizer)
    tmp_vars = @variable(model, [i = 1:n])
    DiscretizedFunctionVariable(convexclass, tmp_vars, model)
end

#function (f::DiscretizedFunctionVariable)(z)
# @expression(f, z) etc
#end
