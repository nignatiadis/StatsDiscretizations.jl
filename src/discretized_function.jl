Base.@kwdef struct DiscretizedFunction{S<:AbstractRealLineDiscretizer, D<:AbstractDictionary, E<:AbstractDictionary}
    discretizer::S
    dictionary::D
    index_dictionary::E = Dictionary(keys(dictionary), Base.OneTo(length(dictionary)))
end

function DiscretizedFunction(discr::AbstractRealLineDiscretizer, vals::AbstractVector)
    DiscretizedFunction(;discretizer=discr, dictionary = Dictionary(discr, vals))
end

function DiscretizedFunction(discr::AbstractRealLineDiscretizer, f)
    DiscretizedFunction(discr, f.(discr))
end

function DiscretizedFunction(discr::AbstractRealLineDiscretizer, flift, f)
    dictionary = Dictionary( flift.(discr),  f.(discr))
    DiscretizedFunction(;discretizer=discr, dictionary = dictionary)
end

function (f::DiscretizedFunction)(x)
    f.dictionary[f.discretizer(x)]
end

function (f::DiscretizedFunction)(x, default_value)
    get(f.dictionary, f.discretizer(x), default_value)
end