local Tasks, Scenes, Text, Data, Job, Physics; import()
local Bullet; import 'entity.particle'

local abs     = math.abs

local Player = {}

function Player:_setInitialMove(p)
    self.shooting     = nothing
    self.setJump      = self.setDoubleJump
    self.doDoubleJump = self.doPeachJump
    self.moveJump     = nothing
    --self.moveWallJump = nothing
    --self.moveLateral  = nothing
    --self.moveFallingDown = nothing
end

function Player:move(dt)
    dt = 1 / (dt * self.moveDef.timeFactor)

    self:moveShoot      (  )
    self:moveDoor       (  )
    self:moveWallJump   (  )
    self:moveJump       (dt)
    self:moveLateral    (dt, self:calcMainForces(dt))
    self:moveFallingDown(dt)
    
end

function Player:calcMainForces(dt)
    local vx  = self.vx
    local def = self.moveDef
    local og  = self:onGround()
    return 
        -- which forces apply on character
        og and def.ogHorForce or def.oaHorForce,
        -- if running, maxspeed is different
        ((og                          and self.keyRun) or
         (def.maxVxWalk < 0.9*abs(vx) and self.keyRun) or
          def.alwaysRun) 
        and def.maxVxRun or def.maxVxWalk

end

function Player:moveShoot()
    if self.shooting() then
        local scalar = 400
        local speed  = {self.lookLeft and -scalar or scalar, 0}
        self.level:
        add(
            Bullet(
                self.level, Data.animation.Bullet, self, speed, self))
    end
end

function Player:moveLateral(dt, force, maxVel)
    local vx, dx = self.vx, self.dx
    -- horizontal walk/run
    if dx ~= 0 then
        local vel = abs(maxVel - abs(vx))
        self.body:applyForce( dt*dx*force*vel, 0)
    end

    -- fake friction in horizontal axis
    if vx ~= 0 and (dx*vx < 0 or (dx == 0 and self:onGround())) then
        -- if fast, slowdown is weaker
        local def      = self.moveDef
        local slowdown = abs(vx) > maxVel and def.slowRun or def.slowWalk
        if abs(vx) > maxVel then slowdown = def.slowRun end

        self.body:applyForce(-dt*vx*force*slowdown, 0)
    end
end

function Player:moveFallingDown()
    local def, vy = self.moveDef, self.vy
    if def.addGravity + vy > def.maxVyFall 
    then self.body:applyLinearImpulse(0, def.maxVyFall - vy - def.addGravity)
    else self.body:applyLinearImpulse(0, def.addGravity) end
end

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

local function prepare_touch(touch)
    return touch == 0 and 0 or touch / math.abs(touch)
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
            if self.setJump == prevSetJump then self.setJump = prevSetJump end
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

    self.tasks:set('fjump', Job.interval(nil, 0, 60)):after(function(c)
        local x, y = self.dx, -1 * self.dir.up + self.dir.down
        if x == 0 and y == 0 then x, y = dx, dy end
        self.body:setLinearVelocity(x * 60, y * 60)
        c:next()
    end):after(Job.interval(nil, 0, 60)):after(function(c)
        self.move = nil
        self.body:setGravityScale(gravity)
        c:next()
    end)
end

local function movePeach(self, dt)
    dt = 1 / (dt * self.moveDef.timeFactor)

    self:moveLateral(dt, self:calcMainForces(dt))    
end

function Player:doPeachJump()
    if not self:usePower('pjump') then return end

    local gravity = self.body:getGravityScale()

    self.body:setGravityScale(0)
    self.body:setLinearVelocity(self.vx, 0)
    self.move = movePeach

    self.tasks:set('djump', Job.interval(function(c)
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

function Player:doStandardDoubleJump()
    if not self:usePower('djump') then return end
    
    local def = self.moveDef

    local dx   = -1*self.dir.left + self.dir.right
    local vx, vy = self.body:getLinearVelocity()
    local vx = dx*abs(vx)
    if vx > def.djumpMaxVx then vx = def.djumpMaxVx end
    self.body:setLinearVelocity(vx, -def.djumpUp)
end

function Player:moveDoor()
    if self.dir.up == 1 and self.door then
        if self.door.level and self.door.level ~= self.level.name then
            gTasks:once('changeMap', function() 
                Scenes.run('First', self.door, self.hp) 
            end)
        else
            local link = self.door.layer.objects[self.door.link]
            self.pos:set(link.x, link.y)
        end
        self.dir.up = 0
    end
end

local function move_on_wallhack(self)
    local dx, dy = self.dx, -1 * self.dir.up + self.dir.down
    local vel = self.keyRun and 15 or 5
    self.pos:set(self.x + dx*vel, self.y + dy*vel)
    self.body:setLinearVelocity(0, 0)
    self:moveShoot()
end

function Player:wallhack_on(freeze_world)
    freeze_world = freeze_world == true

    if freeze_world then 
        Physics.world:stop()
        self.wallhack_freeze_world = freeze_world
    end

    self:removeMasksFixtures()
    
    self.wallhack_gravity = self.body:getGravityScale()
    self.body:setGravityScale(0)
    self.move = move_on_wallhack
    self.applyDamage = nothing
end

function Player:wallhack_off()
    if is_nil(self.wallhack_gravity) then return end
    
    if self.wallhack_freeze_world then
        Physics.world:start()
        self.wallhack_freeze_world = nil
    end

    self:restoreMaskFixtures()

    self.body:setGravityScale(self.wallhack_gravity)
    self.move             = nil
    self.wallhack_gravity = nil
    self.applyDamage      = nil
end

return Player