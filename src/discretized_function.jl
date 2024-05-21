Base.@kwdef struct DiscretizedFunction{S<:AbstractRealLineDiscretizer, D<:AbstractDictionary, T, E<:AbstractDictionary}
    discretizer::S
    dictionary::D
    default_value::T = zero(eltype(values(dictionary)))
    index_dictionary::E = Dictionary(keys(dictionary), Base.OneTo(length(dictionary)))
end


Base.keys(dictfun::DiscretizedFunction) = Base.keys(dictfun.dictionary)

Base.values(dictfun::DiscretizedFunction) = Base.values(dictfun.dictionary)


function dictfun(discr::AbstractRealLineDiscretizer, vals::AbstractVector, flift=identity)
    DiscretizedFunction(;discretizer=discr, dictionary=Dictionary(flift.(discr), vals))
end 

function dictfun(discr::AbstractRealLineDiscretizer, f, flift=identity)
    dictfun(discr, f.(flift.(discr)), flift)
end 

function (f::DiscretizedFunction)(x, default_value=f.default_value)
    get(f.dictionary, f.discretizer(x), default_value)
end