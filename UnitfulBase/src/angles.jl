# Angles and solid angles
@unit sr      "sr"      Steradian   1                       true
@unit rad     "rad"     Radian      1                       true
@unit °       "°"       Degree      pi/180                  false
# For numerical accuracy, specific to the degree
import Base: sind, cosd, tand, secd, cscd, cotd
for (_x,_y) in ((:sin,:sind), (:cos,:cosd), (:tan,:tand),
        (:sec,:secd), (:csc,:cscd), (:cot,:cotd))
    @eval ($_x)(x::Quantity{T, NoDims, typeof(°)}) where {T} = ($_y)(ustrip(x))
    @eval ($_y)(x::Quantity{T, NoDims, typeof(°)}) where {T} = ($_y)(ustrip(x))
end
