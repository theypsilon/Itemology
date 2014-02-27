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

local f = require 'data.fixture.Filters'

function Player:doSpecialShot(dirx, diry)
    self:triggerBullet({dirx, diry}, nil, function(bullet, impact, a)
        if impact.structure then
            local nx, ny = a:getContactNormal()
            local x ,  y = bullet.pos:get()

            local hit, hx, hy = Physics.world:getRayCast(
                x, y, 
                bullet.speed[1] + x, 
                bullet.speed[2] + y
            )

            if hit then x, y = hx, hy end

            local body
            local walls = {}

            self.tasks:once('creating_shadow', function()

                local fixtures = {}
                for i = -24, 24, 12 do
                    walls   [#fixtures + 1] = true
                    fixtures[#fixtures + 1] = {
                        option = 'circle',
                        args = {ny*i, nx*i, 2},
                        sensor = true,
                    }
                end

                for i = -18, 18, 12 do
                    local x = nx == 0 and 0 or nx * 10
                    local y = ny == 0 and 0 or ny * 10
                    fixtures[#fixtures + 1] = {
                        option = 'circle',
                        args = {ny*i + x, nx*i + y, 5},
                        sensor = true,
                    }
                end

                body = Physics:registerBody{
                    option = 'dynamic',
                    fixtures = fixtures,
                    x = x,
                    y = y,
                    fixedRotation = true,
                    bullet = true,
                    gravityScale = 0,

                    fixCategory = f.C_FRIEND_SHOOT,
                    fixMask     = f.M_FRIEND_SHOOT
                }

                for _,fix in pairs(body.fixtures) do
                    fix:setCollisionHandler(function(p, fa, fb, a)
                        if fb:getBody() == impact then fix.touched = true end
                    end, MOAIBox2DArbiter.BEGIN)
                end

            end)

            self.tasks:once('delete_shadow', function()
                local touched = true
                for k, fix in pairs(body.fixtures) do
                    if (walls[k] and not fix.touched)
                    or (fix.touched and not walls[k]) then touched = false end
                end
                if touched then self:makePortal(x, y, nx, ny) end
                body:clear()
            end, 10)
        end
        return true
    end)
end

function Player:makePortal(x, y, nx, ny)
    nx, ny = math.abs(nx), math.abs(ny)

    local xo, yo = x - ny * 24, y - nx * 24
    local x1, y1 =     ny * 48,     nx * 48

    local offset = 0

    print 'portal!!'

    if self.portal then
        self.portal = nil
    else
        self.portal = {xo, yo, x1, y1}
    end

    Physics:registerBody{
        option = 'dynamic',
        fixtures = {{
            option = 'rect',
            args = {-offset, -offset, x1 + offset, y1 + offset},
            sensor = true
        }},
        x = xo,
        y = yo,
        fixedRotation = true,
        bullet = true,
        gravityScale = 0,

        fixCategory = f.C_FRIEND_SHOOT,
        fixMask     = f.M_FRIEND_SHOOT
    }
end

return Player