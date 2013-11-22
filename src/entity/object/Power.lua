local physics   = require 'Physics'
local Animation = require 'Animation'

local function remove(self) self.removed = true   end
local function tick  (self) self.animation:next() end

return function(d,p)
    local x, y, w, h = p.x, p.y, p.width, p.height
    local animation = Animation(data.animation.Power)
    animation:setAnimation(p.properties.power)

    local prop  = animation.prop
    local body, fix = physics:registerBody({
        id = 'Mob',
        option = 'static',
        fixtures = {
            ['area']={
                    option = 'rect',
                    args   = {-w/2, -h/2, w/2, h/2},
                    sensor = true
            },
        },
        x = x,
        y = y,
    }, prop)

    body.object = p.properties

    return {
        body = body, 
        prop = prop, 
        x=x, y=y, 
        animation = animation, 
        remove = remove, tick = tick
    }
end