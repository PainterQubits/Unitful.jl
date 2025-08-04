#!/bin/julia

# generate_latex_images.jl
# Run locally (rarely) to generate a couple of figures needed by the
# documentation

using LaTeXStrings, Unitful, Latexify, UnitfulLatexify

mktempdir() do dir
    commands = [
        :(latexify(612.2u"nm")),
        :(latexify(u"kg*m/s^2")),
        :(latexify(612.2u"nm"; fmt=SiunitxNumberFormatter())),
        :(latexify(u"kg*m/s^2"; fmt=SiunitxNumberFormatter())),
        :(latexify(612.2u"nm"; fmt=SiunitxNumberFormatter(; simple=true))),
        :(latexify(u"kg*m/s^2"; fmt=SiunitxNumberFormatter(; simple=true))),
        :(latexify((1:5)u"m"; fmt=SiunitxNumberFormatter())),
        :(latexify((1, 2, 4) .* u"m"; fmt=SiunitxNumberFormatter())),
    ]

    open(joinpath(dir, "examples.tex"), "w") do f
        print(
            f,
            raw"""
            \documentclass{standalone}
            \usepackage{booktabs}
            \usepackage{siunitx}
            \begin{document}
            \begin{tabular}{lll}\toprule\\
            \textt{julia} & \LaTeX & Result \\\midrule
            """,
        )
        for command in commands
            print(
                f,
                raw"\verb+",
                string(command),
                raw"+",
                raw"& \verb+",
                eval(command),
                raw"+",
                raw"& ",
                eval(command),
                " \\\\\n",
            )
        end
        print(
            f,
            raw"""
            \bottomrule
            \end{tabular}
            \end{document}
            """,
        )
    end

    # List manually imported from Unitful/src/pkgdefaults.jl
    # Could be automated by temporarily redefining @unit, @affineunit ... and include()ing this file.
    functions = [
        x -> "\\verb+$(string(x))+",
        x -> latexify(x; fmt=SiunitxNumberFormatter()),
        x -> latexify(x; fmt=SiunitxNumberFormatter()),
        x -> latexify(x; fmt=SiunitxNumberFormatter(; simple=true)),
    ]
    allunits = begin
        uparse.([
            "nH*m/Hz",
            "m",
            "s",
            "A",
            "K",
            "cd",
            "g",
            "mol",
            "sr",
            "rad",
            "°",
            "Hz",
            "N",
            "Pa",
            "J",
            "W",
            "C",
            "V",
            "S",
            "F",
            "H",
            "T",
            "Wb",
            "lm",
            "lx",
            "Bq",
            "Gy",
            "Sv",
            "kat",
            #"percent", # Messes with comments
            "permille", # Undefined in all formats
            "pertenthousand", # Undefined in all formats (butchered)
            "°C",
            "°F",
            "minute",
            "hr",
            "d",
            "wk", # Undefined in siunitx
            "yr", # Undefined in siunitx
            "rps", # Undefined in siunitx
            "rpm", # Undefined in siunitx
            "a", # Undefined in siunitx
            "b",
            "L",
            "M", # Undefined in siunitx
            "eV",
            "Hz2π", # Butchered by encoding
            "bar",
            "atm", # Undefined in siunitx
            "Torr", # Undefined in siunitx
            "c", # Undefined in siunitx
            "u", # Undefined in siunitx
            "ge", # Undefined in siunitx
            "Gal", # Undefined in siunitx
            "dyn", # Undefined in siunitx
            "erg", # Undefined in siunitx
            "Ba", # Undefined in siunitx
            "P", # Undefined in siunitx
            "St", # Undefined in siunitx
            #"Gauss", # errors in testing, maybe from Unitful.jl's dev branch?
            #"Oe", # errors in testing, maybe from Unitful.jl's dev branch?
            #"Mx", # errors in testing, maybe from Unitful.jl's dev branch?
            "inch", # Undefined in siunitx
            "mil", # Undefined in siunitx
            "ft", # Undefined in siunitx
            "yd", # Undefined in siunitx
            "mi", # Undefined in siunitx
            "angstrom", # Undefined in mathrm,siunitxsimple
            "ac", # Undefined in siunitx
            "Ra", # Undefined in siunitx
            "lb", # Undefined in siunitx
            "oz", # Undefined in siunitx
            "slug", # Undefined in siunitx
            "dr", # Undefined in siunitx
            "gr", # Undefined in siunitx
            "lbf", # Undefined in siunitx
            "cal", # Undefined in siunitx
            "btu", # Undefined in siunitx
            "psi", # Undefined in siunitx
            #"dBHz", # Cannot *yet* be latexified.
            #"dBm", # Cannot *yet* be latexified.
            #"dBV", # Cannot *yet* be latexified.
            #"dBu", # Cannot *yet* be latexified.
            #"dBμV", # Cannot *yet* be latexified.
            #"dBSPL", # Cannot *yet* be latexified.
            #"dBFS", # Cannot *yet* be latexified.
            #"dBΩ", # Cannot *yet* be latexified.
            #"dBS", # Cannot *yet* be latexified.
        ])
    end

    open(joinpath(dir, "allunits.tex"), "w") do f
        print(
            f,
            raw"""
            \documentclass{standalone}
            \usepackage{booktabs}
            \usepackage{siunitx}
            \begin{document}
            \begin{tabular}{llll}\toprule\\
            Name & \texttt{mathrm} & \texttt{siunitx} & \texttt{siunitx+simple} \\\midrule
            """,
        )
        for unit in allunits
            join(f, [fun(unit) for fun in functions], " & ")
            print(f, " \\\\\n")
        end
        print(
            f,
            raw"""
            \bottomrule
            \end{tabular}
            \end{document}
            """,
        )
    end

    for s in ["examples", "allunits"]
        try
            run(
                `xelatex -interaction=nonstopmode -output-directory $dir $(joinpath(dir,s*".tex"))`,
            )
        catch
        end

        try
            run(
                `magick -fill white -opaque none -density 600 -quality 90 $(joinpath(dir,s*".pdf")) $(joinpath(pkgdir(UnitfulLatexify),"docs","src","assets","latex-"*s*".png"))`,
            )
        catch
        end
    end
end
