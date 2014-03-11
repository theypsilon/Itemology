local Animation; import()

local Entity; import 'entity'

local ParticleAnimation = class(Entity)
function ParticleAnimation:_init(level, def, default, p, prop, skip, ...)
    Entity._init(self, level, p.x, p.y)

    self.animation = Animation(def, prop, skip, default)
    self.animation.prop:setLoc(p.x, p.y)
    self.animation:next(self, ...)

    self.prop = self.animation.prop
end

function ParticleAnimation:tick()
    Entity.tick(self)
    local changed, alive = self.animation:next()
    if not alive then self:remove() end
    self.pos.x, self.pos.y = self.prop:getLoc()
end

return ParticleAnimation