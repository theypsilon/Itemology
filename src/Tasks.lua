local Job = require 'Job'

local Tasks = class.Tasks()
function Tasks:_init() self.callbacks = {} end

function Tasks:_prepareIndex(index) return index end

function Tasks:set(index, f, delay)
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

function Tasks:iterator( ) return     pairs(self.callbacks) end
function Tasks:__call(...) for _,t in pairs(self.callbacks) do t(...) end end

function Tasks:new() return Tasks() end

local  globalTasks = Tasks()
return globalTasks