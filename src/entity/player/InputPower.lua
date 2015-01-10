local Data; import()

local Player = {}

function Player:_setInput()

    local config = Data.key.Player1

    local action_map = {
        left    = true,
        right   = true,
        up      = true,
        down    = true,
        run     = true,
        jump    = false,
        special = false,
        plus    = false,
        select  = false,
        hack    = false
    }

    local actions = {}
    -- for action, precheck in pairs(action_map) do
    --     local  key  = config[action]
    --     assert(key ~= nil)
    --     Input.bindAction(key, actions, action)
    --     if precheck then 
    --         actions[action] = Input.checkAction(key) 
    --     end
    -- end

    -- Input.bindAction(config.select , function() self:selectNextJumpPower() end)
    -- Input.bindAction(config.hack   , function() 
    --     self.tasks:once('wallhack' , function()  self:wallhack_on ()  end)
    -- end, function() 
    --     self.tasks:once('wallhack' , function()  self:wallhack_off()  end)
    -- end)

    self.action    = actions
    self.keyconfig = config
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
    djump  = {'pow_jump', 'double_jump', 'DoubleStandardJump'},
    pjump  = {'pow_jump', 'double_jump', 'PeachJump'},
    xjump  = {'pow_jump', 'double_jump', 'DixieJump'},
    fjump  = {'pow_jump', 'double_jump', 'FalconJump'},
    tjump  = {'pow_jump', 'double_jump', 'TeleportJump'},
    kjump  = {'pow_jump', 'double_jump', 'KirbyJump'},
    sjump  = {'pow_jump', 'jump', 'SpaceJump'},
    nojump = {'none'    , 'double_jump', 'DoubleStandardJump'}
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

    self.jumpResource[power_type[o.power][3]] = self.power[o.power]
end

function setupJump(self, ptype)

    ptype = power_type[ptype]

    local jump_cat, func_name = ptype[2], ptype[3]

    assert(self.jumpSelector[jump_cat], 'what?? '..jump_cat)
    self.jumpSelector[jump_cat] = func_name
end

function Player:selectNextJumpPower()
    local powers = iter(self.power)
        :filter(function(k, v) return v > 0 end)
        :totable()

    if power_type[self.pow_jump] and power_type[self.pow_jump][2] == 'jump' then
        local singles = iter(power_type)
        :filter(function(k, v) return v[1] == 'pow_jump' and v[2] == 'jump' end)

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