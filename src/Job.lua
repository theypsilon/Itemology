local Job = {}

local Chain = class()
function Chain:_init(f) 
    assert(is_callable(f))
    self.job = f 
end

function Chain:finish(fallthrough) 
    self.finished    = true
    self.fallthrough = fallthrough 
end

function Chain:BREAK() 
    self.finished = true
    self.next = nil 
end

function Chain:__call()
    local  ret = self.job(self)
    if self.finished then 
        if self.next and #self.next > 0 then 
            self.job  = table.remove(self.next, 1)
            self.finished = nil
            if  self.fallthrough then
                self.fallthrough = nil
                return self:__call()
            end
        else self.job = nothing end
    end
    return ret
end

function Chain:after  (f)
    assert(is_callable(f))
    self.next = self.next or {}
    self.next[#self.next + 1] = f
    return self
end

function Chain.is(o) return o._name == 'Chain' end

Job.chain = Chain

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
    assert(is_positive(final  ) or is_nil(final))

    local run = function(c, ...)
        local ret = f(c, ...)
        c.ticks = c.ticks + 1
        if final and c.ticks >= final then return c:finish() end
        return ret
    end

    if initial > 0 then
        run = Chain(function(c)
            c.ticks = c.ticks + 1
            if c.ticks >= initial then c:finish() end
        end):after(run)
    else
        run = Chain(run)
    end

    run.ticks = 0
    return run
end

return Job