function colon{T1<:Integer,T2<:Integer,T3<:Integer}(start::Quantity{T1},
        step::Quantity{T2}, stop::Quantity{T3})
    StepRange(promote(start, step, stop)...)
end

function colon(start::Quantity, step::Quantity, stop::Quantity)
    step == zero(step) && throw(ArgumentError("step cannot be zero"))
    len = floor(Int, (stop-start)/step + 1)
    stop′ = start + len*step
    len += (start < stop′ <= stop) + (start > stop′ >= stop)
    len = max(zero(len), len)
    len == 1 && return Ranges.linspace(start, start, len)
    Ranges.linspace(promote(start, stop)..., len)
end

function Base.range{T1<:Integer,T2<:Integer}(start::Quantity{T1},
        step::Quantity{T2}, len::Integer)
    StepRange(start, step, start+(len-1)*step)
end

function Base.range(start::Quantity, step::Quantity, len::Integer)
    stop = start + (len-1)*step
    Ranges.linspace(promote(start, stop)..., max(0, len))
end

Base.linspace(start::Quantity, stop::Quantity, len::Integer) =
    Ranges.linspace(promote(start, stop)..., len)

function Base.steprange_last{T<:Number,D,U}(start::Quantity{T,D,U}, step, stop)
    z = zero(step)
    step == z && throw(ArgumentError("step cannot be zero"))
    if stop == start
        last = stop
    else
        if (step > z) != (stop > start)
            last = start - step
        else
            diff = stop - start
            if T<:Signed && (diff > zero(diff)) != (stop > start)
                # handle overflowed subtraction with unsigned rem
                if diff > zero(diff)
                    remain = -convert(typeof(start), unsigned(-diff) % step)
                else
                    remain = convert(typeof(start), unsigned(diff) % step)
                end
            else
                remain = Base.steprem(start,stop,step)
            end
            last = stop - remain
        end
    end
    last
end
