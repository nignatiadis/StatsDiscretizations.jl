using Infinity
using StatsDiscretizations

ℝ_discr = RealLineDiscretizer{:open,:closed}(-5:0.1:5)
@test ℝ_discr(2) == Interval{:open,:closed}(1.9,2)
@test ℝ_discr(2.0001) == Interval{:open,:closed}(2,2.1)

@test_throws Exception ℝ_discr[0]
@test_throws Exception ℝ_discr[1000]

𝕀_discr = BoundedIntervalDiscretizer{:open, :closed}(-5:0.1:5)

@test collect(𝕀_discr) == collect(ℝ_discr[2:(end-1)])

xs = rand(1000)
discr_𝕀_xs = 𝕀_discr.(xs)
@test all( in.(xs, discr_𝕀_xs))
@test discr_𝕀_xs == 𝕀_discr.(discr_𝕀_xs)
@test 𝕀_discr(Interval{:open,:open}(0.05,0.06))  == Interval{:open,:closed}(0.0,0.1)
@test 𝕀_discr(Interval{:open,:closed}(0.099,0.1))  == Interval{:open,:closed}(0.0,0.1)

@test_throws ArgumentError 𝕀_discr(Interval{:open,:closed}(0.05,0.15))
@test_throws ArgumentError 𝕀_discr(Interval{:open,:closed}(0.05,0.15))

@test_throws Exception 𝕀_discr(-10)
@test_throws ArgumentError 𝕀_discr(+10)

discr_ℝ_xs = ℝ_discr.(xs)
@test all( in.(xs, discr_ℝ_xs))
@test discr_ℝ_xs == 𝕀_discr.(discr_ℝ_xs)
@test ℝ_discr(Interval{:open,:open}(0.05,0.06))  == Interval{:open,:closed}(0.0,0.1)
@test ℝ_discr(Interval{:open,:closed}(0.099,0.1))  == Interval{:open,:closed}(0.0,0.1)

@test_throws ArgumentError ℝ_discr(Interval{:open,:closed}(0.05,0.15))


@test ℝ_discr(-10) == Interval{:open,:closed}(-∞,-5.0)
@test ℝ_discr(10) == Interval{:open,:closed}(5.0, ∞)
