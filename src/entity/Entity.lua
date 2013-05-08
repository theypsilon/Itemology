class.Entity()

local function validate(level, x, y)
    
end

function Entity:_init(level, x, y)
    validate(level, x, y)

	self.x = x or 0
	self.y = y or 0
	self._ticks = 0
    self.level  = level
    level:add(self)
end

function Entity:tick() 
	self._ticks = self._ticks + 1
end

function Entity:draw()	
end