local Animation; import()

local super = require 'entity.Entity'

local ParticleAnimation = class.ParticleAnimation(super)
function ParticleAnimation:_init(level, def, default, p, prop, skip, ...)
    super._init(self, level, p.x, p.y)

    self.animation = Animation(def, prop, skip, default)
    self.animation.prop:setLoc(p.x, p.y)
    self.animation:next(self, ...)

    self.prop = self.animation.prop
end

function ParticleAnimation:tick()
    super.tick(self)
    local changed, alive = self.animation:next()
    if not alive then self:remove() end
    self.x, self.y = self.prop:getLoc()
end

return ParticleAnimation