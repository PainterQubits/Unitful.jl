module MakeDefUnitsDocs

using Unitful, OrderedCollections

mdfile = "docs/src/defaultunits.md"
mdheader = "docs/src/assets/defaultunits-header.md"
mdfooter = "docs/src/assets/defaultunits-footer.md"
mdlogunits = "docs/src/assets/defaultunits-logunits.md"
vfile = "docs/src/assets/vfile.txt"

"""
# Examples
```julia-repl
julia> prefnamesvals()
OrderedCollections.OrderedDict{String, Tuple{String, Int64}} with 20 entries:
  "y"  => ("yocto", -24)
  "z"  => ("zepto", -21)
  ⋮    => ⋮
"""
function prefnamesvals()
    prefixnames = Dict(
        "Q"  => "quetta",
        "R"  => "ronna",
        "Y"  => "yotta",
        "Z"  => "zetta",
        "E"  => "exa",
        "P"  => "peta",
        "T"  => "tera",
        "G"  => "giga",
        "M"  => "mega",
        "k"  => "kilo",
        "h"  => "hecto",
        "da" => "deca",
        "d"  => "deci",
        "c"  => "centi",
        "m"  => "milli",
        "μ"  => "micro",
        "n"  => "nano",
        "p"  => "pico",
        "f"  => "femto",
        "a"  => "atto",
        "z"  => "zepto",
        "y"  => "yocto",
        "r"  => "ronto",
        "q"  => "quecto")
    pd = Unitful.prefixdict
    sxp = sort(collect(keys(pd)))

    return OrderedDict(pd[k] => (prefixnames[pd[k]], k) for k in sxp if pd[k] != "")
end

regularid(n) = !startswith(string(n), r"#|@")

uful_ids() = filter(regularid, names(Unitful; all=true))

docstr(n::Symbol) = Base.Docs.doc(Base.Docs.Binding(Unitful, n)) |> string

isprefixed(u::Symbol) = occursin("A prefixed unit, equal", docstr(u))

isdocumented(n::Symbol) = !startswith(docstr(n), "No documentation found.")

"""
# Examples
```julia-repl
julia> gettypes(Unitful.Power)
1-element Vector{DataType}:
 Quantity{T, 𝐋^2 𝐌 𝐓^-3, U}
```
"""
function gettypes(x::Type)
    if x isa UnionAll
        return gettypes(x.body)
    elseif x isa Union
        pns = propertynames(x)
        ts = [getproperty(x, pn) for pn in pns]
        ts = [t for t in ts if (t isa Type) && (t <: Unitful.Quantity)]
        return ts
    elseif x <: Unitful.Quantity
        return [x]
    else
        return []
    end
end


"""
    getphysdims(uids::Vector{Symbol})
Filters the list of `Unitful` identifiers to return those which denote physical dimensions (e.g. `Area`, `Power`)
"""
getphysdims(uids) = [n for n in uids 
        if (getproperty(Unitful, n) isa UnionAll) && 
            !endswith(string(n), "Units") &&
            !occursin("Scale", string(n)) &&
            !isempty(gettypes(getproperty(Unitful, n)))]

"""
# Examples
```julia-repl
julia> getdim(Unitful.Area)
𝐋^2
```
"""
getdim(x::Type) = gettypes(x)[1].parameters[2]
getdim(x::Symbol) = getdim(getproperty(Unitful, x))

"""
# Examples
```julia-repl
julia> getdimpars(Unitful.Power)
svec((Unitful.Dimension{:Length}(2//1), Unitful.Dimension{:Mass}(1//1), Unitful.Dimension{:Time}(-3//1)))
```
"""
getdimpars(x) = getproperty(typeof(getdim(x)), :parameters)
getdimpar(x) = getdimpars(x)[1][1]
getdimpow(x) = getdimpar(x).power

isbasicdim(x) = length(getdimpars(x)[1])== 1 && getdimpow(x) == 1

function physdims_categories(physdims)
    basicdims = Symbol[]
    compounddims = Symbol[]
    otherdims =  Symbol[]
    for d in physdims
        try
            if isbasicdim(d)
                push!(basicdims, d)
            else
                push!(compounddims, d)
            end
        catch
            push!(otherdims, d)
        end
    end
    return (;basicdims, compounddims, otherdims, )
end

"""
# Examples
```julia-repl
julia> unitsdict(basicdims, uids)
OrderedCollections.OrderedDict{Symbol, Vector{Symbol}} with 7 entries:
  :Amount      => [:mol]
  :Current     => [:A]
  :Length      => [:angstrom, :ft, :inch, :m, :mi, :mil, :yd]
  :Luminosity  => [:cd, :lm]
  :Mass        => [:dr, :g, :gr, :kg, :lb, :oz, :slug, :u]
  :Temperature => [:K, :Ra, :°C, :°F]
  :Time        => [:d, :hr, :minute, :s, :wk, :yr]
```
"""
function unitsdict(physdims, uids)
    ups = []
    for d in physdims
        dm = getproperty(Unitful, d)
        units = Symbol[]
        for uname in uids
            u = getproperty(Unitful, uname)
            if (u isa Unitful.Units) 
                if (1*u isa dm) && (!isprefixed(uname) || uname == :g) && isdocumented(uname) # gram considered prefixed unit
                    push!(units, uname)
                end
            end
        end
        if !isempty(units) 
            sort!(units; by = x -> lowercase(string(x)))
            unique!(nameofunit, units) # special cases: Liter, Angstrom
            push!(ups, d => units)
        end
    end
    return OrderedDict(sort!(ups))
end

function physconstants(uids) 
    ph_consts = [n for n in uids if 
    isconst(Unitful, n) && 
    !(getproperty(Unitful, n) isa Union{Type, Unitful.Units, Unitful.Dimensions, Module, Function}) &&
    isdocumented(n) ]
    sort!(ph_consts)
    return ph_consts
end

function isnodims(u) 
    u isa Unitful.FreeUnits || return false
    return getproperty(typeof(u), :parameters)[2] == NoDims
end
isnodims(u::Symbol) = isnodims(getproperty(Unitful, u))

nodimsunits(uids) = [n for n in uids if isnodims(n) && isdocumented(n) && !isprefixed(n) && n != :NoUnits]

removerefs(d) = replace(d, r"\[(`[\w\.]+\`)]\(@ref\)" => s"\1")

"""
    udoc(s)
Truncates documentation and removes references
"""
udoc(s) = match(r"(?ms)(.+)\n\nDimension: ", docstr(s)).captures[1] |> removerefs

function nameofunit(u)
    special = Dict(u"ha" => "Hectare", u"kg" => "Kilogram", u"°F" => "Degree Fahrenheit", u"°C" => "Degree Celcius")
    u in keys(special) && return special[u]
    t = typeof(u)
    ps = getproperty(t, :parameters)
    u1 = ps[1][1]
    @assert u1 isa Unitful.Unit
    t1 = typeof(u1)
    uname = getproperty(t1, :parameters)[1]
    return string(uname)
end

nameofunit(s::Symbol) = nameofunit(getproperty(Unitful, s))

function make_subsection_text(uvec; isunit=true)
    s = ""
    for u in uvec 
        if isunit
            n = nameofunit(u)
        else
            n = string(u)
        end
        d = udoc(u) 
        s *= "#### $n \n\n$d \n\n"
    end
    return s
end

function make_simple_section_text(sectiontitle, uvec; isunit=true)
    s = "## $sectiontitle \n\n"
    s *= make_subsection_text(uvec; isunit)
    return s
end

function make_structured_section_text(sectiontitle, sectiondict)
    s = "## $sectiontitle \n\n"
    for (dim, uvec) in sectiondict 
        s *= "### $dim\n\n"
        s *= make_subsection_text(uvec)
    end
    return s
end

function makeprefixsection(pnv)
    s = """
## Metric (SI) Prefixes

| Prefix | Name | Power of Ten |
|--------|--------|--------|
"""
    for (k,v) in pnv
        s *= "| $k | $(v[1]) | $(v[2]) | \n"
    end

    return s
end


header() = read(mdheader, String) 
footer() = read(mdfooter, String)
logunits() = read(mdlogunits, String)

function makefulltext(sections, nodims_units, phys_consts)
    s = header() * "\n\n"
    for (sectiontitle, sectiondict) in sections
        s *= make_structured_section_text(sectiontitle, sectiondict)
    end
    s *= make_simple_section_text("Dimensionless units", nodims_units)
    s *= logunits()
    s *= make_simple_section_text("Physical constants", phys_consts; isunit=false)
    s *= makeprefixsection(prefnamesvals())
    s *= footer()
    return s
end

function write_unitful_v(vfile)
    open(vfile, "w") do io
        println(io, pkgversion(Unitful))
    end
    return nothing
end

function savetext(fulltext, mdfile)
    open(mdfile,"w") do io
       write(io, fulltext)
    end
    write_unitful_v(vfile)
    return nothing
end

"""
    make_chapter(wr = true; verbose = false)
Generates the text of the `Pre-defined units and constants` documentation section 
and writes it into the file if `wr==true`
"""
function make_chapter(wr = true; verbose = false)
    uids = uful_ids()

    (;basicdims, compounddims) = uids |> getphysdims |> physdims_categories

    basic_units =  unitsdict(basicdims, uids)
    compound_units = unitsdict(compounddims, uids)
    nodims_units = nodimsunits(uids) 
    sections = OrderedDict(["Basic dimensions" => basic_units, 
        "Compound dimensions" => compound_units])
    phys_consts = physconstants(uids)

    fulltext = makefulltext(sections, nodims_units, phys_consts)

    wr && savetext(fulltext, mdfile)

    if verbose
        return (;fulltext, sections, nodims_units, phys_consts)
    else
        return nothing
    end
end

export make_chapter

end # module
