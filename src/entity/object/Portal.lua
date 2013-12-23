local Physics, Data; import()

local function get_component(vertical, e)
    local  dir = e[vertical and 'vx' or 'vy']
    if not dir then
        local x, y = e.body:getLocation()
        dir = vertical and x or y
    end
    return dir
end

local function onTick(self)
    if self.processing then
        for k,v in pairs(self.processing) do v(self, k) end
        self.processing = {}
    end
end

local function onBegin(self, e)
    local dir = get_component(self.vertical, e)
    self.travelling[e] = dir > 0 and 1 or -1
end

local function onEnd(self, e)
    assert(self.travelling[e])
    local dir = get_component(self.vertical, e)

    if (dir * self.travelling[e] > 0 and not self.requesting[e]) or
       (dir * self.travelling[e] < 0 and     self.requesting[e]) 
    then
        local exit = e.level.entityByName()[self.link][1]
        local x, y = e.x - self.x, e.y - self.y
        if self.vertical then
            x = exit.x
            y = exit.y + y
        else
            x = exit.x + x
            y = exit.y
        end
        e.body:setTransform(x, y)
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

    if x == w then w = 0 end
    if y == h then h = 0 end

    local body = Physics:makeItemBody(p.x, p.y, 'rect', {x, y, w, h})
    local self = table.copy(p.properties)
    self.body  = body
    self._name = k

    self.vertical = w == 0
    self.processing = {}
    self.travelling = {}
    self.requesting = {}

    body.fixtures.area:setCollisionHandler(function(p, fa, fb, a)
        if fb.name ~= 'area' then return end
        local e = fb:getBody().parent
        if not e or not e.body then return end
        self.processing[e] = p == MOAIBox2DArbiter.END and onEnd or onBegin
    end, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)

    self.tick = onTick

    self.x, self.y = p.x, p.y
    return self
end