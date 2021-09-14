# Original author:
# Mason Protter: protter@ualberta.ca

setDimPow(D::Dict, x::Unitful.Dimension{T}) where {T} = D[T] = x.power

function dimDict(x::Unitful.Dimensions{T}) where {T}
    D = Dict{Symbol,Rational}(:Length => 0,
             :Mass => 0,
             :Temperature => 0,
             :Time => 0,
             :Current => 0)
    for t in T
        setDimPow(D, t)
    end
    return D
end

dimDict(x::Unitful.Quantity{T}) where {T} = dimDict(dimension(x))

dimDict(x) = Dict{Symbol,Rational}(:Length => 0, :Mass => 0, :Temperature => 0, :Time => 0, :Current => 0)


gettypeparams(::Unitful.FreeUnits{T,U,V}) where {T,U,V} = T, U, V
const energydimension = gettypeparams(u"GeV")[2]

"""
    natural(q; base=u"eV")

Convert `q` to natural units based on the units specified by `base`. If `base` is 
unspecified, `natural` will default to `eV`. Currently, `natural` only supports 
`base`s with dimensions of energy. For all other `base` you will need to use `unnatrual` '
to convert.

Examples:

    julia> natural(1u"kg")
    5.609588650020686e35 eV

    julia> natural(1u"kg", base=u"GeV")
    5.609588650020685e26 GeV

    julia> natural(1u"m")
    5.067730759202785e6 eV^-1

    julia> natural(1u"m", base=u"GeV")
    5.067730759202785e15 GeV^-1
"""
natural(q; base=u"eV") = _natural(base, q)

function _natural(base::Unitful.FreeUnits{T,energydimension,U}, q) where {T,U}
    D = dimDict(q)
    (α, β, γ, δ, ϕ) = (D[:Length], D[:Mass], D[:Temperature], D[:Time], D[:Current])
    uconvert(base^(-α - δ + β + γ + ϕ),
             q * ħc^(-α + ϕ / 2) * ħ^(-δ) * c^(2(β - ϕ / 2)) * k^(γ) * (4π * ϵ0)^(-ϕ / 2))
end

function _natural(base::Unitful.FreeUnits{T,U,V}, q) where {T,U,V}
    throw("""natural(q; base)` where `base` has dimensions `$U` has not yet been implemented. Please use a base with dimensions of `energy` and then use `unnatural` to convert to your desired units.""")
end

"""
    unnatural(targetUnit, q)

Convert a quantity `q` to units specified by `targetUnits` automatically inserting whatever 
factors  of `ħ`, `c`, `ϵ₀` and `k` are required to make the conversion work.

Examples:

    julia> unnatural(u"m", 5.067730759202785e6u"eV^-1")
    1.0 m

    julia> unnatural(u"m/s", 1)
    2.99792458e8 m s^-1

    julia> unnatural(u"K", 1u"eV")
    11604.522060401006 K
"""
function unnatural(targetUnit, q)
    natTarget = natural(1targetUnit)
    natQ = natural(q)
    ratio = natQ / natTarget
    if typeof(ratio |> dimension) == Unitful.Dimensions{()}
        (ratio)targetUnit
    else
        throw(Unitful.DimensionError)
    end
end
