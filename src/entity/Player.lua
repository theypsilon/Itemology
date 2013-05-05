require 'entity.Entity'
local super   = Entity

class.Player(super)

function Player:_init()
	super._init(self, 400, 300)
	self.dir = {left = 0, right = 0, up = 0, down = 0}
	for k,_ in pairs(self.dir) do
		input.bindAction(k, function() self.dir[k] = 1 end, function() self.dir[k] = 0 end)
	end
end

local move_factor = 500

function Player:tick(dt)
	local dx = -1*self.dir.left + self.dir.right
	local dy = -1*self.dir.up   + self.dir.down
	self.x = self.x + move_factor*dx*dt
	self.y = self.y + move_factor*dy*dt
	reload.instance(self)
	super.tick(self)
end

function Player:draw()
	sprites:get('gr1'):draw(self.x, self.y)
	super.draw(self)
end