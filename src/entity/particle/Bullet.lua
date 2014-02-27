local Animation, Physics, Data; import()
local Entity, Position; import 'entity'

local Bullet = class(Entity)
function Bullet:_init(level, def, p, speed, parent, onhit)
    Entity._init(self, level, p.x, p.y)
    self.lx, self.ly = level.map:getBorder()

    self.animation = Animation(def)
    self.speed     = speed

    self.prop = self.animation.prop
    self.body = Physics:registerBody(Data.fixture.Bullet, self.prop, self)

    self.parent = parent

    self.body.fixtures['area']:setCollisionHandler(
        Bullet.onHit(onhit), MOAIBox2DArbiter.POST_SOLVE)

    self.pos = Position(self.body)
    self.pos:set(p.x, p.y)
end

function Bullet.onHit(onhit)
    onhit = onhit or function(_, impact) return is_nil(impact.sensor) end
    assert(is_function(onhit), 'onhit has to call a function')
    return function(p, fa, fb, a)
        local self = fa:getBody().parent
        local impact = fb:getBody()
        if onhit(self, impact, a) then self.tick = self.remove end
    end
end

function Bullet:tick()
    Entity.tick(self)
    self.animation:next()
    self.body:setLinearVelocity(self.speed[1], self.speed[2])

    local x, y = self.pos:get()
    if x > self.lx or y > self.ly or x < 0 or y < 0 then
        self:remove()
    end
    self.x, self.y = x, y
end

return Bullet