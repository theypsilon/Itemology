local Tasks, Scenes, Text, Data, Job, Physics; import()
local Bullet; import 'entity.particle'

local abs = math.abs

local Player = {}

function Player:setAction()
    if self.keyRun then

        if self.tasks.callbacks.action then return end

        self.tasks:set('action', Job.chain(Job.cron(10, function(c)
            if self.keyRun then 
                self:triggerBullet{self.lookLeft and -1 or 1, 0}
            else 
                c:exit()
            end
        end, 10)))
    end
end

function Player:triggerBullet(dir, scalar)
    scalar = scalar or 400
    local speed = {dir[1] * scalar, dir[2] * scalar}

    self.level: add(
                    Bullet(
                        self.level, Data.animation.Bullet, self, speed, self))
end

return Player