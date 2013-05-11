require 'entity.Entity'
local super   = Entity

class.Mob(super)

function Mob:_init   (level, x, y)
    super._init(self, level, x, y)
end

function Mob:tick(dt)
    super.tick (self)
end

function Mob:draw(x, y, z)
    x = x or self.x
    y = y or self.y
    sprites:get('stand'):draw(x, y)
    super.draw(self)
end