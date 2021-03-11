# Methods for extending Distributions.jl interface to InfExtendedReal and Intervals

_pdf(dbn, x) = pdf(dbn, x)
_logpdf(dbn, x) = logpdf(dbn, x)
_cdf(dbn, x) = cdf(dbn, x)
_ccdf(dbn, x) = ccdf(dbn, x)

# Extend to InfExtendedReal

function _pdf(dbn, x::InfExtendedReal)
    isinf(x) ? 0.0 : pdf(dbn, x.val)
end
function _logpdf(dbn, x::InfExtendedReal)
    isinf(x) ? -Inf : logpdf(dbn, x.val)
end
function _cdf(dbn, x::InfExtendedReal)
    isposinf(x) ? 1.0 : isneginf(x) ? 0.0 : cdf(dbn, x.val)
end
function _ccdf(dbn, x::InfExtendedReal)
    isneginf(x) ? 1.0 : isposinf(x) ? 0.0 : ccdf(dbn, x.val)
end


function cdf(dbn, int::Union{<:ClosedClosed, <:OpenClosed})
    _cdf(dbn, rightendpoint(int))
end
function cdf(dbn::ContinuousUnivariateDistribution, int::Union{<:ClosedOpen, <:OpenOpen})
    _cdf(dbn, rightendpoint(int))
end
function cdf(dbn::DiscreteDistribution, int::Union{<:ClosedOpen, <:OpenOpen})
    b = rightendpoint(int)
    _cdf(dbn, b) - _pdf(dbn, b)
end



function pdf(dbn, int::OpenClosed)
    a, b = endpoints(int)
    isposinf(b) ? _ccdf(dbn, a) : isneginf(a) ? _cdf(dbn, b) : _cdf(dbn, b) - _cdf(dbn, a)
end

function pdf(dbn::ContinuousUnivariateDistribution, int::AbstractInterval)
    a, b = endpoints(int)
    pdf(dbn, Interval{:open,:closed}(a,b))
end

function pdf(dbn::DiscreteDistribution, int::OpenOpen)
    a, b = endpoints(int)
    pdf(dbn, Interval{:open,:closed}(a,b)) - _pdf(dbn, b)
end

function pdf(dbn::DiscreteDistribution, int::ClosedOpen)
    a, b = endpoints(int)
    pdf(dbn, Interval{:open,:closed}(a,b)) - _pdf(dbn, b) + _pdf(dbn, a)
end



#logcdf, logccdf, logdiffcdf
