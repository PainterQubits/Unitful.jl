module InverseFunctionsUnitfulExt
using Unitful
import InverseFunctions: inverse

# `true` plays the role of 1, but doesn't promote unnecessary
inverse(f::Base.Fix1{typeof(ustrip), <:Unitful.Units}) = Base.Fix1(*, true*f.x)

end
