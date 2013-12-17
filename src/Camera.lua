local Layer, Graphics, Data; import()

local Entity = require 'entity.Entity'

local Camera = class()

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
    local f = Data.MainConfig.screen.width / Data.MainConfig.world.width

    self.padding = padding or { x = 0, y = 0 }

    if target then
        self:setTarget(target)
        self.area    = area or { 
            x = 0, y = 0, 
            w = Graphics.getWidth () <  self._limit.w and
                Graphics.getWidth () or self._limit.w, 
            h = Graphics.getHeight() <  self._limit.h and
                Graphics.getHeight() or self._limit.h,
        }
    end

    self.z = f * z
end

local function validateTarget(target)
    if target:is_a(Entity) == false then
        error 'the target is not a valid "Entity" object'
    end
end

function Camera:setTarget(target)
    validateTarget(target)

    local endx, endy = target.map:getBorder()

    self._target             = target
    self._map                = target.map
    self._limit =  {x = 0, y = 0, w = endx, h = endy}
    (target.prop.layer or Layer.main):setCamera(self.cam)
end

function Camera:draw()
    if not self._target then return end
    local area = self.area

    local x = self:_calcCorner('x', area.w) - area.x
    local y = self:_calcCorner('y', area.h) - area.y

    if self._last_x and self._last_y then
        local dx, dy = x - self._last_x, y - self._last_y

        if math.abs(dx) > 16 then x = self._last_x + (dx > 0 and 16 or -16) end
        if math.abs(dy) > 16 then y = self._last_y + (dy > 0 and 16 or -16) end
    end

    self._last_x = x
    self._last_y = y

    self.cam:setLoc(x, y, self.z)
end

local end_char = {x = 'w', y = 'h'}
local end_fix  = {x = -48, y = -24}

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
    local ending = self._limit[end_char[index]] + end_fix[index]
    local begin  = self._limit[index]

    if corner + length > ending then corner = ending - length end 
    if corner < begin           then corner = begin           end

    return corner
end

return Camera