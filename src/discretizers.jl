abstract type AbstractRealLineDiscretizer{T <: AbstractInterval}  <: AbstractVector{T} end

function Base.size(discr::AbstractRealLineDiscretizer)
    (Base.length(discr), )
end

struct RealLineDiscretizer{L, R, T, G <:AbstractVector{T}} <: AbstractRealLineDiscretizer{Interval{L, R, T}}
    grid::G
end

function RealLineDiscretizer{L,R}(grid::G) where {L, R, T, G<:AbstractVector{T}}
    Tinf = hasinf(T) ? T : InfExtendedReal{T}
    RealLineDiscretizer{L,R,Tinf,G}(grid)
end

function Base.length(discr::RealLineDiscretizer)
    length(discr.grid) + 1
end

function Base.getindex(discr::RealLineDiscretizer{L,R,T}, i::Int) where {L,R,T}
    grid = discr.grid
    n = length(grid)
    if i==1
        Interval{L,R,T}(-∞, first(grid))
    elseif i==n+1
        Interval{L,R,T}(last(grid), +∞)
    elseif 1 < i <= n
        Interval{L,R,T}(grid[i-1], grid[i])
    else
        throw(IndexError("Out of bounds"))
    end
end

struct BoundedIntervalDiscretizer{L, R, T, G <:AbstractVector{T}} <: AbstractRealLineDiscretizer{Interval{L, R, T}}
    grid::G
end

function BoundedIntervalDiscretizer{L,R}(grid::G) where {L, R, T, G<:AbstractVector{T}}
    BoundedIntervalDiscretizer{L,R,T,G}(grid)
end

function Base.length(discr::BoundedIntervalDiscretizer)
    length(discr.grid) - 1
end

function Base.getindex(discr::BoundedIntervalDiscretizer{L,R,T}, i::Int) where {L,R,T}
    grid = discr.grid
    n = length(grid)
    if 1 <= i <= n-1
        Interval{L,R,T}(grid[i], grid[i+1])
    else
        throw(IndexError("Out of bounds"))
    end
end



function _discretize(sorted_intervals::AbstractRealLineDiscretizer, x)
    n = length(sorted_intervals)
    left, right = 1, n
    for i = 1:n
        middle = div(left + right, 2)
        middle_interval = sorted_intervals[middle]
        if x ⊆ middle_interval
            return middle_interval
        elseif _isless(x, rightendpoint(middle_interval))
            right = middle - 1
        else
            left = middle + 1
        end
    end
    throw(ArgumentError("x seems does not lie inside any interval of the discretization."))
end


function (discr::AbstractRealLineDiscretizer)(x)
    _discretize(discr, x)
end



#function discretize(x)
#    y = unwrap(x)
#    discretize(y)
#    wrap(y)
#end
