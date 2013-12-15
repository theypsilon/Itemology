local Physics, Data; import()

return function(d,p)
    local x, y, w, h = p.x, p.y, p.width, p.height
    local body, fix = Physics:registerBody {
        id = 'Mob',
        option = 'static',
        fixtures = {
            ['area']={
                    option = 'rect',
                    args   = {0, 0, w, h},
                    sensor = true
            },
        },
        x = x,
        y = y,

        fixCategory = Data.fixture.Filters.C_ITEM,
        fixMask     = Data.fixture.Filters.M_ITEM
    }

    local object = table.copy(p.properties)
    object.body  = body

    object.x, object.y = p.x, p.y
    return object
end