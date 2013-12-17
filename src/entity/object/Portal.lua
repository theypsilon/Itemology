local Physics, Data; import()

local function explode(div,str) -- credit: http://richard.warburton.it
    if (div == '') then return false end

    local pos, arr = 0, {}

    for st, sp in function() return string.find(str, div, pos, true) end do
        arr[#arr + 1] = string.sub(str, pos, st - 1)
        pos = sp + 1
    end

    arr[#arr + 1] = string.sub(str, pos)
    return arr
end

return function(d,p,k)
    local dot = table.map(
        explode(' ', p[1].points), function(v) return table.map(
            explode(',', v), function(v) return tonumber(v) 
        end) 
    end)

    local x, y, w, h = dot[1][1], dot[1][2], dot[2][1], dot[2][2]
    local body, fix = Physics:registerBody {
        id = 'Mob',
        option = 'static',
        fixtures = {
            ['area']={
                    option = 'rect',
                    args   = {x, y, w, h},
                    sensor = true
            },
        },
        x = p.x,
        y = p.y,

        fixCategory = Data.fixture.Filters.C_ITEM,
        fixMask     = Data.fixture.Filters.M_ITEM
    }

    local object = table.copy(p.properties)
    object.body  = body
    object._name = k

    local offsetx = w == 0 and 16 or 0
    local offsety = h == 0 and 16 or 0

    function object:move(e, origin)
        local x, y = e.x - origin.x, e.y - origin.y
        x = x + (e.vx < 0 and -offsetx or offsetx)
        y = y + (e.vy < 0 and -offsety or offsety)
        e.pos:set(self.x + x, self.y + y)
    end

    body.fixtures.area:setCollisionHandler(function(p, fa, fb, a)
        if fb.name ~= 'area' then return end
        local body = fb:getBody()
        local e = body.parent
        if e and e.pos then
            if p == MOAIBox2DArbiter.BEGIN then
                local link = object.link
                gTasks:once(nil, function()
                    local exit = e.level.entityByName()[link][1]
                    exit:move(e, object)
                end)
            end
        end
    end, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)

    object.x, object.y = p.x, p.y
    return object
end