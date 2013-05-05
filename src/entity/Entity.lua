class.Entity()

function Entity:_init(x, y)
	self.x = x or 0
	self.y = y or 0
	self.t = 0;
end

function Entity:tick() 
	self.t = self.t + 1
end

function Entity:draw() 
	love.graphics.print(self.t, self.x, self.y)
end