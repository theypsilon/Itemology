local Entity; import 'entity'

local Broken = class(Entity)

function Broken:_init(level, def, p)
    Entity._init(self, level, p.x, p.y)

    self.animation = def.animation
    self.sequence  = def.sequence

    self.step  = 1
    self.limit = self.sequence[1].limit
    self.animation:setAnimation(self.sequence[1].animation)
end

function Broken:tick()
    Entity.tick(self)

    local current

    if self.ticks > self.limit then
        self.step  = self.step + 1
        if self.step > #self.sequence then
            self:remove()
            return
        end
        current = self.sequence[self.step]
        self.limit = current.limit
        self.animation:setAnimation(current.animation)
    else
        current = self.sequence[self.step]
    end

    self.animation:next()
end

return Broken