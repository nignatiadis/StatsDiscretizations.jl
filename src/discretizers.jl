abstract type AbstractRealLineDiscretizer{T}  <: AbstractVector{T} end

function Base.size(discr::AbstractRealLineDiscretizer)
    (length(discr),)
end

"""
    unwrap(x)

Unwraps the value `x`. By default, returns `x` as is.
"""
unwrap(x) = x

"""
    wrap(x, val)

Wraps the value `val` based on `x`. By default, returns `val` as is.
"""
wrap(x, val) = val


## RealLineDiscretizer

"""
    RealLineDiscretizer{L, R, T, G <:AbstractVector{T}} <: AbstractRealLineDiscretizer{Interval{L, R, T}}

An extended continuous discretizer that partitions the real line into intervals based on a given grid of points.
It extends the discretization beyond the grid by including intervals from -∞ to the first grid point and from
the last grid point to +∞.

The type parameters `L` and `R` specify the endpoint types of the intervals (e.g., `Closed` or `Open`),
`T` is the element type of the grid, and `G` is the type of the grid vector.

# Fields
- `grid::G`: The grid of points used for discretization.

# Examples
```julia
grid = [0.0, 1.0, 2.0]
discr = RealLineDiscretizer{Closed,Open}(grid)
```
"""
struct RealLineDiscretizer{L, R, T, G <:AbstractVector{T}} <: AbstractRealLineDiscretizer{Interval{L, R, T}}
    grid::G
end

function RealLineDiscretizer{L,R}(grid::G) where {L, R, T, G<:AbstractVector{T}}
    RealLineDiscretizer{L,R,T,G}(grid)
end

function Base.length(discr::RealLineDiscretizer)
    length(discr.grid) + 1
end

function Base.getindex(discr::RealLineDiscretizer{L,R,T}, i::Int) where {L,R,T}
    grid = discr.grid
    n = length(grid)
    if i==1
        Interval{L,R,T}(-Inf, first(grid))
    elseif i==n+1
        Interval{L,R,T}(last(grid), +Inf)
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

struct FiniteGridDiscretizer{T, G <:AbstractVector{T}} <: AbstractRealLineDiscretizer{T}
    grid::G
end

function Base.length(discr::FiniteGridDiscretizer)
    length(discr.grid)
end

function Base.getindex(discr::FiniteGridDiscretizer, i::Int)
    Base.getindex(discr.grid, i)
end

function _discretize(discr::FiniteGridDiscretizer, x)
    idx = findfirst(==(x), discr)
    isnothing(idx) && throw("x not in the supported grid")
    (idx, discr[idx])
end


struct ExtendedFiniteGridDiscretizer{T, F, G <:AbstractVector{T}} <: AbstractRealLineDiscretizer{Union{T,Interval{:closed, :open, F}}}
    grid::G
end

function ExtendedFiniteGridDiscretizer(grid::G) where {T, G<:AbstractVector{T}}
    ExtendedFiniteGridDiscretizer{T,Float64,G}(grid)
end

function Base.length(discr::ExtendedFiniteGridDiscretizer)
    length(discr.grid)
end

# not type stable but I doubt it's a problem for efficiency at this point
function Base.getindex(discr::ExtendedFiniteGridDiscretizer{T,F}, i::Int) where {T,F}
    grid = discr.grid
    n = length(grid)
    if i == 1
        return Interval{:closed,:closed,F}(-Inf, grid[1])
    elseif 1 < i < n
        return grid[i]
    elseif i == n
        return Interval{:closed,:closed,F}(grid[end], Inf)
    else
        throw(IndexError("Out of bounds"))
    end
end


function _discretize(discr::ExtendedFiniteGridDiscretizer{T,F}, x) where {T,F}
    grid = discr.grid
    n = length(grid)
    if x ⊆ discr[1]
        return (1, discr[1])
    elseif x ⊆ discr[end]
        return (n, discr[end])
    else
        idx = findfirst(==(x), grid)
        isnothing(idx) && throw("x not in the supported grid")
        return (idx+1, grid[idx])
    end
end



### Code that implements the discretization

_isless(a,b) = Base.isless(a,b)
_isless(a::AbstractInterval, b) = _isless(leftendpoint(a), b)
_isless(a, b::AbstractInterval) = _isless(a, leftendpoint(b))
_isless(a::AbstractInterval, b::AbstractInterval) = _isless(leftendpoint(a), leftendpoint(b))


# Generic fallback of the discretization
function _discretize(sorted_intervals::AbstractRealLineDiscretizer, x)
    n = length(sorted_intervals)
    left, right = 1, n
    for _ = 1:n
        middle = div(left + right, 2)
        middle_interval = sorted_intervals[middle]
        if x ⊆ middle_interval
            return (middle, middle_interval)
        elseif _isless(x, rightendpoint(middle_interval))
            right = middle - 1
        else
            left = middle + 1
        end
    end
    throw(ArgumentError("x seems does not lie inside any interval of the discretization."))
end

function (discr::AbstractRealLineDiscretizer)(x)
    x_val = unwrap(x)
    x_val_discr = last(_discretize(discr, x_val))
    wrap(x, x_val_discr)
end

function Base.findfirst(discr::AbstractRealLineDiscretizer, x)
    x_val = unwrap(x)
    first(_discretize(discr, x_val))
end