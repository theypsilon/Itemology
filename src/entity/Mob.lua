require 'entity.Entity'
local super   = Entity

class.Mob(super)

function Mob:_init   (level, x, y)
    super._init(self, level, x, y)
    self.prop = sprites:get('stand'):newProp()
    local body = world:addBody ( MOAIBox2DBody.DYNAMIC )
    self.prop:setAttrLink ( MOAIProp2D.INHERIT_TRANSFORM, body, MOAIProp2D.TRANSFORM_TRAIT )
    self.body = body
end

function Mob:tick(dt)
    super.tick (self)
end

function Mob:draw(x, y, z)
    --x = x or self.x
    --y = y or self.y
    --self.prop:setLoc(x, y)
    super.draw(self)
end