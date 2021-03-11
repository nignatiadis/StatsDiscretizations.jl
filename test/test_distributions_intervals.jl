using StatsDiscretizations
using Test
using Infinity

@test cdf(Binomial(5,0.5), Interval{:open,:closed}(0, ∞)) == 1.0
@test cdf(Binomial(5,0.7), Interval{:open,:closed}(-∞,0)) ≈ pdf(Binomial(5,0.7), 0)
