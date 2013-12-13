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

    -- shoot
    Input.bindAction('b3', function()

    end)

    -- select jump
    Input.bindAction('s1', function() self:selectNextJumpPower() end)

    -- debug - print location
    Input.bindAction('r', function() 
        self.tasks:once('wallhack', function()  self:wallhack_on ()  end)
    end, function() 
        self.tasks:once('wallhack', function()  self:wallhack_off()  end)
    end)    
end

local power_type = {
    djump = 'pow_jump',
    pjump = 'pow_jump',
    xjump = 'pow_jump',
    fjump = 'pow_jump',
    tjump = 'pow_jump',
    kjump = 'pow_jump',
    sjump = 'pow_jump',
}

local setup = {
    djump = function(self) self.doDoubleJump = self.doStandardDoubleJump; self.setJump = self.setDoubleJump end,
    pjump = function(self) self.doDoubleJump = self.doPeachJump         ; self.setJump = self.setDoubleJump end,
    xjump = function(self) self.doDoubleJump = self.doDixieJump         ; self.setJump = self.setDoubleJump end,
    fjump = function(self) self.doDoubleJump = self.doFalconJump        ; self.setJump = self.setDoubleJump end,
    tjump = function(self) self.doDoubleJump = self.doTeleportJump      ; self.setJump = self.setDoubleJump end,
    kjump = function(self) self.doDoubleJump = self.doKirbyJump         ; self.setJump = self.setDoubleJump end,
    sjump = function(self) setSingleJump(self, 'setSpaceJump')  end,
   nojump = function(self) self.setJump = self.setDoubleJump end
}

function Player:_setPower()
    self.power = table.map(power_type, function(v, k) return 0, k end)
    self.pow_jump = false
    for k,_ in pairs(power_type) do
        Text:debug(self.power, k)
    end
    Text:debug(self, 'pow_jump')
end

local function setSingleJump(self, name)
    self.tasks:set('singlejump', Job.chain(function(c)
        if self.setJump == self.setDoubleJump then
            self.setJump = self[name]
            c:exit()
        end
    end))
end

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
        self.pow_jump = false
        setup.nojump(self)
        return 
    end

    local cur = self.pow_jump
    local key = cur and table.flip(powers)[cur] or 1
    self.pow_jump = key == #powers and powers[1] or powers[key + 1]
    self:setupPower(self.pow_jump)
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