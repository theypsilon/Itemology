local Physics; import()

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
    p.properties.orientation = p.properties.dir
    p.properties.action = nil
    local self = table.copy(p.properties)
    self.body  = body
    self._name = k

    self.vertical = w == 0
    self.processing = {}
    self.travelling = {}
    self.requesting = {}

    if self.orientation then 
        self.orientation = self.orientation == 'right' and 1 or self.orientation == 'left' and -1 or
                   self.orientation == 'down'  and 1 or self.orientation == 'up'   and -1 or
                   tonumber(self.orientation)
        assert(self.orientation == 1 or self.orientation == -1, self.orientation)
    end

    self.portal = {}

    body.fixtures.area:setCollisionHandler(function(...)
        self.portal[#self.portal + 1] = {...}
    end, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)

    self.pos = {x = p.x, y = p.y}
    return self
end