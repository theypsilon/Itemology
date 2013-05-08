require 'entity.Mob'
local super   = Mob

class.Player(super)

function Player:_init(level, x, y)
	super._init(self, level, x, y)
	self.dir = {left = 0, right = 0, up = 0, down = 0}
	for k,_ in pairs(self.dir) do
		input.bindAction(k, function() self.dir[k] = 1 end, function() self.dir[k] = 0 end)
	end
end

local move_factor = 500

function Player:tick(dt)
	local dx = -1*self.dir.left + self.dir.right
	local dy = -1*self.dir.up   + self.dir.down
	local mx = self.x + move_factor*dx*dt
	local my = self.y + move_factor*dy*dt
	local lx, ly = self.level:getBorder()
	if mx > 0 and mx < lx and my > 0 and my < ly then
		self.x = math.floor(mx)
		self.y = math.floor(my)
	end
	reload.instance(self)
	super.tick(self)
end

function Player:draw(...)
	super.draw(self, ...)
end