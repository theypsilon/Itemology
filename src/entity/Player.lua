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

    self.fixtures[1]:setCollisionHandler( 
        function() end, 
        MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END 
    )

    self.pos = Position(self.body)
    self.pos:set(x, y)
end

local move_factor = 10

function Player:tick(dt)
	local dx = -1*self.dir.left + self.dir.right
	local dy = -1*self.dir.up   + self.dir.down
	local lx, ly = self.level:getBorder()

	if dx ~= 0 or dy ~= 0 then
		self.body:applyLinearImpulse(dx*10, dy*10)
	end

	-- local vx, vy = self.body:getLinearVelocity()
	-- if math.abs(vx) > 100 then vx = vx > 0 and 100 or -100 end
	-- if math.abs(vy) > 100 then vy = vy > 0 and 100 or -100 end

	-- local mx, my = self.pos.x + vx*dt, self.pos.y + vy*dt
	-- if mx <= 0 or mx >= lx then vx = 0 end
	-- if my <= 0 or my >= ly then vy = 0 end

	-- self.body:setLinearVelocity(vx, vy)

	self.x, self.y = self.body:getPosition()

	--reload.instance(self)
	super.tick(self)
end

function Player:draw(...)
	super.draw(self, ...)
end