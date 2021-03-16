module StatsDiscretizations

using Reexport

using Dictionaries
using Discretizers

@reexport using Distributions
import Distributions: pdf, logpdf, cdf, ccdf

using Infinity
using Infinity.Utils

@reexport using IntervalSets

using Requires
@reexport using StatsBase

include("intervals.jl")
include("distributions_intervals.jl")
include("discretizers.jl")
include("discretized_function.jl")
include("default_discretizers.jl")

function __init__()
    @require JuMP="4076af6c-e467-56ae-b986-b466b2749572" include("discretized_function_jump.jl")
end


export RealLineDiscretizer,
       BoundedIntervalDiscretizer,
       DiscretizedFunction,
       FiniteSupportDiscretizer

end
