local Input, Text, Job; import()

local Player = {}

function Player:_setInput()

    -- walk
    self.dir = iter(Input.checkAction{'left', 'right', 'up', 'down'})
        :map(function(k, v) return k, v and 1 or 0 end):tomap()

    for k,_ in pairs(self.dir) do
        Input.bindAction(k, function() self.dir[k] = 1 end, function() self.dir[k] = 0 end)
    end

    -- jump
    Input.bindAction('b2', 
        function() self.keyJump = true; self:setJump() end, 
        function() self.keyJump = false end)

    -- run
    self.keyRun = Input.checkAction('b1')
    Input.bindAction('b1', 
        function() self.keyRun = true;  self:setAction() end, 
        function() self.keyRun = false; self:setAction() end)

    -- shoot
    Input.bindAction('b3', 
        function() self.special = true;  self:setSpecial() end,
        function() self.special = false; self:setSpecial() end)

    -- plus
    Input.bindAction('b4', function() self.keyPlus = true  end,
                           function() self.keyPlus = false end)

    -- select jump
    Input.bindAction('s1', function() self:selectNextJumpPower() end)

    -- debug - print location
    Input.bindAction('r', function() 
        self.tasks:once('wallhack', function()  self:wallhack_on ()  end)
    end, function() 
        self.tasks:once('wallhack', function()  self:wallhack_off()  end)
    end)    
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

local power_type = {
    djump  = {'pow_jump', 'd', 'doStandardDoubleJump'},
    pjump  = {'pow_jump', 'd', 'doPeachJump'},
    xjump  = {'pow_jump', 'd', 'doDixieJump'},
    fjump  = {'pow_jump', 'd', 'doFalconJump'},
    tjump  = {'pow_jump', 'd', 'doTeleportJump'},
    kjump  = {'pow_jump', 'd', 'doKirbyJump'},
    sjump  = {'pow_jump', 's', 'setSpaceJump'},
    nojump = {'none'    , 'd', 'doStandardDoubleJump'}
}

local setupJump

function Player:_setPower()
    setupJump(self, 'nojump')
    self.setSpecial = self.setYoshiSpecial
    self.power = iter(power_type)
        :filter(function(k, v) return v[1] == 'pow_jump' end)
        :map(function(k, v) return k, 0 end)
        :tomap()

    self.pow_jump, self.pow_action, self.pow_special = false, false, false

    for k,v in pairs(power_type) do
        if v[1] == 'pow_jump' then 
            Text:debug(self.power, k, nil, nil, function(v)
                return v ~= 0 and v ~= nil
            end)
        end
    end
    Text:debug(self, 'pow_jump')
end

function Player:setupPower(power)
    local power_nature = power_type[power][1]
    if power_nature == 'pow_jump' then
        setupJump(self, power)
    end
end

function Player:findPower(o)
    local ptype = power_type[o.power][1]
    if ptype and not self[ptype] then 
        self[ptype]   = o.power 
        self:setupPower(o.power)
    end
    if o.charges == 'huge' or o.charges == 'inf'then o.charges = math.huge end
    self.power[o.power] = o.charges + (o.add and self.power[o.power] or 0)
end

function setupJump(self, ptype)

    ptype = power_type[ptype]

    local jump_cat, func_name = ptype[2], ptype[3]

    if      jump_cat == 'd'  then

        self.setJump = self.setDoubleJump
        self.doDoubleJump = self[func_name]

    elseif  jump_cat == 's'  then

        self.setJump = self[func_name]

    else error 'what do we have here??' end
end

function Player:selectNextJumpPower()
    local powers = iter(self.power)
        :filter(function(k, v) return v > 0 end)
        :totable()

    if power_type[self.pow_jump] and power_type[self.pow_jump][2] == 's' then
        local singles = iter(power_type)
        :filter(function(k, v) return v[1] == 'pow_jump' and v[2] == 's' end)

        if table.count(powers) == table.count(singles) then
            self.pow_jump = false
            setupJump(self, 'nojump')
            return 
        end
    end

    if table.empty(powers) then
        self.pow_jump = false
        setupJump(self, 'nojump')
        return 
    end

    local cur = self.pow_jump
    local key = cur and table.flip(powers)[cur] or 1
    self.pow_jump = key == #powers and powers[1] or powers[key + 1]
    self:setupPower(self.pow_jump)
end

return Player