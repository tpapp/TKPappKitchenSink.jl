export similar_basis_vector, function_slice

"""
    $SIGNATURES

Return a vector with `1` at index `i` and `0`s otherwise (ie a standard basis
vector), similar to the first argument.
"""
function similar_basis_vector(x::AbstractVector{T}, i::Integer) where T
    v = zeros(T, length(x))
    v[i] = one(T)
    v
end

similar_basis_vector(::SVector{N, T}, i::Integer) where {N, T} =
    SVector{N, T}(ntuple(j -> i == j ? one(T) : zero(T), N)...)

"""
    $SIGNATURES

Return a callable implementing ``λ ↦ f(x + λv)``.
"""
function function_slice(f, x::AbstractVector, v::AbstractVector)
    @argcheck length(x) == length(v)
    λ -> f(x .+ λ * v)
end

"""
    $SIGNATURES

Return a callable implementing ``λ ↦ f(x + λe)``, where ``e`` is the `i`th
standard basis vector.
"""
function_slice(f, x::AbstractVector, i::Integer) =
    function_slice(f, x, similar_basis_vector(x, i))
