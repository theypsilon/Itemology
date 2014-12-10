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
	self:runSystem('UpdateTicks')
end

function Entity:remove()
    if self.hurt then self.hurt = function() end end
    self.removed = true
end

function Entity:draw()	
end

function Entity:runSystem(system, dt)
    dt = dt or self.dt
    local syst = require('ecs.system.'..system)
    local args = {syst, self, dt}
    for _,component in pairs(syst:requires()) do
        table.insert(args, self[component])
    end
    syst.update(unpack(args))
end

return Entity