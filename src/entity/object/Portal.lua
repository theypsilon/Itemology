local Physics, Data; import()

local function onTick(self)
    if self.processing then
        for k,v in pairs(self.processing) do v(self, k) end
        self.processing = {}
    end
end

local function onBegin(self, e)
    local dir = e[self.orientation == 'vertical' and 'vx' or 'vy']
    self.travelling[e] = dir > 0 and 1 or -1
end

local function onEnd(self, e)
    assert(self.travelling[e])
    local dir = e[self.orientation == 'vertical' and 'vx' or 'vy']

    if (dir * self.travelling[e] > 0 and not self.requesting[e]) or
       (dir * self.travelling[e] < 0 and     self.requesting[e]) 
    then
        local exit = e.level.entityByName()[self.link][1]
        local x, y = e.x - self.x, e.y - self.y
        if self.orientation == 'vertical' then
            x = exit.x
            y = exit.y + y
        else
            x = exit.x + x
            y = exit.y
        end
        e.pos:set(x, y)
        exit.requesting[e] = true
    end

    self.requesting[e] = nil
    self.travelling[e] = nil
end

return function(d,p,k)

    local x, y, w, h
    if p[1] then
        local dot = table.map(
            table.explode(' ', p[1].points), function(v) return table.map(
                table.explode(',', v), function(v) return tonumber(v) 
            end) 
        end)
        x, y, w, h = dot[1][1], dot[1][2], dot[2][1], dot[2][2]
    else
        x, y, w, h = 0, 0, p.width or 0, p.height or 0
    end

    dump(x,y,w,h, k)
    

    if x == w then w = 0 end
    if y == h then h = 0 end

    local body   = Physics:makeItemBody(p.x, p.y, 'rect', {x, y, w, h})
    local object = table.copy(p.properties)
    object.body  = body
    object._name = k

    object.orientation = w == 0 and 'vertical' or 'horizontal'
    object.processing = {}
    object.travelling = {}
    object.requesting = {}

    body.fixtures.area:setCollisionHandler(function(p, fa, fb, a)
        if fb.name ~= 'area' then return end
        local e = fb:getBody().parent
        if not e or not e.pos then return end
        object.processing[e] = p == MOAIBox2DArbiter.END and onEnd or onBegin
    end, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)

    object.tick = onTick

    object.x, object.y = p.x, p.y
    return object
end