local Physics, Data; import()

return function(d,p,k)
    local dot = table.map(
        table.explode(' ', p[1].points), function(v) return table.map(
            table.explode(',', v), function(v) return tonumber(v) 
        end) 
    end)

    local x, y, w, h = dot[1][1], dot[1][2], dot[2][1], dot[2][2]
    local body   = Physics:makeItemBody(p.x, p.y, 'rect', {x, y, w, h})
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