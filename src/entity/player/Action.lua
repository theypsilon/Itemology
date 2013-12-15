local Tasks, Scenes, Text, Data, Job, Physics; import()
local Bullet; import 'entity.particle'

local abs = math.abs

local Player = {}

function Player:setRun()
    if self.keyRun then
        local _, shooting = self.shooting()
        self.shooting = shooting or Job.cron(10, nothing, 10)
    else
        if self.shooting == nothing then return end
        local shooting = self.shooting
        self.shooting  = function()
            if shooting() then self.shooting = nothing end
            return nil, shooting
        end
    end
end

function Player:moveShoot()
    if self.shooting() then self:triggerBullet{self.lookLeft and -1 or 1, 0} end
end

function Player:triggerBullet(dir)
    local scalar = 400
    local speed = {dir[1] * scalar, dir[2] * scalar}

    self.level: add(
                    Bullet(
                        self.level, Data.animation.Bullet, self, speed, self))
end

return Player