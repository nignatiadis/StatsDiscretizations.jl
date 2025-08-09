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

# Test examples from docstrings
@testset "Docstring Examples" begin
    # PDF examples - continuous distribution
    d = Normal(0, 1)
    prob = StatsDiscretizations.pdf(d, Interval(-1.0, 1.0))
    @test prob ≈ 0.6826894921370859 atol=1e-10  # 68% of standard normal
    
    # PDF examples - discrete distribution
    d = Poisson(2.0)
    # P(X=1) + P(X=2) + P(X=3) for Poisson(2)
    expected_closed = Distributions.pdf(d, 1) + Distributions.pdf(d, 2) + Distributions.pdf(d, 3)
    @test StatsDiscretizations.pdf(d, Interval{:closed,:closed}(1, 3)) ≈ expected_closed
    
    # P(X=2) + P(X=3) for Poisson(2) 
    expected_open = Distributions.pdf(d, 2) + Distributions.pdf(d, 3)
    @test StatsDiscretizations.pdf(d, Interval{:open,:closed}(1, 3)) ≈ expected_open
    
    # CDF examples - continuous distribution
    d = Normal(0, 1)
    @test StatsDiscretizations.cdf(d, Interval{:open,:closed}(-1.0, 0.0)) ≈ 0.5
    @test StatsDiscretizations.cdf(d, Interval{:closed,:open}(-1.0, 0.0)) ≈ 0.5  # same for continuous
    
    # CDF examples - discrete distribution
    d = Poisson(2.0)
    @test StatsDiscretizations.cdf(d, Interval{:open,:closed}(0, 2)) ≈ Distributions.cdf(d, 2)
    @test StatsDiscretizations.cdf(d, Interval{:open,:open}(0, 2)) ≈ Distributions.cdf(d, 1)  # P(X < 2) = P(X ≤ 1)
    
    # LOGPDF examples - continuous distribution
    d = Normal(0, 1)
    expected_prob = Distributions.cdf(d, 3.0) - Distributions.cdf(d, -3.0)
    @test StatsDiscretizations.logpdf(d, Interval(-3.0, 3.0)) ≈ log(expected_prob)
    
    # LOGPDF examples - discrete distribution
    d = Poisson(10.0)
    expected_prob = sum(Distributions.pdf(d, x) for x in 8:12)
    @test StatsDiscretizations.logpdf(d, Interval{:closed,:closed}(8, 12)) ≈ log(expected_prob)
end

# Comprehensive boundary condition tests
@testset "All Boundary Conditions" begin
    # Test all 4 combinations of boundary conditions
    boundary_types = [(:open,:closed), (:closed,:open), (:open,:open), (:closed,:closed)]
    
    @testset "Continuous - $L,$R boundaries" for (L,R) in boundary_types
        d = Normal(0, 1)
        interval = Interval{L,R}(-1.0, 1.0)
        
        # For continuous distributions, CDF should only depend on right endpoint
        expected_cdf = R == :closed ? Distributions.cdf(d, 1.0) : Distributions.cdf(d, 1.0)
        @test StatsDiscretizations.cdf(d, interval) ≈ expected_cdf
        @test StatsDiscretizations.logcdf(d, interval) ≈ log(expected_cdf)
        
        # PDF should be the same regardless of boundary conditions for continuous
        @test StatsDiscretizations.pdf(d, interval) ≈ Distributions.cdf(d, 1.0) - Distributions.cdf(d, -1.0)
    end
    
    @testset "Discrete - $L,$R boundaries" for (L,R) in boundary_types  
        d = Poisson(3.0)
        interval = Interval{L,R}(1, 4)
        
        # CDF should depend on right boundary condition
        expected_cdf = R == :closed ? Distributions.cdf(d, 4) : Distributions.cdf(d, 3)
        @test StatsDiscretizations.cdf(d, interval) ≈ expected_cdf
        @test StatsDiscretizations.logcdf(d, interval) ≈ log(expected_cdf)
        
        # PDF should depend on both boundary conditions
        expected_pdf = 0.0
        for x in 1:4
            include_x = (x > 1 || L == :closed) && (x < 4 || R == :closed)
            if include_x
                expected_pdf += Distributions.pdf(d, x)
            end
        end
        @test StatsDiscretizations.pdf(d, interval) ≈ expected_pdf
    end
end