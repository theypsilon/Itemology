local Entity; import 'entity'

local Spawn = class(Entity)

function Spawn:_init   (level, definition, p)
    Entity._init(self, level, p.x, p.y)

    local pref  = definition.preferenceData

    if pref then
        self.entity = definition.entity
        self.num    = definition.total
        self.rate   = definition.rate
        self.offset = definition.offset
    else
        p = p.properties
        self.entity = p.entity or p.class
        self.num    = p.total
        self.rate   = p.rate
        self.offset = p.offset
    end

    definition = nil

    self.definition = require('data.entity.' .. self.entity)
    self.entity     = require(self.definition.class)
end

function Spawn:tick()
    if self.offset then
        self.offset = self.offset - 1
        if self.offset < 0 then self.offset = nil end
    elseif self._ticks % self.rate == 0 and self.num > 0 then
        self.level:add(self.entity(self.level, self.definition, self.pos))
        self.num = self.num - 1
    end

    Entity.tick(self)
end

return Spawn