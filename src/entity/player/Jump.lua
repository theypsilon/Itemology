local Tasks, Scenes, Text, Data, Job, Physics; import()

local abs = math.abs

local Player = {}

function Player:setDoubleJump()
    if  self.tasks.callbacks.jumping or 
        self.walltouch or
        not self:onGround() then return end

    local jump
    self.tasks:set('jumping', Job.interval(function(c)
        if not self.keyJump then return c:next() end
        self:doJump(c.ticks + 1)
    end, 0, #self.moveDef.jumpImp)):after(function(c)
        self.setJump = function() jump = true end
        c:fallthrough()
    end):after(function(c)

        if self:onGround() then return c:fallthrough() end

        if self:moveWallJump(true) then jump = nil end

        if jump then self:doDoubleJump(); c:next() end

    end):after(function(c)
        if self:onGround() then 
            self.setJump = self.setDoubleJump
            return c:next() 
        end
        self:moveWallJump(true)
    end)
end

function Player:setSingleJump()
    if  self.tasks.callbacks.jumping or 
        self.walltouch or
        not self:onGround() then return end

    self.tasks:set('jumping', Job.interval(function(c)
        if not self.keyJump then return c:next() end
        self:doJump(c.ticks + 1)
    end, 0, #self.moveDef.jumpImp)) :after(function(c)
        if self:onGround()  then return c:next() end
        self:moveWallJump(true)
    end)
end

function Player:setSpaceJump()
    if not self:usePower('sjump') then return end

    if  self.tasks.callbacks.jumping or 
        self.walltouch or
        not self:onGround() then return end

    local gravity = self.body:getGravityScale()
    self.body:setGravityScale(0.7)

    self.moveVertical = nothing

    self.tasks:set('jumping', Job.interval(function(c)
        if not self.keyJump then return c:next() end
        self:doJump(c.ticks + 1)
    end, 0, #self.moveDef.jumpImp)) :after(function(c)
        if self:onGround()  then 
            self.moveVertical = nil
            self.body:setGravityScale(gravity)
            return c:next() 
        end
        if self.vy > 100 then self.body:setLinearVelocity(self.vx, 100) end
        self:moveWallJump(true)
    end)
end

local function prepare_touch(touch)
    return touch == 0 and 0 or touch / abs(touch)
end

function Player:moveWallJump(fromJumping)
    if self:onGround() then self.lastwalljump = false end

    if not fromJumping and self.tasks.callbacks.jumping then return end
    if                 self.tasks.callbacks.walljumping then return end

    local vy, dx = self.vy, self.dx

    local initial_touch = prepare_touch(self.touch)

    if  initial_touch ~= 0 and 
        initial_touch == dx and 
        self.lastwalljump ~= initial_touch and
        not self:onGround()
    then

        local prevSetJump = self.setJump 

        local ws = self.moveDef.wallSlidingSpeed

        local jump
        local function setWallJump() jump = true end
        self.setJump = setWallJump

        self.tasks:set('walljumping', Job.chain(function(c)
            local touch = prepare_touch(self.touch)

            if touch ~= initial_touch or self:onGround() then return c:next() end

            if jump then
                local def = self.moveDef
                self.body:setLinearVelocity(
                    -touch * ( def.wjumpVxPlus + abs(dx) * def.wjumpVxBase ),
                    -def.wjumpUp
                )
                self.lastwalljump = touch
                return c:next()
            end

            if self.vy > ws then self.body:setLinearVelocity(self.vx, ws) end
        end)):after(function(c)
            if self.setJump ~= self.jumpBackup then self.setJump = prevSetJump end
            c:next()
        end)
        return true
    end
end

function Player:onGround()
    return self.groundCount ~= 0
end

function Player:doJump(step)
    local jump = self.moveDef.jumpImp
    self.body:applyLinearImpulse(0, -jump[step])
end

function Player:doFalconJump()
    if not self:usePower('fjump') then return end

    self.lastwalljump = false

    local vx, vy = self.body:getLinearVelocity()
    local dx, dy = vx > 0 and 1 or -1, vy > 0 and 1 or -1

    if abs(vx) < 100 then vx = 0 
    else vx = vx > 0 and 1 or -1 end
    if abs(vy) < 100 then vy = 0
    else vy = vy > 0 and 1 or -1 end

    local gravity = self.body:getGravityScale()

    self.body:setLinearVelocity(vx*3, vy*3)
    self.body:setGravityScale(0)
    self.move = nothing

    local x, y = 0, 0

    self.tasks:set('djumping', Job.interval(function()
        local dx, dy = self.dx, -1 * self.dir.up + self.dir.down
        x, y = x + dx, y + dy
    end, 0, 60)):after(function(c)
        if abs(x) < 10 and abs(y) < 10 then return c:next(5) end
        self.body:setLinearVelocity(x*1.3, y*1.3)
        c:next()
    end):after(Job.interval(nil, 0, 60)):after(function(c)
        self.move = nil
        self.body:setGravityScale(gravity)
        c:next()
    end)
end


function Player:doKirbyJump()
    if not self:usePower('kjump') then return end

    self.lastwalljump = false 

    self:doStandardDoubleJump(true)

    local gravity = self.body:getGravityScale()

    local step = 0
    self.tasks:set('djumping', Job.chain(function(c)
        step = step + 1
        if not self.keyJump then c:next() end
        if self:onGround() or step > 200 then c:exit() end
    end)):after(function(c)
        step = step + 1
        if self.keyJump then
            if c.last <= step then 
                self:doStandardDoubleJump(true)
                c.last = step + 20 
            end
            c:next(1)
        end
        if self:onGround() or step > 200 then c:exit() end
    end).last = 20
end

function Player:doTeleportJump()
    if not self:usePower('tjump') then return end

    self.lastwalljump = false

    local vx, vy, dx, dy = self.vx, self.vy, self.dx, self.dy
    local vdx, vdy = vx > 0 and 1 or vx < 0 and -1 or dx,
                     vy > 0 and 1 or vy < 0 and -1 or dy

    local x, y = dx ~= -vdx and dx or 0, dy ~= -vdy and dy or 0

    if y == 1 then y = 0 end

    if x == 0 and y == 0 then y = -1 end

    if x ~= 0 and y ~= 0 then
        x, y = x * 65, y * 65
    else
        x, y = x * 110, y * 110
    end

    self.pos:set(self.x + x, self.y + y)

    self.tasks:set('djumping', Job.chain(function(c)
        if self:onGround() then c:next() end
    end))
end

local function movePeach(self, dt)
    dt = 1 / (dt * self.moveDef.timeFactor)

    self:moveLateral(dt, self:calcMainForces(dt))    
end

function Player:doPeachJump()
    if not self:usePower('pjump') then return end

    self.lastwalljump = false

    local gravity = self.body:getGravityScale()

    self.body:setGravityScale(0)
    self.body:setLinearVelocity(self.vx, 0)
    self.move = movePeach

    self.tasks:set('djumping', Job.interval(function(c)
        if not self.keyJump then c:next() end
    end, 0, 60)):after(function(c)
        if self.move == movePeach then
            self.move = nil
            self.body:setGravityScale(gravity)
        end
        if self:onGround()               then return c:next() end
        if self.keyJump and c.ticks < 59 then
            gravity = self.body:getGravityScale()
            self.body:setGravityScale(0)
            self.body:setLinearVelocity(self.vx, 0)
            self.move = movePeach
            c:next(1)  
        end
    end)
end

function Player:doDixieJump()
    if not self:usePower('xjump') then return end

    self.lastwalljump = false

    local gravity = self.body:getGravityScale()

    self.body:setGravityScale(0.3 * gravity)
    self.body:setLinearVelocity(self.vx, 0)
    self.move = movePeach

    self.tasks:set('djumping', Job.chain(function(c)
        if not self.keyJump then c:next() end
        if self:onGround() then c:fallthrough() end

        if self.vy > 30 then self.body:setLinearVelocity(self.vx, 30) end
    end)):after(function(c)
        if self.move == movePeach then
            self.move = nil
            self.body:setGravityScale(gravity)
        end
        if self:onGround()               then return c:next() end
    end)
end

function Player:doStandardDoubleJump(free)
    if not free and not self:usePower('djump') then return end
    if not free then self.lastwalljump = false end
    
    local def = self.moveDef

    local dx   = -1*self.dir.left + self.dir.right
    local vx, vy = self.body:getLinearVelocity()
    local vx = dx*abs(vx)
    if vx > def.djumpMaxVx then vx = def.djumpMaxVx end
    self.body:setLinearVelocity(vx, -def.djumpUp)
end

return Player