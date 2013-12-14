local Job = {}

local Chain = class()
function Chain:_init(f, key) 
    assert(is_callable(f))
    key          = key and key or 1
    self.job     = f
    self.pending = {[key] = f} 
    self.cur     = is_number(key) and key or 0
end

function Chain:exit() 
    self.finished = true
    self.fall     = nil 
    self.pending  = nil
end

local function get_continue(self)
    return self.cur + 1
end

function Chain:next(key, fall) 
    assert(not key or self.pending[key], 'wrong state: ' .. tostring(key))
    self.finished = true
    self.continue = key and key or get_continue(self)
    self.fall     = fall
end

function Chain:fallthrough(key) self:next(key, true) end
function Chain:free(key)     self.pending[key] = nil end

function Chain:__call()
    local  ret = self.job(self)
    if self.finished then 
        if self.pending then
            
            if is_number(self.continue) then self.cur = self.continue end

            self.job  = self.pending[self.continue]

            if not self.job then self.job = nothing; return end

            self.finished = nil
            if  self.fall then
                self.fall = nil
                return self:__call()
            end
        else self.job = nothing end
    end
    return ret
end

local function merge(self, c, key)
    if c.job then self.pending[key and key or (#self.pending + 1)] = c.job end

    if c.pending then
        for k,v in pairs(c.pending) do 
            if is_number(k) then k = #self.pending + 1 end
            assert(is_nil(self.pending[k]), 'cant merge two chains. key: '..k)
            self.pending[k] = v
        end
    end

    return self
end

function Chain:after  (f, key)
    self.pending = self.pending or {}
    if is_object(f) and f._name == 'Chain' then return merge(self, f, key) end

    assert(is_callable(f))
    self.pending[key and key or (#self.pending + 1)] = f

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
    assert(is_positive(every),every)
    assert(is_callable(f),f)
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

function Job.interval(f, initial, final, key)
    assert(is_callable(f) or is_nil(f))
    assert(is_positive(initial))
    assert(is_positive(final  ) or is_nil(final))

    local ticks = 0

    local run = function(c, ...)
        c.ticks = ticks
        local ret = f and f(c, ...)
        ticks   = ticks + 1
        if final and ticks >= final then return c:next() end
        return ret
    end

    if initial > 0 then
        run = Chain(function(c)
            ticks = ticks + 1
            if ticks >= initial then c:next() end
        end, key):after(run)
    else
        run = Chain(run, key)
    end

    return run
end

return Job