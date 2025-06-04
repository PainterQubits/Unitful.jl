module PrintfExt

using Printf
using Unitful

Printf.plength(f::Printf.Spec{<:Printf.Ints}, x::AbstractQuantity{<:Real}) = Printf.plength(f, ustrip(x)) + length(string(unit(x))) + Unitful.has_unit_spacing(unit(x))

# separate methods for disambiguation
Printf.fmt(buf, pos, arg::AbstractQuantity{<:Real}, spec::Printf.Spec{<:Printf.Floats}) = _fmt(buf, pos, arg, spec)
Printf.fmt(buf, pos, arg::AbstractQuantity{<:Real}, spec::Printf.Spec{<:Printf.Ints}) = _fmt(buf, pos, arg, spec)

function _fmt(buf, pos, arg, spec)
    pos = Printf.fmt(buf, pos, ustrip(arg), spec)
    if Unitful.has_unit_spacing(unit(arg))
        pos = Printf.fmt(buf, pos, ' ', only((Printf.format"%c").formats))
    end
    pos = Printf.fmt(buf, pos, string(unit(arg)), only((Printf.format"%s").formats))
    return pos
end

end
