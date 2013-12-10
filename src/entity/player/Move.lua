local Tasks, Scenes, Text, Data, Job, Physics; import()
local Bullet; import 'entity.particle'

local abs     = math.abs

local Player = {}

function Player:_setInitialMove(p)
    self.shooting = nothing

    self.setJump  = self.setDoubleJump

    self.moveJump = nothing
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
        self.level:add(Bullet(self.level, Data.animation.Bullet, self, speed, self))
    end
end

function Player:moveLateral(dt, force, maxVel)
    local vx, dx = self.vx, self.dx
    -- horizontal walk/run
    if dx ~= 0 then
        self.body:applyForce( dt*dx*force*(maxVel-abs(vx)), 0)
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
    if self.tasks.callbacks.jumping then return end

    local max    = #self.moveDef.jumpImp
    local djump  = nil
    self.setJump = nothing
    self.tasks:set('jumping', Job.interval(function(c)
        if not self.keyJump then return c:finish() end
        self:doJump(c.ticks + 1)
    end, 0, max)):after(function(c)
        if self:onGround()  then return c:finish(true) end

        if c.ticks == max then
            c.ticks = nil
            self.setJump = function() djump = true end
        end

        if djump then
            self:doDoubleJump()
            c:finish()
        end
    end):after(function(c)
        self.setJump = self.setDoubleJump
        if self:onGround()  then return c:finish() end
    end)
end

function Player:setSingleJump()
    if self.tasks.callbacks.jumping then return end

    local jump   = self.moveDef.jumpImp
    self.tasks:set('jumping', Job.interval(function(c)
        if not self.keyJump then return c:finish() end
        self:doJump(c.ticks + 1)
    end, 0, #jump)):after(function(c)
        if self:onGround()  then return c:finish() end
    end)
end

function Player:moveWallJump()
    local vx, vy, dx = self.vx, self.vy, self.dx

    if  self:onGround() then
        self.walltouch, self.lastwalljump = false, 0
        return
    end

    local touch = self.touch == 0 and 0 or self.touch / math.abs(self.touch)

    if touch ~= 0 then

        if  touch == dx and
        --     vx == 0  and
            self.lastwalljump ~= touch
        then
            self.walltouch = true
        end
    else
        self.walltouch = false
    end

    if self.walltouch then

        local def = self.moveDef

        if  self.keyJump    and 
            self.jumping == 0 
        then
            self.jumping = -1
            self.body:setLinearVelocity(
                -touch * ( def.wjumpVxPlus + abs(dx) * def.wjumpVxBase ), 
                -def.wjumpUp
            )
            self.lastwalljump = touch
        else
            local ws = def.wallSlidingSpeed
            if (self.jumping == 0 or self.lastwalljump  ~= touch) and
                vy  > ws    
            then
                local v = vy - ws
                self.body:setLinearVelocity(vx, ws)
        end end
    end

end

function Player:onGround()
    return self.groundCount ~= 0
end

function Player:doJump(step)
    local jump = self.moveDef.jumpImp
    self.body:applyLinearImpulse(0, -jump[step])
end

function Player:doDoubleJump()
    print 'do de dudde jump'
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
            gTasks:once('changeMap', function() Scenes.run('First', self.door, self.hp) end)
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