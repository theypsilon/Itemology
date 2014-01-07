local Job; import()

local Tasks = class()
function Tasks:_init(chains)
    self.callbacks = {} 
    if chains then
        local proxy = {}
        local is_chain = Job.class.is
        setmetatable(self.callbacks, {
            __newindex = function(t, k, v) 
                proxy[k] = is_chain(v) and v or Job.chain(v)
            end,
            __index    = function(t, k) 
                return proxy[k] 
            end
        })
    end
end

function Tasks:_prepareIndex(index) return index end

function Tasks:set(index, f, delay)
    assert(is_callable(f))
    assert(not delay or is_positive(delay))
    index = Tasks:_prepareIndex(index)
    local callbacks = self.calling and self.calling or self.callbacks
    callbacks[index] = delay and Job.cron(delay, f) or f
    return callbacks[index]
end

function Tasks:unset(index)
    local  task = self.callbacks[index]
    assert(task, 'cant unset no task')
    self.callbacks[index] = nil
    return task
end

function Tasks:once(index, f, delay)
    index = Tasks:_prepareIndex(index and index or (#self.callbacks + 1))
    local final = function(...)
        self.callbacks[index] = nil
        return true, f(...)
    end
    if delay and delay > 0 then
        self.callbacks[index] = function() 
            delay = delay - 1 
            if delay == 0 then self.callbacks[index] = final end
            return false, nil
        end
    else
        self.callbacks[index] = final
    end

    return self.callbacks[index]
end

function Tasks:__call() 
    local cbs = self.callbacks
    self.calling = {}
    for k, v in pairs(cbs) do 
        v()
        if is_table(v) and v.finished then cbs[k] = nil end
    end 
    for k, v in pairs(self.calling) do cbs[k] = v end
    self.calling = nil
end

return Tasks