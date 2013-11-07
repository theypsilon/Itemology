local super = require 'entity.Entity'

local Broken = class.Broken(super)

function Broken:_init(level, def, p)
    super._init(self, level, p.x, p.y)

    self.animation = def.animation
    self.sequence  = def.sequence

    self.step  = 1
    self.limit = self.sequence[1].limit
    self.animation:setAnimation(self.sequence[1].animation)
end

function Broken:tick()
    super.tick(self)

    if self._ticks > self.limit then
        self.step  = self.step + 1
        if self.step > #self.sequence then
            self:remove()
        else
            self.limit = self.sequence[self.step].limit
            self.animation:setAnimation(self.sequence[self.step].animation)
        end
    end

    self.animation:next()
end

return Broken