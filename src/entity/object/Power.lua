local Physics, Animation, Data; import()

local function remove(self) self.removed = true   end
local function tick  (self) self.animation:next() end

return function(d,p)
    local x, y, w, h = p.x, p.y, p.width, p.height
    local animation = Animation(Data.animation.Power)
    animation:setAnimation(p.properties.power)

    local prop  = animation.prop
    local body, fix = Physics:registerBody({
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

        fixCategory = Data.fixture.Filters.C_ITEM,
        fixMask     = Data.fixture.Filters.M_ITEM
    }, prop)

    local object = table.copy(p.properties)
    object.x, object.y = x, y
    object.prop = prop
    object.animation = animation
    object.body = body
    object.tick = tick
    object.remove = remove

    if object.z then prop:setPriority(object.z) end

    return object
end