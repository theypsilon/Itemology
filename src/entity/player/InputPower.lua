local Input, Text, Job; import()

local Player = {}

function Player:_setInput()

    -- walk
    self.dir = table.map(
        Input.checkAction{'left', 'right', 'up', 'down'}, 
            function(v) return v and 1 or 0 end)

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
    djump  = {'pow_jump', 'd', 'doStandardDoubleJump'},
    pjump  = {'pow_jump', 'd', 'doPeachJump'},
    xjump  = {'pow_jump', 'd', 'doDixieJump'},
    fjump  = {'pow_jump', 'd', 'doFalconJump'},
    tjump  = {'pow_jump', 'd', 'doTeleportJump'},
    kjump  = {'pow_jump', 'd', 'doKirbyJump'},
    sjump  = {'pow_jump', 's', 'setSpaceJump'},
    nojump = {'none'    , 's', 'setDoubleJump'}
}

local function setSingleJump(self, name)
    self.tasks:set('singlejump', Job.chain(function(c)
        if self.setJump == self.setDoubleJump then
            self.setJump = self[name]
            c:exit()
        end
    end))
end

local setup = {
    djump = function(self) setupJump(self, 'doStandardDoubleJump') end,
    pjump = function(self) setupJump(self, 'doPeachJump'         ) end,
    xjump = function(self) setupJump(self, 'doDixieJump'         ) end,
    fjump = function(self) setupJump(self, 'doFalconJump'        ) end,
    tjump = function(self) setupJump(self, 'doTeleportJump'      ) end,
    kjump = function(self) setupJump(self, 'doKirbyJump'         ) end,
    sjump = function(self) setSingleJump(self, 'setSpaceJump')  end,
   nojump = function(self) self.setJump = self.setDoubleJump end
}

local function setupJump(self, type)
    if not table.empty(table.filter(power_type, 
        function(v) return self[v[3]] == self.setJump end)) 
    then
        self.setJump = self.setDoubleJump
    end

    local jump_cat = power_type[type][2]

    if jump_cat == 'd' then
        self.doDoubleJump = self[power_type[type][3]]
    elseif jump_cat == 's' then
        self.setJump = self[power_type[type][3]]
    end

end

function Player:_setPower()
    self.setSpecial = self.setYoshiSpecial
    self.power = table.map( table.filter(power_type, 
                                function(v) return v[1] == 'pow_jump' end), 
                                    function(v, k) return 0, k end)
    self.pow_jump = false
    for k,_ in pairs(power_type) do
        Text:debug(self.power, k)
    end
    Text:debug(self, 'pow_jump')
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

function Player:setupPower(power)
    setupJump(self, power)
end

function Player:selectNextJumpPower()
    local powers = table.keys(
                        table.filter(self.power, 
                            function(v) return v > 0 end))

    if power_type[self.pow_jump] and power_type[self.pow_jump][2] == 's' then
        local singles = table.filter(power_type, 
            function(v) return v[1] == 'pow_jump' and v[2] == 's' end)

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