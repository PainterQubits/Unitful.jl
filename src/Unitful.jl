module Unitful

import Base: ==, <, <=, +, -, *, /, //, ^, isequal
import Base: show, convert
import Base: abs, abs2, angle, float, fma, muladd, inv, sqrt, cbrt
import Base: min, max, floor, ceil, real, imag, conj
import Base: exp, exp10, exp2, expm1, log, log10, log1p, log2
import Base: sin, cos, tan, cot, sec, csc, atan, cis

import Base: eps, mod, rem, div, fld, cld, trunc, round, sign, signbit
import Base: isless, isapprox, isinteger, isreal, isinf, isfinite, isnan
import Base: copysign, flipsign
import Base: prevfloat, nextfloat, maxintfloat, rat, step
import Base: length, float, last, one, zero, range
import Base: getindex, eltype, step, last, first, frexp
import Base: Integer, Rational, typemin, typemax
import Base: steprange_last, unsigned

import LinearAlgebra: Diagonal, Bidiagonal, Tridiagonal, SymTridiagonal
import LinearAlgebra: istril, istriu, norm
import Random

export logunit, unit, dimension, uconvert, ustrip, upreferred
export @dimension, @derived_dimension, @refunit, @unit, @u_str
export Quantity, DimensionlessQuantity, NoUnits, NoDims

export uconvertp, uconvertrp, convertr, convertrp, reflevel, linear
export @logscale, @logunit, @dB, @B, @cNp, @Np
export Level, Gain

const unitmodules = Vector{Module}()
const basefactors = Dict{Symbol,Tuple{Float64,Rational{Int}}}()

include("types.jl")
const promotion = Dict{Symbol,Unit}()

include("user.jl")
include("utils.jl")
include("dimensions.jl")
include("units.jl")
include("quantities.jl")
include("display.jl")
include("promotion.jl")
include("conversion.jl")
include("range.jl")
include("fastmath.jl")
include("logarithm.jl")
include("pkgdefaults.jl")

function __init__()
    # @u_str should be aware of units defined in module Unitful
    Unitful.register(Unitful)
end

end
