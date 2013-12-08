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
        function() self.keyJump = true end, 
        function() self.keyJump = false; self:resetJump() end)

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
    self.power = {djump = 0, shoot = 0}
    Text:debug(self.power, 'djump')
end

return Player