local Tasks, Scenes, Text, Data, Job, Physics; import()
local Bullet; import 'entity.particle'

local abs     = math.abs

local Player = {}

function Player:_setInitialMove(p)
    --self.moveLateral  = nothing
    --self.moveVertical = nothing
end

function Player:move ()
    self:moveDoor    ()
    self:moveFalling ()
    self:moveLateral (self:calcMainForces())
    self:moveVertical()
end

function Player:moveFalling()
    if self:onGround() then self.lastwalljump = nil; return end
    
    local occupied = 
        self.tasks.callbacks.jumping or 
        self.tasks.callbacks.falling

    if occupied then return end

    local jump = self:getDoubleJumpStateMachine()
    jump:next(2)

    self.tasks:set('falling', jump)
end

function Player:calcMainForces()
    local vx  = self.vx
    local def = self.moveDef
    local og  = self:onGround()
    return 
        -- which forces apply on character
        og and def.ogHorForce or def.oaHorForce,
        -- if running, maxspeed is different
        ((og                          and self.action.run) or
         (def.maxVxWalk < 0.9*abs(vx) and self.action.run) or
          def.alwaysRun) 
        and def.maxVxRun or def.maxVxWalk

end

local function sig(v)
    return v > 0 and 1 or v < 0 and -1 or 0
end

function Player:moveLateral(force, maxVel)
    local vx, dx, dt = self.vx, self.dx, self.dt
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

        self.body:applyForce(-dt*vx*force*slowdown, 0)
    end

    -- local limitvx = 300
    -- if abs(vx) > limitvx then 
    --     self.body:setLinearVelocity(vx > 0 and limitvx or -limitvx, self.vy)
    -- end
end

function Player:moveVertical()
    local def, vy = self.moveDef, self.vy
    if def.addGravity + vy > def.maxVyFall 
    then self.body:applyLinearImpulse(0, def.maxVyFall - vy - def.addGravity)
    else self.body:applyLinearImpulse(0, def.addGravity) end

    if vy < -400 then self.body:applyLinearImpulse(0, -vy - 400) end
end

function Player:moveDoor()
    if self.action.up and self.door then
        if self.door.level and self.door.level ~= self.level.name then
            gTasks:once('changeMap', function() 
                Scenes.run('First', self.door, self.hp) 
            end)
        else
            local link = self.door.layer.objects[self.door.link]
            if link then self.body:setTransform(link.x, link.y) end
        end
        self.action.up = false
    end
end

local function move_on_wallhack(self)
    local dx, dy = self.dx, 
    -1 * (self.action.up and 1 or 0) + (self.action.down and 1 or 0)
    local vel = self.action.run and 15 or 5
    self.body:setTransform(self.pos.x + dx*vel, self.pos.y + dy*vel)
    self.body:setLinearVelocity(0, 0)
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