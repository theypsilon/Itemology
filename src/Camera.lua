class.Camera()

local function validate(target, rect)

end

function Camera:_init(target, rect)
    validate(target, rect)

    self._target       = target
	self._level        = target.level
    self._lx, self._ly = target.level:getBorder()
    self.rect    = rect or { 
        x = 0, y = 0, 
        w = love.graphics.getWidth () > self._lx and self._lx or love.graphics.getWidth(), 
        h = love.graphics.getHeight() > self._ly and self._ly or love.graphics.getHeight()
    }
    self._level.map:setDrawRange(0, 0, self._lx, self._ly)

end

function Camera:draw()
    local x, y          = self._target.x , self._target.y
    local map, entities = self._level.map, self._level.entities
    local rect = self.rect

    if map then
        local mx, my = ((rect.x + rect.w) / 2), ((rect.y + rect.h) / 2)
        local xo, yo = x - mx, y - my
        if xo < 0 then xo = 0 end
        if yo < 0 then yo = 0 end
        local x1, y1 = xo + rect.w, yo + rect.h
        local lx, ly = self._lx, self._ly
        if x1 > lx then 
            x1 = lx
            xo = lx - rect.w 
        end 
        if y1 > ly then
            y1 = ly
            yo = ly - rect.h
        end
        love.graphics.push()
        love.graphics.translate(-xo, -yo)
        --map:setDrawRange(xo, yo, x1, y1)
        map:draw()
        for entity,_ in pairs(entities) do
            entity:draw()
        end
        love.graphics.pop()
    else

    end
end