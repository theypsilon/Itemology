local Input, Text, Job; import()

local Player = {}

function Player:_setInput()

    -- walk
    self.dir = {left = 0, right = 0, up = 0, down = 0}
    for k,_ in pairs(self.dir) do
        Input.bindAction(k, function() self.dir[k] = 1 end, function() self.dir[k] = 0 end)
    end

    -- jump
    Input.bindAction('b2', 
        function() self.keyJump = true; self:setJump() end, 
        function() self.keyJump = false end)

    -- run
    Input.bindAction('b1', function() 
        self.keyRun = true 
        local _, shooting = self.shooting()
        self.shooting = shooting or Job.cron(10, nothing, 10)
    end, function() 
        self.keyRun = false
        if self.shooting == nothing then return end
        local shooting = self.shooting
        self.shooting  = function()
            if shooting() then self.shooting = nothing end
            return nil, shooting
        end
    end)

    Input.bindAction('shift', function() self:selectNextJumpPower() end)

    -- debug - print location
    Input.bindAction('r', function() 
        self.tasks:once('wallhack', function() 
            self:wallhack_on ()
            print(self.pos:get())
        end)
    end, function() 
        self.tasks:once('wallhack', function() 
            self:wallhack_off() 
        end)
    end)    
end

function Player:_setPower()
    self.power = {djump = 0, pjump = 0, fjump = 0, xjump = 0}
    self.power_djump = false
    Text:debug(self.power, 'djump')
    Text:debug(self.power, 'pjump')
    Text:debug(self.power, 'fjump')
    Text:debug(self.power, 'xjump')
    Text:debug(self, 'power_djump')
end

local setup = {
    djump = function(self) self.doDoubleJump = self.doStandardDoubleJump end,
    pjump = function(self) self.doDoubleJump = self.doPeachJump          end,
    xjump = function(self) self.doDoubleJump = self.doDixieJump          end,
    fjump = function(self) self.doDoubleJump = self.doFalconJump         end,
}

local power_type = {
    djump = 'power_djump',
    pjump = 'power_djump',
    xjump = 'power_djump',
    fjump = 'power_djump',
}

function Player:findPower(o)
    local ptype = power_type[o.power]
    if ptype and not self[ptype] then 
        self[ptype]   = o.power 
        self:setupPower(o.power)
    end
    self.power[o.power] = o.charges + (o.add and self.power[o.power] or 0)
end

function Player:setupPower(power) 
    setup[power](self) 
end

function Player:selectNextJumpPower()
    local powers = table.keys(
                        table.filter(self.power, 
                            function(v) return v > 0 end))

    if table.empty(powers) then 
        self.power_djump = false    
        return 
    end

    local cur = self.power_djump
    local key = cur and table.flip(powers)[cur] or 1
    self.power_djump = key == #powers and powers[1] or powers[key + 1]
    self:setupPower(self.power_djump)
end

function Player:usePower(key)
    local  use = self.power[key]
    if not use or use == 0 then  return false end
    if use > 0 then 
        use = use - 1
        self.power[key] = use
        if use == 0 then self:selectNextJumpPower() end
    end
    return true
end

return Player