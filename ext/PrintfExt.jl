module PrintfExt

using Printf
using Unitful

Printf.plength(f::Printf.Spec{<:Printf.Ints}, x::Quantity) = Printf.plength(f, ustrip(x)) + length(string(unit(x)))

function Printf.fmt(buf, pos, arg::Quantity, spec::Printf.Spec{<:Printf.Floats})
    pos = Printf.fmt(buf, pos, ustrip(arg), spec)
    pos = Printf.fmt(buf, pos, string(unit(arg)), only((Printf.format"%s").formats))
    return pos
end

# same function body as above – a separate method is needed for disambiguation
function Printf.fmt(buf, pos, arg::Quantity, spec::Printf.Spec{<:Printf.Ints})
    pos = Printf.fmt(buf, pos, ustrip(arg), spec)
    pos = Printf.fmt(buf, pos, string(unit(arg)), only((Printf.format"%s").formats))
    return pos
end

end
