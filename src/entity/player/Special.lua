local Tasks, Animation, Scenes, Text, Data, Job, Physics; import()
local Bullet; import 'entity.particle'

local abs = math.abs

local Player = {}

function Player:setYoshiSpecial()
    if not self.special then return end
    if  self.tasks.callbacks.special or 
        self.tasks.callbacks.jumping or
        self.tasks.callbacks.walljumping or
        self.tasks.callbacks.djumping then return end

    local a = Animation(Data.animation.Cursor)

    local prop = a.prop

    local dist = 50

    local cos, sin, rad = math.cos, math.sin, math.rad

    local look = self.lookLeft == true and -1 or 1

    local jump, wjump, shoot = self.setJump, self.moveFalling, self.setAction
    self.setJump     = self.setSingleJump
    self.moveFalling = nothing
    self.setAction   = nothing

    local bShoot = 0



    local angle, dir = -20, 1.8
    self.tasks:set('special', Job.chain(function(c)
        local x, y = self.x, self.y

        angle = angle + dir
        
        if  self.dir.down == 1 or 
            self.removed       or 
            self:isWounded() then return c:exit() end

        --if self.keyRun        then angle =  0 end
        if self.dir.up   == 1 then angle = 90 end

        if self.special == (bShoot %2 == 1) then bShoot = bShoot + 1 end
        if bShoot == 2 then c:next() end

        if angle < -20 or angle > 90 then dir = -dir end

        local radians = rad(angle)
        prop:setLoc(x + look * cos(radians) * dist, y - sin(radians) * dist)
        a:next()
    end)):after(function(c)
        local radians = rad(angle)

        self:doSpecialShot(look * cos(radians), -sin(radians))

        c:next()
    end):finally(function()
        self.setJump     = jump
        self.moveFalling = wjump
        self.setAction   = shoot
        prop:clear() 
    end)
end

function Player:doSpecialShot(dirx, diry)
    self:triggerBullet{dirx, diry}
end

return Player