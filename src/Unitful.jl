module Unitful

using Reexport
@reexport using UnitfulBase

using UnitfulBase: register
import UnitfulBase: dimension, unit, ustrip, uconvert, numtype, isrootpower_dim

import UnitfulBase: uparse
uparse(str; unit_context=Unitful) = uparse(str, unit_context)

import Dates

import Base: round, floor, ceil, trunc, convert
import Base: +, -, *, /, //, fld, cld, mod, rem, atan, ==, isequal, <, isless, <=
import Base: div, isapprox 

const promotion = UnitfulBase.promotion

include("pkgdefaults.jl")
include("dates.jl")

function __init__()
    register(Unitful)
    merge!(UnitfulBase.promotion, promotion)
end

end
