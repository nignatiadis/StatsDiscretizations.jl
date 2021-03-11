# StatsDiscretizations

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://nignatiadis.github.io/StatsDiscretizations.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://nignatiadis.github.io/StatsDiscretizations.jl/dev)
[![Build Status](https://github.com/nignatiadis/StatsDiscretizations.jl/workflows/CI/badge.svg)](https://github.com/nignatiadis/StatsDiscretizations.jl/actions)
[![Coverage](https://codecov.io/gh/nignatiadis/StatsDiscretizations.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/nignatiadis/StatsDiscretizations.jl)

Julia package to simplify discretization operations that are routine in statistical tasks.


The discretizers implemented in this package have the following properties:
* Callable as `discretizer(z)` and broadcastable `discretizer.(zs)`.
* Return intervals: `typeof(discretizer(z)) <::AbstractInterval`.
* Idempotent: `discretizer(discretizer(z)) == discretizer(z)`.


(Warning: The package commits ''light'' type piracy, e.g., by implementing `Distributions.pdf(dbn, int::AbstractInterval)`.)