local Layer, Graphics; import()

local Entity = require 'entity.Entity'

local Camera = class.Camera()

local function validate(area, padding)
    if area and (not area.x or not area.y or not area.w or not area.h) then
        error 'incorrect area: not recognized {x,y,w,h}'
    end
    if padding and (not padding.x or not padding.y) then
        error 'incorrect padding: not recognized {x,y}'
    end
end

local z = 527

function Camera:_init(target, area, padding)
    validate(area, padding)

    self.cam = MOAICamera.new()
    local f = data.MainConfig.screen.width / data.MainConfig.world.width

    if target then 
        self:setTarget(target)
        self.area    = area or { 
            x = 0, y = 0, 
            w = Graphics.getWidth () <  self._end.x and
                Graphics.getWidth () or self._end.x, 
            h = Graphics.getHeight() <  self._end.y and
                Graphics.getHeight() or self._end.y,
        }
    end

    self.z = f * z

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
    self._map                    = target.map
    self._end                  = {}
    self._end.x, self._end.y = target.map:getBorder()
    self._end.x, self._end.y = self._end.x - 48, self._end.y - 16;
    self._begin = {x=0, y=0}
    (target.prop.layer or Layer.main):setCamera(self.cam)
end

function Camera:draw()
    if not self._target then return end
    local map = self._map
    local area          = self.area

    if not map then
        error('this is a scrolled camera, target needs a tiled map')
    end

    local x = self:_calcCorner('x', area.w) - area.x
    local y = self:_calcCorner('y', area.h) - area.y

    self.cam:setLoc(x, y, self.z)
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
    local ending = self._end  [index]
    local begin  = self._begin[index]

    if corner + length > ending then corner = ending - length end 
    if corner < begin           then corner = begin           end

    return corner
end

return Camera