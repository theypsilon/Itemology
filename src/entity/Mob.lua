local Entity; import 'entity'

local Mob = class.Mob(Entity)

function Mob:_init   (level, x, y)
    Entity._init(self, level, x, y)
end

return Mob