module ConstructionBaseUnitfulExt
using Unitful
import ConstructionBase: constructorof

constructorof(::Type{Unitful.Quantity{_,D,U}}) where {_,D,U} =
    Unitful.Quantity{T,D,U} where T

end
