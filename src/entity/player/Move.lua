local Player = {}

local task, scenes, Text = require 'TaskQueue', require 'Scenes', require 'Text'

local abs     = math.abs
local nothing = function() end 

function Player:_setInitialMove(p)
    self. jumping = 0
    self.djumping = 0

    self.moveJump = self.moveDoubleJump
    --self.moveWallJump = nothing
    --self.moveLateral  = nothing
    --self.moveFallingDown = nothing
end

function Player:move(dt)
    dt = 1 / (dt * self.moveDef.timeFactor)

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
        ((og                        and self.keyRun) or
         (def.maxVxWalk < 0.9*abs(vx) and self.keyRun) or
          def.alwaysRun) 
        and def.maxVxRun or def.maxVxWalk

end

function Player:moveLateral(dt, force, maxVel)
    local vx, dx = self.vx, self.dx
    -- horizontal walk/run
    if dx ~= 0 and abs(vx) < maxVel then
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

function Player:moveSingleJump()
    if not self.keyJump then return end

    local jump = self.moveDef.jumpImp

    if  self:onGround() and 
        self.jumping == 0 
    then
        self.jumping = 1
        self:doJump()
    elseif  
        self.jumping == 0 
    then 
        self.jumping = #jump
    elseif 
        self.jumping > 0 and  
        self.jumping < #jump 
    then
        self.jumping = self.jumping + 1
        self:doJump()
    end
end

function Player:moveDoubleJump()
    if  self:onGround() and 
        self.keyJump    and 
        self.jumping == 0 
    then
        self.jumping = 1
        self:doJump()
    elseif 
        self:onGround() 
    then 
        self.djumping = 0 
    elseif 
        self.keyJump 
    then
        local jump = self.moveDef.jumpImp

        if  self.jumping == 0 
        then 
            if  self.power.djump > 0 and 
                self.djumping   == 0 
            then
                self.djumping = 1
                self.power.djump = self.power.djump - 1
                self:doDoubleJump()
            elseif 
                self.djumping > 0 and 
                self.djumping < #jump 
            then
                self.djumping = self.djumping + 1
                --self:doDoubleJump()
            else
                self.jumping = #jump
            end
        elseif  
            self.jumping > 0 and  
            self.jumping < #jump 
        then
            self.jumping = self.jumping + 1
            self:doJump()
        end
    end
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
               vx == 0  and
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

function Player:doJump()
    local jump = self.moveDef.jumpImp
    self.body:applyLinearImpulse(0, -jump[self.jumping])
end

function Player:doDoubleJump()
    local def = self.moveDef

    local dx   = -1*self.dir.left + self.dir.right
    local vx, vy = self.body:getLinearVelocity()
    local vx = dx*abs(vx)
    if vx > def.djumpMaxVx then vx = def.djumpMaxVx end
    self.body:setLinearVelocity(vx, -def.djumpUp)
end

function Player:resetJump()
    self.jumping = 0
end

function Player:moveDoor()
    if self.dir.up == 1 and self.door then
        if self.door.level and self.door.level ~= self.level.name then
            task.setOnce('changeMap', function() scenes.run('First', self.door, self.hp) end)
        else
            local link = self.door.layer.objects[self.door.link]
            self.pos:set(link.x, link.y)
        end
        self.dir.up = 0
    end
end

function Player:wallhack(on)
    on = on == true

    local physics = require 'Physics'

    if on then
        physics.world:stop()
        function self.move()
            local dx, dy = self.dx, -1 * self.dir.up + self.dir.down
            local vel = self.keyRun and 15 or 5
            self.pos:set(self.x + dx*vel, self.y + dy*vel)
        end
    else
        physics.world:start()
        self.move = Player.move
    end
end

return Player