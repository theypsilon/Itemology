local Entity = class()

local function validate(level, x, y)
    
end

function Entity:_init(level, x, y)
    validate(level, x, y)

	self.pos = {x = x, y = y}
	self.ticks  = 0
    self.level  = level
    self.map    = level.map
end

function Entity:tick() 
	self.ticks = self.ticks + 1
end

function Entity:remove()
    if self.hurt then self.hurt = function() end end
    self.removed = true
end

function Entity:draw()	
end

return Entity