local Entity = class.Entity()

local function validate(level, x, y)
    
end

function Entity:_init(level, x, y)
    validate(level, x, y)

	self.x = x or 0
	self.y = y or 0
    self.size = {x = 0, y = 0}
    self.last = {x = 0, y = 0}
    self.zindex = 0
    self.currSp = nil
	self._ticks = 0
    self.level  = level
    self.map    = level.map
end

function Entity:tick() 
	self._ticks = self._ticks + 1
end

function Entity:remove()
    if self.hurt then self.hurt = function() end end
    self.removed = true
end

function Entity:draw()	
end

return Entity