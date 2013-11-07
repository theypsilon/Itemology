global{callbacks = {}}

local task = {}

function task._prepareIndex(index)
    return index
end

function task.set(index, f, timer)
    callbacks[task._prepareIndex(index)] = f
end

function task.setOnce(index, f, timer)
    index = task._prepareIndex(index)
    local once = function()
        f()
        callbacks[index] = nil
    end
    if timer and timer > 0 then
        callbacks[index] = function() 
            timer = timer - 1 
            if timer == 0 then callbacks[index] = once end
        end
    else
        callbacks[index] = once
    end
end

function task.iterator()
    return pairs(callbacks)
end

return task