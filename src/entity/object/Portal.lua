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
    local dir = (self.dir and not self.requesting[e]) 
        and self.dir or get_component(self.vertical, e)
    self.travelling[e] = dir > 0 and 1 or -1
end

local function onEnd(self, e)
    assert(self.travelling[e])
    local dir = get_component(self.vertical, e)

    if (dir * self.travelling[e] > 0 and not self.requesting[e]) or
       (dir * self.travelling[e] < 0 and     self.requesting[e]) 
    then
        local exit = e.level.entityByName()[self.link][1]

        local offset = self.vertical and 
            (e.pos.y - self.pos.y) or (e.pos.x - self.pos.x)
        if exit.vertical ~= self.vertical then
            offset = -offset
            local vx, vy = e.body:getLinearVelocity()
            e.body:setLinearVelocity(vy, vx)
        end
        local x, y
        if exit.vertical then
            x = exit.pos.x
            y = exit.pos.y + offset
        else
            x = exit.pos.x + offset
            y = exit.pos.y
        end
        e.body:setTransform(x, y)

        if not self.requesting[true] then
            exit.requesting[e] = true
        end
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

    if self.dir then 
        self.dir = self.dir == 'right' and 1 or self.dir == 'left' and -1 or
                   self.dir == 'down'  and 1 or self.dir == 'up'   and -1 or
                   tonumber(self.dir)
        assert(self.dir == 1 or self.dir == -1, self.dir)
    end

    body.fixtures.area:setCollisionHandler(function(p, fa, fb, a)
        if fb.name ~= 'area' then return end
        local e = fb:getBody().parent
        if not e or not e.body then return end
        self.processing[e] = p == MOAIBox2DArbiter.END and onEnd or onBegin
    end, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)

    self.tick = onTick

    self.pos = {x = p.x, y = p.y}
    return self
end