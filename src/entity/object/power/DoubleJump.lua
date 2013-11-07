local physics = require 'Physics'
local Atlass  = require 'Atlass'

return function(d,p)
    local x, y, w, h = p.x, p.y, p.width, p.height
    local atlass = Atlass(data.atlass.Sprites)
    local prop  = atlass:get('doublejump'):newProp()
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

    return {body = body, prop = prop, x=x, y=y, tick=function() end}
end