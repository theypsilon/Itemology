require 'entity.Mob'
local super   = Mob

local Position = require 'entity.Position'

class.Player(super)

function Player:_init(level, x, y)
	super._init(self, level, x, y)
	self.dir = {left = 0, right = 0, up = 0, down = 0}
	for k,_ in pairs(self.dir) do
		input.bindAction(k, function() self.dir[k] = 1 end, function() self.dir[k] = 0 end)
	end

    self.prop = sprites:get('stand'):newProp()

    local definition = require 'fixtures.Player'
    definition['prop'  ] = self.prop
    definition['parent'] = self

    self.body, self.fixtures = physics:addBody(definition)
    self:_setListeners()

    self.pos = Position(self.body)
    self.pos:set(x, y)
    self.jumping = false
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

    self.fixtures['sensor']:setCollisionHandler(floorSensor, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)
end
local move_factor = 10

function Player:tick(dt)

    self:move(dt)

	self.x, self.y = self.body:getPosition()

	--reload.instance(self)
	super.tick(self)
end

function Player:move(dt)
    local dx = -1*self.dir.left + self.dir.right

    if self:onGround() then

        if self.dir.up ~= 0 then self:jump() end

        if dx ~= 0 then
            self.body:applyLinearImpulse(dx*10, 0)
        end

    elseif dx ~= 0 then
        self.body:applyLinearImpulse(dx*3, 0)
    end

    local vx, vy = self.body:getLinearVelocity()
    if math.abs(vx) > 150 then
        self.body:setLinearVelocity(vx > 0 and 150 or -150, vy)
    end


    -- local lx, ly = self.level:getBorder()
    -- local vx, vy = self.body:getLinearVelocity()
    -- if math.abs(vx) > 100 then vx = vx > 0 and 100 or -100 end
    -- if math.abs(vy) > 100 then vy = vy > 0 and 100 or -100 end

    -- local mx, my = self.pos.x + vx*dt, self.pos.y + vy*dt
    -- if mx <= 0 or mx >= lx then vx = 0 end
    -- if my <= 0 or my >= ly then vy = 0 end

    -- self.body:setLinearVelocity(vx, vy)
end

function Player:onGround()
    return self.groundCount ~= 0
end

function Player:canJump()
    return self:onGround() and not self.jumping
end

function Player:jump()
    self.jumping = true
    self.body:applyLinearImpulse(0, -60)
end

function Player:draw(...)
	super.draw(self, ...)
end