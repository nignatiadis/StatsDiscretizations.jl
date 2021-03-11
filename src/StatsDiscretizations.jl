module StatsDiscretizations

using Reexport

using Dictionaries
using Discretizers

@reexport using Distributions
import Distributions: pdf, logpdf, cdf, ccdf

using Infinity
using Infinity.Utils

@reexport using IntervalSets
@reexport using StatsBase

include("intervals.jl")
include("distributions_intervals.jl")
include("discretizers.jl")

export RealLineDiscretizer,
       BoundedIntervalDiscretizer

end
