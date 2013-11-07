local Job = {}

function Job.refListener(table, key, onChange, firstTime, ...)
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

function Job.cron(every, f)
    local ticks = 0
    return function(...)
        ticks = ticks + 1
        if ticks > every then
            ticks = 0
            return  true, f(...)
        else
            return false, nil
        end
    end
end

return Job