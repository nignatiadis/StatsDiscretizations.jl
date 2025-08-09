# Methods for extending Distributions.jl interface to Intervals

pdf(dbn, x) = Distributions.pdf(dbn, x)
logpdf(dbn, x) = Distributions.logpdf(dbn, x)
cdf(dbn, x) = Distributions.cdf(dbn, x)
logcdf(dbn, x) = Distributions.logcdf(dbn, x)


"""
    pdf(distribution, interval::Interval)

Compute the probability that a random variable from `distribution` falls within the given `interval`.

For **continuous distributions**, this returns P(X ∈ interval) = ∫_{interval} pdf(x) dx.

For **discrete distributions**, this returns the sum of probability masses for all 
integer points contained within the interval, respecting the boundary conditions 
(open vs closed endpoints).

The interval boundary behavior follows these rules:
- `Interval{:closed,:closed}(a,b)`: includes both endpoints [a,b]  
- `Interval{:open,:closed}(a,b)`: excludes left endpoint (a,b]
- `Interval{:closed,:open}(a,b)`: excludes right endpoint [a,b)
- `Interval{:open,:open}(a,b)`: excludes both endpoints (a,b)

# Examples
```julia
using Distributions, IntervalSets

# Continuous distribution: probability over interval
d = Normal(0, 1)
pdf(d, Interval(-1.0, 1.0))  # ≈ 0.683 (68% of standard normal)

# Discrete distribution: sum of point masses
d = Poisson(2.0) 
pdf(d, Interval{:closed,:closed}(1, 3))  # P(X=1) + P(X=2) + P(X=3)
pdf(d, Interval{:open,:closed}(1, 3))    # P(X=2) + P(X=3)
```

See also: [`logpdf`](@ref), [`cdf`](@ref)
"""
function pdf(dbn::Distributions.Distribution, interval::Interval)
    exp(logpdf(dbn, interval))
end

# For ContinuousUnivariateDistribution

"""
    cdf(distribution, interval::Interval)

Compute the cumulative probability up to and including the right boundary of the `interval`.

For both discrete and continuous distributions, this returns:
- If right-closed: P(X ≤ rightendpoint(interval))
- If right-open: P(X < rightendpoint(interval))

The left endpoint and left boundary conditions do not affect the result, as this 
function computes cumulative probability from -∞ up to the right boundary.

This is particularly useful for goodness-of-fit testing with discretized data. When 
data is binned into intervals, the empirical CDF at each interval represents the 
proportion of observations with values ≤ rightendpoint (or < rightendpoint if right-open).
This function provides the theoretical probability for comparison.

# Examples
```julia
using Distributions

# Continuous distribution
d = Normal(0, 1)
cdf(d, Interval{:open,:closed}(-1.0, 0.0))    # P(X ≤ 0) = 0.5
cdf(d, Interval{:closed,:open}(-1.0, 0.0))    # P(X < 0) = 0.5 (same for continuous)

# Discrete distribution  
d = Poisson(2.0)
cdf(d, Interval{:open,:closed}(0, 2))         # P(X ≤ 2)
cdf(d, Interval{:open,:open}(0, 2))           # P(X < 2) = P(X ≤ 1)
```

See also: [`logcdf`](@ref), [`pdf`](@ref)
"""
function cdf(dbn::Distributions.ContinuousUnivariateDistribution, interval::Interval)
    Distributions.cdf(dbn, rightendpoint(interval))
end

"""
    logcdf(distribution, interval::Interval)

Compute the logarithm of the cumulative probability up to and including the right boundary of the `interval`.

This returns log(P(X ≤ rightendpoint)) for right-closed intervals or log(P(X < rightendpoint)) 
for right-open intervals. Provides better numerical stability for very small probabilities.

# Examples
```julia
d = Normal(0, 1) 
logcdf(d, Interval(-10.0, -5.0))  # log(P(X ≤ -5)) (numerically stable)
```

See also: [`cdf`](@ref), [`logpdf`](@ref)
"""
function logcdf(
    dbn::Distributions.ContinuousUnivariateDistribution,
    interval::Interval,
)
    Distributions.logcdf(dbn, rightendpoint(interval))
end


"""
    logpdf(distribution, interval::Interval)

Compute the logarithm of the probability that a random variable from `distribution` falls within the given `interval`.

This returns log(P(X ∈ interval)) and provides better numerical stability than 
computing `log(pdf(distribution, interval))` directly, especially for very small probabilities.

For **continuous distributions**, this uses `logdiffcdf` for numerical accuracy.
For **discrete distributions**, this carefully handles boundary conditions using 
log-space arithmetic to avoid numerical underflow.

# Examples
```julia
using Distributions, IntervalSets

# Continuous distribution
d = Normal(0, 1)
logpdf(d, Interval(-3.0, 3.0))  # log(P(-3 < X < 3)) ≈ log(0.997)

# Discrete distribution  
d = Poisson(10.0)
logpdf(d, Interval{:closed,:closed}(8, 12))  # log(P(8 ≤ X ≤ 12))
```

See also: [`pdf`](@ref), [`logcdf`](@ref)
"""
function logpdf(
    dbn::Distributions.ContinuousUnivariateDistribution,
    interval::Interval,
)
    Distributions.logdiffcdf(dbn, rightendpoint(interval), leftendpoint(interval))
end


# For DiscreteUnivariateDistribution

function logcdf(dbn::Distributions.DiscreteDistribution, interval::Interval)
    b = rightendpoint(interval)
    logcdf_b = Distributions.logcdf(dbn, b)
    isrightclosed(interval) ? logcdf_b : logsubexp(logcdf_b, Distributions.logpdf(dbn, b))
end

function cdf(dbn::Distributions.DiscreteDistribution, interval::Interval)
    exp(StatsDiscretizations.logcdf(dbn, interval))
end

function logpdf(dbn::Distributions.DiscreteDistribution, interval::Interval)
    a = leftendpoint(interval)
    b = rightendpoint(interval)

    right_logcdf = Distributions.logcdf(dbn, b) 
    
    if isinf(right_logcdf) && (right_logcdf .< 0.0)
        return Float64(-Inf)
    end

    logdiffcdf_a_b = Distributions.logdiffcdf(dbn, b, a)

    # substract mass of right endpoint if interval is right open
    logdiffcdf_a_b =
        isrightclosed(interval) ? logdiffcdf_a_b :
        logsubexp(logdiffcdf_a_b, Distributions.logpdf(dbn, b))

    # add mass of left endpoint if interval is left closed
    logdiffcdf_a_b =
        isleftclosed(interval) ? logaddexp(logdiffcdf_a_b, Distributions.logpdf(dbn, a)) :
        logdiffcdf_a_b

    logdiffcdf_a_b
end
