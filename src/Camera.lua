class.Camera()

local function validate(target, rect)

end

function Camera:_init(target, rect)
    validate(target, rect)

    self._target = target
	self._level  = target.level
    self.rect    = rect or {x = 0, y = 0, w = love.graphics.getWidth(), h = love.graphics.getHeight()}
    dump(self.rect)
end

function Camera:draw()
    local x, y          = self._target.x , self._target.y
    local map, entities = self._level.map, self._level.entities
    local rect = self.rect

    if map then
        local mx, my = math.floor((rect.x + rect.w) / 2), math.floor((rect.y + rect.h) / 2)
        local xo, yo = x - mx, y - my
        if xo < 0 then xo = 0 end
        if yo < 0 then yo = 0 end
        local x1, y1 = xo + rect.w, yo + rect.h
        love.graphics.push()
        love.graphics.translate(-xo, -yo)
        map:draw()
        for entity,_ in pairs(entities) do
            entity:draw()
        end
        love.graphics.pop()
        map:setDrawRange(xo, yo, x1, y1)
    else

    end
end