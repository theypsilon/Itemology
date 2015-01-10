local Animation; import()

local function ParticleAnimation(level, def, default, p, prop, skip, ...)
    local e = {}
    e.pos = {x = p.x, y = p.y}
    e.ticks  = 0
    e.level  = level
    e.map    = level.map

    e.animation = Animation(def, prop, skip, default)
    e.animation.prop:setLoc(p.x, p.y)
    e.animation:next(e, ...)
    e.animation_entity = true
    e.animation_result = {}

    e.prop = e.animation.prop
    e._name="particle.Animation"
    return e
end

return ParticleAnimation