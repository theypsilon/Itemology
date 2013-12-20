local Job = {}

local Chain = class()
function Chain:_init(f, key) 
    assert(is_callable(f))
    key        = key and key or 1
    self.job   = f
    self.state = {[key] = f} 
    self.cur   = is_number(key) and key or 0
end

local update_chain

function Chain:exit() 
    self.finished = true
    self.fall     = true 
    self.state    = nil
    if not self.running then update_chain(self) end
end

function Chain:next(key, fall) 
    assert(not key or self.state[key], 'wrong state: ' .. tostring(key))
    self.finished = true
    self.continue = key and key or (self.cur + 1)
    self.fall     = fall
    if not self.running then update_chain(self) end
end

function Chain:fallthrough(key) return self:next(key, true) end

function Chain:free(key) 
    if is_table(key) then for _, k in pairs(key) do self:free(k) end return end
    self.state[key] = nil
end

function Chain:__call()
    self.running = true
    local  ret   = self.job(self)
    self.running = nil
    update_chain(self)
    return ret
end

local function set_last_job(self)
    if self.finaljob then 
        self.job      = self.finaljob
        self.finaljob = nil
        self.finished = nil
    else 
        self.job = nothing 
    end
end

function update_chain(self)
    if self.finished then 
        if self.state then
            
            if is_number(self.continue) then self.cur = self.continue end

            self.job  = self.state[self.continue]

            if not self.job then set_last_job(self) else self.finished = nil end

            if self.finished then return end

            if  self.fall then
                self.fall = nil
                return self:__call()
            end
        else set_last_job(self) end
    end
end

local merge

function Chain:after(f, key)
    if is_table(f) and f.state then return merge(self, f) end

    assert(is_callable(f))
    self.state[key and key or (#self.state + 1)] = f

    return self
end

function merge(self, c)
    assert(c.state)

    for k,v in pairs(c.state) do 
        if is_number(k) then k = #self.state + 1 end
        assert(is_nil(self.state[k]), 'cant merge two chains. key: '..k)
        assert(is_callable(v))
        self.state[k] = v
    end

    return self
end

function Chain:with (key, f)
    assert(is_string(key), 'wrong key')
    return self:after(f, key)
end

function Chain:finally(f)
    assert(is_callable(f))
    assert(not self.finaljob)
    self.finaljob = function(c) c:next() return f() end
end

function Chain.is(o) return getmetatable(o) == Chain end

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

function Job.bistate(semicycles)
    local i, semicycles = 0, semicycles or 2
    assert(is_positive(semicycles), tostring(semicycles))
    return function(state) --assert(is_boolean(state), type(state))
        if state == (i %2 == 1) then i = i + 1 end
        return i == semicycles
    end
end

return Job