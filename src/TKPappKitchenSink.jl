module TKPappKitchenSink

using Plots

export
    density_slice,
    showfull,
    local_test

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

"""
    showfull(x)
    showfull(io, x)

Print arguments without truncation.
"""
showfull(io, x) = show(IOContext(io; compact = false, limit = false), x)
showfull(x) = showfull(STDOUT, x)

"""
    local_test(pkgname, [coverage])

Find and test a package in `LOAD_PATH`. Useful when the package is outside
`Pkg.dir()`.

Assumes the usual directory structure: package has the same name as the module,
the main file is in `src/Pkgname.jl`, while tests are in `test/runtests.jl`.
"""
function local_test(pkgname; coverage::Bool=false)
    module_path = Base.find_in_path(pkgname, nothing)
    src_dir, module_file = splitdir(module_path)
    dir = normpath(src_dir, "..")
    test_path = joinpath(dir, "test", "runtests.jl")
    @assert isfile(test_path) "Could not find $(test_path)"
    Base.cd(dir) do
        try
            color = Base.have_color? "--color=yes" : "--color=no"
            codecov = coverage? ["--code-coverage=user"] : ["--code-coverage=none"]
            compilecache = "--compilecache=" * (Bool(Base.JLOptions().use_compilecache) ? "yes" : "no")
            julia_exe = Base.julia_cmd()
            run(`$julia_exe --check-bounds=yes $codecov $color $compilecache $test_path`)
            info("$module_file tests passed")
        catch err
            Base.Pkg.Entry.warnbanner(err, label="[ ERROR: $module_file ]")
        end
    end
end

end # module
