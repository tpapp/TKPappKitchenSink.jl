export
    showfull,
    local_test,
    edit_list

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

function _edit_list(ms, n)
    if isempty(ms)
        print_with_color(:red, "no methods.\n")
        return
    end
    ms = collect(ms)
    N = length(ms)
    firstmsg = N > n ? ", only first $n of $N shown" : ""
    print_with_color(:yellow, "select a method (C-d exit$firstmsg)\n")
        for (index, method) in enumerate(Base.Iterators.take(ms, n))
        print_with_color(:green, "$(index)) ")
        print(method)
        println()
    end
    while true
        selection = strip(readline())
        if isempty(selection)
            break
        else
            index = tryparse(Int, selection)
            if isnull(index) || (get(index) ∉ 1:length(ms))
                println_with_color(:red, "invalid selection $(selection), ",
                                   "exit with RET")
            else
                edit(ms[get(index)])
                break
            end
        end
    end
end

"""
    edit_list(f; [max)

List methods of a function, edit the selected one.
"""
edit_list(f::Function; max_methods = 20) =
    _edit_list(methods(f), max_methods)

edit_list(f::Function, t::Type; max_methods = 20, showparents = true) =
    _edit_list(methodswith(t, f, showparents), max_methods)
