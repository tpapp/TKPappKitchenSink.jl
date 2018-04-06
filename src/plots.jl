export
    default_grid_size, plot_function_around, plot_local_slices

"""
    $SIGNATURES

Find integers `w` and `h` such that `w * h ≥ n` and `abs2(w/h-aspect_ratio)` is
minimized. Return `(w, h)`.

Useful for determining grid size for `n` subplots.

The algorithm uses a heuristic, making an initial guess as the closest integer
to `√(aspect_ratio/r)`, and minimizing the objective within the nearest `± d`
integers.
"""
function default_grid_size(n; aspect_ratio = 4//3, d = 2)
    hs = filter(h -> h ∈ 1:n, @. round(√(n/aspect_ratio) + (-d:d)))
    ws = cld.(n, hs)
    _, ix = findmin(@. abs2((ws / hs) - aspect_ratio))
    ws[ix], hs[ix]
end

"""
    $SIGNATURES

Return `PGFPlotsX.Plot` elements visualizing the function ``f`` on ``x ± Δ``,
using `n` points. For plotting directly, use

```julia
Axis(plot_function_around(f, x, Δ)...)
```
"""
function plot_function_around(f, x::Real, Δ::Real; n = 100)
    xs = linspace(x - Δ, x + Δ, n)
    @pgf (Plot(Table(xs, f.(xs))),
          Plot({ only_marks }, Table([x], [f(x)])))
end

"""
    $SIGNATURES

Plot slices of the ``ℝⁿ→ℝ`` around `x ± Δs`. Return a `GroupPlot`, with subplots
arranged using `default_grid_size` using `aspect_ratio`. `xlabelfun` generates
labels for coordinates from the coordinate index, while `ylabel` provides the
`y` label.
"""
function plot_local_slices(f, x::AbstractVector, Δs::AbstractVector;
                           aspect_ratio = 4//3,
                           grid_size = default_grid_size(length(x)),
                           xlabelfun = i -> "\$x_{$(i)}\$",
                           ylabel = raw"$f$")
    @argcheck length(x) == length(Δs)
    w, h = grid_size
    plots = []
    for (i, Δ) in enumerate(Δs)
        push!(plots, @pgf { xlabel = xlabelfun(i) })
        append!(plots, plot_function_around(function_slice(f, x, i),
                                            zero(eltype(x)), Δ))
    end
    @pgf GroupPlot({ group_style = { group_size = "$w by $h"},
                     ylabel = ylabel},
                   plots...)
end
