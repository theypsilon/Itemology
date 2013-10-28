require 'entity.Mob'
local super   = Mob

local Position = require 'entity.Position'

class.Player(super)

function Player:_init(level, x, y)
	super._init(self, level, x, y)

    self.animation = Animation(data.animation.Player)
    self.prop      = self.animation.prop

    local definition = data.fixtures.Player
    definition['prop'  ] = self.prop
    definition['parent'] = self

    self.body, self.fixtures = physics:addBody(definition)

    self:_setListeners()
    self:_setInput()

    self.pos = Position(self.body)
    self.pos:set(x, y)

    self.jumping = 0

    local _
    _, self.limit_map_y = self.level:getBorder()

    self.moveDef = data.move.Player
end

function Player:_setInput()

    -- walk
    self.dir = {left = 0, right = 0, up = 0, down = 0}
    for k,_ in pairs(self.dir) do
        input.bindAction(k, function() self.dir[k] = 1 end, function() self.dir[k] = 0 end)
    end

    -- jump
    input.bindAction('b2', 
        function() self.keyJump = true end, 
        function() self.keyJump = false; self.jumping = 0 end)

    -- run
    input.bindAction('b1', function() self.keyRun = true end, function() self.keyRun = false end)
end

function Player:_setListeners()
    self.fixtures['area']:setCollisionHandler( 
        function() end, 
        MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END 
    )

    self.groundCount = 0

    local function floorSensor(phase, fix_a, fix_b, arbiter)
        if phase == MOAIBox2DArbiter.BEGIN then
            self.groundCount = self.groundCount + 1
            if fix_b:getBody().tag == 'platform' then
                self.platform = fix_b:getBody()
            end
        elseif phase == MOAIBox2DArbiter.END then
            self.groundCount = self.groundCount - 1
            if fix_b:getBody().tag == 'platform' then
                self.platform = nil
            end
        end
    end

    self.fixtures['sensor1']:setCollisionHandler(floorSensor, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)
    self.fixtures['sensor2']:setCollisionHandler(floorSensor, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)
end

local abs = math.abs

function Player:tick(dt)

    local vx, vy  = self.body:getLinearVelocity()

    self:move(dt, vx, vy)

	self.x, self.y = self.body:getPosition()

    if self.y > self.limit_map_y then 
        local spawn = self.level.map('objects')('spawn')
        self.pos:set(spawn.x, spawn.y)
        self.body:setLinearVelocity(0, 0)
    end

    self:animate(vx, vy)

	super.tick(self)
end

function Player:move(dt, vx, vy)
    if not vx or not vy then vx, vy = self.body:getLinearVelocity() end

    local dx     = -1*self.dir.left + self.dir.right

    local def = self.moveDef
    local force, maxVel, slowdown = def.ogHorForce, def.maxVxWalk, def.slowWalk

    dt = dt * def.timeFactor

    -- if fast, slowdown is weaker
    if abs(vx) > maxVel then slowdown = def.slowRun end

    -- if running, maxspeed is different
    if self.keyRun or def.alwaysRun then maxVel = def.maxVxRun end

    self:moveJump(dx, def, dt)

    -- which forces apply on character
    if not self:onGround() and dx ~= 0 then force = def.oaHorForce end

    -- horizontal walk/run
    if dx ~= 0 then
        self.body:applyForce( dt*dx*force*(maxVel-abs(vx)), 0)
    end

    -- fake friction in horizontal axis
    if vx ~= 0 and (dx*vx < 0 or (dx == 0 and self:onGround())) then
        self.body:applyForce(-dt*vx*force*slowdown, 0)
    end

    -- falling down
    if def.addGravity + vy > def.maxVyFall 
    then self.body:applyLinearImpulse(0, def.maxVyFall - vy - def.addGravity)
    else self.body:applyLinearImpulse(0, def.addGravity) end
    
end

function Player:moveJump(dx, def, dt)
    if self:onGround() and self.keyJump and self.jumping == 0 then
        self.jumping = 1
        self:doJump(dt)
    elseif self.keyJump then
        local jump = def.jumpImp
        if     self.jumping == 0 then self.jumping = #jump
        elseif self.jumping  > 0 and  self.jumping < #jump then
            self.jumping = self.jumping + 1
            self:doJump(dt)
        end
    end
end

function Player:onGround()
    return self.groundCount ~= 0
end

function Player:doJump(dt)
    self.body:applyLinearImpulse(0, -self.moveDef.jumpImp[self.jumping])
end

function Player:animate(vx, vy)
    if not vx or not vy then vx, vy = self.body:getLinearVelocity() end
    local def = self.moveDef

    if abs(vx) > 5 and abs(vy) < 1  then self.animation:setAnimation(abs(vx)*0.9 <= def.maxVxWalk and 'walk' or 'run')
                                    else self.animation:setAnimation('stand') end

    local dx = -1*self.dir.left + self.dir.right
    if abs(vy) > 1 then
        self.animation:setAnimation(abs(vx)*0.9 <= def.maxVxWalk and 'jump' or (vy < 0) and 'fly' or 'fall')
    elseif dx*vx < 0 then
        self.animation:setAnimation('skid')
    end

    self.animation:setMirror(vx < 0)
    self.animation:next()
end

function Player:draw(...)
	super.draw(self, ...)
end