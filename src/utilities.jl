export
    showfull,
    edit_list

"""
    showfull(x)
    showfull(io, x)

Print arguments without truncation.
"""
showfull(io, x) = show(IOContext(io; compact = false, limit = false), x)
showfull(x) = showfull(STDOUT, x)

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
