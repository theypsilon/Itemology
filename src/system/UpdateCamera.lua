local System; import 'system'
local UpdateCamera = class(System)

function UpdateCamera:requires()
	return {'cam'}
end

function UpdateCamera:update(camera, dt)
    if not camera._target then return end
    local area = camera.area

    local x = camera:_calcCorner('x', area.w) - area.x
    local y = camera:_calcCorner('y', area.h) - area.y

    if camera._last_x and camera._last_y then
        local dx, dy = x - camera._last_x, y - camera._last_y

        if math.abs(dx) > 16 then x = camera._last_x + (dx > 0 and 16 or -16) end
        if math.abs(dy) > 16 then y = camera._last_y + (dy > 0 and 16 or -16) end
    end

    camera._last_x = x
    camera._last_y = y

    camera.cam:setLoc(x, y, camera.z)
end


return UpdateCamera