local Tasks, Scenes, Text, Data, Job, Physics; import()
local Bullet; import 'entity.particle'

local abs     = math.abs

local Player = {}

function Player:_setInitialMove(p)
    self.shooting     = nothing
    self.jumpBackup   = self.setDoubleJump
    self.setJump      = self.setDoubleJump
    self.doDoubleJump = self.doPeachJump
    --self.moveWallJump = nothing
    --self.moveLateral  = nothing
    --self.moveFallingDown = nothing
    self.moveShoot    = nothing
end

function Player:move(dt)
    dt = 1 / (dt * self.moveDef.timeFactor)

    self:moveShoot      (  )
    self:moveDoor       (  )
    self:moveWallJump   (  )
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

local function sig(v)
    return v > 0 and 1 or v < 0 and -1 or 0
end

function Player:moveLateral(dt, force, maxVel)
    local vx, dx = self.vx, self.dx
    -- horizontal walk/run
    if dx ~= 0 then
        local vel = maxVel - abs(vx)
        if abs(vel) > maxVel and sig(vel) == dx then vel = -vel end
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