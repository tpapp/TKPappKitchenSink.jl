module TKPappKitchenSink

using Plots

"""
    density_slice(ℓ, x, ix1, x1s, ix2, x2s; [xlab], [ylab])

Visualize 2D slices of the log density `ℓ` around `x`, along axes `ix1` and `ix2`, with values `x1s` and `x2s`, respectively.
"""
function density_slice(ℓ, x, ix1, x1s, ix2, x2s;
                       xlab = "slice $ix1", ylab = "slice $ix2")
    x = copy(x)
    function g(x1, x2)
        x[ix1] = x1
        x[ix2] = x2
        ℓ(x)
    end
    z = g.(x1s, x2s')
    z .-= maximum(z)
    heatmap(x1s, x2s, exp.(z'), xlab = xlab, ylab = ylab)
end

end # module
