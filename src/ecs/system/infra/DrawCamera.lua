local Layer; import()
local System; import 'ecs'

local DrawCamera = class(System)

function DrawCamera:requires()
    return {'cam'}
end

function DrawCamera:update(e, _, cam)
    if not cam.prop then
        cam.prop = MOAICamera.new()
        ;
        (cam.target.prop.layer or Layer.main):setCamera(cam.prop)
    end
    cam.prop:setLoc(cam.last_x, cam.last_y, e.z)
end


return DrawCamera