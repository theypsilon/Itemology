local Layer, Graphics, Data; import()

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
    return target and target.pos and
        (target.pos.x or target.x) and
        (target.pos.y or target.y)
end

function Camera:setTarget(target)
    if not validateTarget(target) then
        error 'target not valid!'
    end

    local endx, endy = target.map:getBorder()

    self._target             = target
    self._limit =  {x = 0, y = 0, w = endx, h = endy}
    (target.prop.layer or Layer.main):setCamera(self.cam)
end

return Camera