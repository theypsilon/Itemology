global{callbacks = {}}

local task = {}

function task._prepareIndex(index)
    return index
end

function task.set(index, f)
    callbacks[task._prepareIndex(index)] = f
end

function task.setOnce(index, f)
    index = task._prepareIndex(index)
    callbacks[index] = function()
        f()
        callbacks[index] = nil
    end
end

function task.iterator()
    return pairs(callbacks)
end

return task