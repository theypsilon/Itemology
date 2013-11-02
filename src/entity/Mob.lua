local super = require 'entity.Entity'

local Mob = class.Mob(super)

function Mob:_init   (level, x, y)
    super._init(self, level, x, y)
end

return Mob