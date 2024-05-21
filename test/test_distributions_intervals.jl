using StatsDiscretizations
using Test
using Distributions
using IntervalSets


for (l,r) in [(:open,:closed), (:closed,:open), (:open,:open), (:closed,:closed)]
    @test StatsDiscretizations.pdf(Normal(), IntervalSets.Interval{l,r}(0.0, Inf)) == 0.5
    @test StatsDiscretizations.pdf(Normal(), IntervalSets.Interval{l,r}(-Inf, Inf)) == 1.0
    @test StatsDiscretizations.pdf(Normal(), IntervalSets.Interval{l,r}(-Inf, Inf)) == 1.0    
end


@test StatsDiscretizations.logcdf(Poisson(2), Interval{:closed,:closed}(0, 1)) == log(Distributions.pdf(Poisson(2),0) + Distributions.pdf(Poisson(2),1))
@test StatsDiscretizations.logcdf(Poisson(2), Interval{:closed,:closed}(0, 0)) == log(Distributions.pdf(Poisson(2),0))
@test StatsDiscretizations.logcdf(Poisson(2), Interval{:closed,:closed}(-1, 0)) == log(Distributions.pdf(Poisson(2),0))
@test StatsDiscretizations.logcdf(Poisson(2), Interval{:closed,:open}(0, 1)) == log(Distributions.pdf(Poisson(2),0))

@test logdiffcdf(Poisson(2), 1, 0) == logpdf(Poisson(2), 1)

d = Binomial(11, 0.3)
@test StatsDiscretizations.pdf(d, Interval{:open, :closed}(3,4)) ≈  Distributions.pdf(d, 4)
@test StatsDiscretizations.pdf(d, Interval{:closed, :closed}(3,4)) ≈  Distributions.pdf(d, 4) +  Distributions.pdf(d, 3)
@test StatsDiscretizations.pdf(d, Interval{:open, :closed}(3, Inf)) ≈  Distributions.ccdf(d, 3)
@test StatsDiscretizations.pdf(d, Interval{:closed, :closed}(3, Inf)) ≈  Distributions.ccdf(d, 2)


@test StatsDiscretizations.cdf(Binomial(10, 0.5), 1) ≈ StatsDiscretizations.pdf(Binomial(10, 0.5), Interval(0,1))

@test StatsDiscretizations.logcdf(Dirac(2.0), Interval(-Inf, 1.0)) == -Inf