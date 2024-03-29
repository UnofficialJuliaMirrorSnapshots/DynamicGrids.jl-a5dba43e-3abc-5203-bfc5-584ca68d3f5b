"""
Chains allow chaining rules together to be completed in a single processing step
without intermediate writes, and potentially compiled together into a single function call. 
These can either be all CellRule or NeighborhoodRule followed by CellRule.
"""
struct Chain{T} <: Rule
    val::T
end
Chain(t::Tuple) = begin
    if !(t[1] isa Union{NeighborhoodRule, CellRule})
        throw(ArgumentError("Only `NeighborhoodRule` or `CellRule` allowed as first rule in a `Chain`. $(Base.nameof(typeof(r))) found"))
    end
    map(tail(t)) do r
        if !(r isa CellRule)
            throw(ArgumentError("Only `CellRule` allowed in a `Chain`. $(Base.nameof(typeof(r))) found"))
        end
    end
    Chain{typeof(t)}(t)
end
Chain(x) = Chain((x,))
Chain(args...) = Chain(args)


val(chain::Chain) = chain.val

Base.show(io::IO, chain::Chain) = begin
    indent = get(io, :indent, "")
    printstyled(io, indent, "Chain :"; color=:green)
    for rule in val(chain)
        println(io)
        print(IOContext(io, :indent => indent * "    "), rule)
    end
end
Base.tail(chain::Chain) = (ch = tail(val(chain)); Chain{typeof(ch)}(ch))
Base.getindex(chain::Chain, I...) = getindex(val(chain), I...)
Base.size(chain::Chain) = size(val(chain))
