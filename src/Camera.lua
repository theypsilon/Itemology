class.Camera()

local function validate(area, padding)
    if area and (not area.x or not area.y or not area.w or not area.h) then
        error 'incorrect area: not recognized {x,y,w,h}'
    end
    if padding and (not padding.x or not padding.y) then
        error 'incorrect padding: not recognized {x,y}'
    end
end

function Camera:_init(target, area, padding)
    validate(area, padding)

    self.cam = MOAICamera.new()

    self:setTarget(target)
    self.area    = area or { 
        x = 0, y = 0, 
        w = graphics.getWidth () <  self._limit.x and
            graphics.getWidth () or self._limit.x, 
        h = graphics.getHeight() <  self._limit.y and
            graphics.getHeight() or self._limit.y,
    }

    self.padding = padding or { x = 0, y = 0 }
end

local function validateTarget(target)
    if target:is_a(Entity) == false then
        error 'the target is not a valid "Entity" object'
    end
end

function Camera:setTarget(target)
    validateTarget(target)
    self._target                 = target
    self._level                  = target.level
    self._limit                  = {}
    self._limit.x, self._limit.y = target.level:getBorder()
    self._limit.x, self._limit.y = self._limit.x + 16 + 16, self._limit.y + 16
    target.prop.layer:setCamera(self.cam)
end

function Camera:draw()
    local map, entities = self._level.map, self._level.entities
    local area          = self.area

    if not map then
        error('this is a scrolled camera, target needs a tiled map')
    end

    local x = self:_calcCorner('x', area.w) - area.x
    local y = self:_calcCorner('y', area.h) - area.y

    self.cam:setLoc(x, y, 640)
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