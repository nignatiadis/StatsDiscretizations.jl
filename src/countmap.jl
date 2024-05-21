function sorted_countmap(xs...; kwargs...)
    cmap = countmap(xs...)
    cmap = Dictionary(cmap)
    sortkeys!(cmap; lt=_isless, by=unwrap, kwargs...)
end    