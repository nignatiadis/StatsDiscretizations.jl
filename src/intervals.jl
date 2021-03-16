const OpenClosed{T} = IntervalSets.TypedEndpointsInterval{:open,:closed, T}
const ClosedOpen{T} = IntervalSets.TypedEndpointsInterval{:closed,:open, T}
const OpenOpen{T} = IntervalSets.TypedEndpointsInterval{:open,:open, T}
const ClosedClosed{T} = IntervalSets.TypedEndpointsInterval{:closed,:closed, T}

_isless(a,b) = Base.isless(a,b)
_isless(a::AbstractInterval, b) = _isless(leftendpoint(a), b)


function Base.isless(a::Interval{:closed,:open}, b::IntervalSets.Interval{:closed,:open})
    Base.isless(leftendpoint(a), leftendpoint(b))
end
