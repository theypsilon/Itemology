require 'entity.Mob'
local super   = Mob

local Position = require 'entity.Position'

class.Player(super)

function Player:_init(level, x, y)
	super._init(self, level, x, y)

    self.prop = sprites:get('stand'):newProp()

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

function Player:tick(dt)

    self:move(dt)

	self.x, self.y = self.body:getPosition()

    if self.y > self.limit_map_y then 
        local spawn = self.level.map('objects')('spawn')
        self.pos:set(spawn.x, spawn.y)
        self.body:setLinearVelocity(0, 0)
    end

	--reload.instance(self)
	super.tick(self)
end

function Player:move(dt)

    local dx = -1*self.dir.left + self.dir.right
    local vx, vy = self.body:getLinearVelocity()
    local def = self.moveDef

    dt = dt * def.timeFactor
    local force  = def.ogHorForce
    local maxVel = def.maxVxWalk

    -- if running, maxspeed is different
    if self.keyRun then maxVel = def.maxVxRun end

    -- which forces apply on character
    if self:onGround() and self:canJump() then
        self.jumping = 1
        self:doJump(dt)
    else
        if self.keyJump then
            local jump = def.jumpImp
            if self.jumping == 0 then self.jumping = #jump
            elseif self.jumping > 0 and self.jumping < #jump then
                self.jumping = self.jumping + 1
                self:doJump(dt)
            end
        end
        if dx ~= 0      then force = def.oaHorForce end
    end

    -- horizontal walk/run
    if dx ~= 0 then
        self.body:applyForce( dt*dx*force*(maxVel-math.abs(vx)), 0)
    end

    -- fake friction in horizontal axis
    if vx ~= 0 and ((dx == 0 and self:onGround()) or dx*vx < 0) then
        self.body:applyForce(-dt*vx*force*def.slowdown, 0)
    end

    -- falling down
    if def.addGravity + vy > def.maxVyFall 
    then self.body:applyLinearImpulse(0,def.maxVyFall - vy - def.addGravity)
    else self.body:applyLinearImpulse(0,def.addGravity) end
    
end

function Player:onGround()
    return self.groundCount ~= 0
end

function Player:canJump()
    return self.keyJump and self.jumping == 0
end

function Player:doJump(dt)
    self.body:applyLinearImpulse(0, -self.moveDef.jumpImp[self.jumping])
end

function Player:draw(...)
	super.draw(self, ...)
end