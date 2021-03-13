function samplehull_discretizer(zs::AbstractVector{<:AbstractFloat},
                                algo::Discretizers.DiscretizationAlgorithm = DiscretizeUniformWidth(:auto);
                                closed = :right)
    grid = binedges(algo, zs)
    if closed === :right
        grid[1] = prevfloat(grid[1])
        return RealLineDiscretizer{:open,:closed}(grid)
    elseif closed === :left
        grid[end] = nextfloat(grid[end])
        return RealLineDiscretizer{:closed,:open}(grid)
    else
        throw(ArgumentError("closed can be :right or :left"))
    end
end


#function support_discretizer(Zs::AbstractVector, )
#    get_nbins
#end
