require 'entity.Entity'
local super   = Entity

class.Mob(super)

function Mob:_init   (level, x, y)
    super._init(self, level, x, y)
end