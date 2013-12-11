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
    self.callbacks[index] = delay and Job.cron(delay, f) or f
    return self.callbacks[index]
end

function Tasks:once(index, f, delay)
    index = Tasks:_prepareIndex(index)
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

function Tasks:__call(...) 
    local cbs = self.callbacks
    for k, v in pairs(cbs) do 
        v(...)
        if is_object(cbs[k]) and cbs[k].finished then cbs[k] = nil end
    end 
end

return Tasks