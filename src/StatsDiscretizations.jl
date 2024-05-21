module StatsDiscretizations


using Dictionaries
import Distributions
using IntervalSets
using LogExpFunctions
using StatsBase 


include("distributions_intervals.jl")
include("discretizers.jl")
include("discretized_function.jl")
include("countmap.jl")

#include("default_discretizers.jl")


function add_discretized_function! end

export AbstractRealLineDiscretizer,
        RealLineDiscretizer,
        BoundedIntervalDiscretizer,
        FiniteGridDiscretizer,
        ExtendedFiniteGridDiscretizer,
        dictfun,
        add_discretized_function!

export AbstractInterval, 
        Interval,
        isleftclosed,
        isrightclosed,
        rightendpoint,
        leftendpoint

end
