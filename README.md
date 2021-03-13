# StatsDiscretizations

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://nignatiadis.github.io/StatsDiscretizations.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://nignatiadis.github.io/StatsDiscretizations.jl/dev)
[![Build Status](https://github.com/nignatiadis/StatsDiscretizations.jl/workflows/CI/badge.svg)](https://github.com/nignatiadis/StatsDiscretizations.jl/actions)
[![Coverage](https://codecov.io/gh/nignatiadis/StatsDiscretizations.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/nignatiadis/StatsDiscretizations.jl)

Julia package to simplify discretization operations that are routine in statistical tasks. The key idea of the package is that a lot of statistical operations
can be simplified by giving first class support to Intervals from the [IntervalSets.jl](https://github.com/JuliaMath/IntervalSets.jl) package.


## Discretizers
Let ℐ the set of all intervals on ℝ. The key idea is that a `discretizer` acts as a function from ℝ ∪ ℐ ↦ ℐ with the following properties:
* Callable as `discretizer(z)` and broadcastable `discretizer.(zs)`.
* Returns intervals: `typeof(discretizer(z)) <: AbstractInterval`.
* Idempotent: `discretizer(discretizer(z)) == discretizer(z)`.

The discretizers that are currently implemented are the following

### `RealLineDiscretizer{:open,:closed}(grid), RealLineDiscretizer{:closed,:open}(grid)`

This is a discretizer that partitions the whole real line into intervals with breakpoints at `grid`. For example:
```julia
julia> using StatsDiscretizations
julia> discr = RealLineDiscretizer{:open,:closed}(-2:0.1:2)
julia> discr(-5)
-Inf..-2.0 (open–closed)
julia> discr(0.05)
0.0..0.1 (open–closed)
julia> discr(0.00)
-0.1..0.0 (open–closed)
```






## Warning
 The package commits ''light'' type piracy, e.g., by implementing `Distributions.pdf(dbn, int::AbstractInterval)`.