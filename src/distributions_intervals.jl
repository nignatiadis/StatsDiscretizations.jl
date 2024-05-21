# Methods for extending Distributions.jl interface to Intervals

pdf(dbn, x) = Distributions.pdf(dbn, x)
logpdf(dbn, x) = Distributions.logpdf(dbn, x)
cdf(dbn, x) = Distributions.cdf(dbn, x)
logcdf(dbn, x) = Distributions.logcdf(dbn, x)


function pdf(dbn::Distributions.Distribution, interval::Interval)
    exp(logpdf(dbn, interval))
end

# For ContinuousUnivariateDistribution

function cdf(dbn::Distributions.ContinuousUnivariateDistribution, interval::Interval)
    Distributions.cdf(dbn, rightendpoint(interval))
end

function logcdf(
    dbn::Distributions.ContinuousUnivariateDistribution,
    interval::Interval,
)
    Distributions.logcdf(dbn, rightendpoint(interval))
end

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
