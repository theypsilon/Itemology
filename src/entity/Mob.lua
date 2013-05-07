require 'entity.Entity'
local super   = Entity

class.Mob(super)

function Mob:_init   (level, x, y)
    super._init(self, level, x, y)
end

function Mob:tick(dt)
    super.tick (self)
end

function Mob:draw()
    sprites:get('gr1'):draw(self.x, self.y)
    super.draw(self)
end