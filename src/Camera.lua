class.Camera()

local function validate(area, padding)
end

function Camera:_init(target, area, padding)
    validate(area, padding)

    self:setTarget(target)
    self._scale  = scale or 1
    self.area    = area or { 
        x = 0, y = 0, 
        w = love.graphics.getWidth () <  self._limit.x and
            love.graphics.getWidth () or self._limit.x, 
        h = love.graphics.getHeight() <  self._limit.y and
            love.graphics.getHeight() or self._limit.y,
    }

    self.padding = padding or { x = 0, y = 0 }
    self:_buildCanvas()
end

function Camera:_buildCanvas()
    self._canvas  = love.graphics.newCanvas(self.area.w + 1, self.area.h + 1)
end

local function validateTarget(target)
end

function Camera:setTarget(target)
    validateTarget(target)
    self._target                 = target
    self._level                  = target.level
    self._limit                  = {}
    self._limit.x, self._limit.y = target.level:getBorder()
end

function Camera:draw()
    local map, entities = self._level.map, self._level.entities
    local area          = self.area
    local c             = self._canvas

    if not map then
        error('this is a scrolled camera, target needs a tiled map')
    end

    if c:getWidth() ~= area.w or c:getHeight() ~= area.h then
        self:_buildCanvas()
    end

    local x = self:_calcCorner('x', area.w)
    local y = self:_calcCorner('y', area.h)

    love.graphics.push()
    love.graphics.setCanvas(c)
    love.graphics.translate(-x, -y)
    map:setDrawRange(x, y, area.w, area.h)
    map:draw()
    for entity,_ in pairs(entities) do
        entity:draw()
    end
    love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.push()
    love.graphics.scale(self._scale)
    love.graphics.draw(c, area.x, area.y)
    love.graphics.pop()
    
end

local abs = math.abs
function Camera:_calcCorner(index, length)
    local padding = self.padding[index]
    local tloc    = self._target[index]
    local  loc    = self[index] or tloc
    local diff    = loc - tloc

    if abs(diff) > padding then
        if diff < 0 then loc = tloc - padding
                    else loc = tloc + padding end
    end    

    self[index] = loc

    local corner = loc - length/2
    local limit  = self._limit[index]

    if corner + length > limit then corner = limit - length end 
    if corner < 0              then corner = 0              end

    return corner
end