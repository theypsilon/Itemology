local Job = {}

function Job.refListener(table, key, onChange, firstTime, ...)
    assert(is_object(table))
    assert(key ~= nil)
    assert(is_callable(onChange))
    local last = table[key]
    if firstTime then onChange(last, ...) end
    return function(...)
        local value = table[key]
        if value ~= last then 
            last = value
            return value,  true, onChange(value, ...)
        else 
            return value, false, nil
        end
    end
end

function Job.cron(every, f, initial)
    assert(is_positive(every))
    assert(is_callable(f))
    local ticks = is_positive(initial) and initial or 0
    f = f or nothing
    return function(...)
        ticks = ticks + 1
        if ticks > every then
            ticks = 0
            return  true, ticks, f(...)
        else
            return false, ticks, nil
        end
    end
end

function Job.interval(f, initial, final)
    assert(is_callable(f))
    assert(is_positive(initial))
    assert(is_positive(final  ))
    local ticks = 0
    return function(...)
        if ticks >= initial and ticks <= final then
            return  true, ticks, f(...)
        else
            return false, ticks, nil
        end
        ticks = ticks + 1
    end
end

return Job