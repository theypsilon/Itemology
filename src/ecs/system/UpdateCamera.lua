local System; import 'ecs'
local UpdateCamera = class(System)

function UpdateCamera:requires()
	return {'cam'}
end

function UpdateCamera:update(e, _, cam)
    if not e._target then return end
    local area = e.area

    local x = e:_calcCorner('x', area.w) - area.x
    local y = e:_calcCorner('y', area.h) - area.y

    if e._last_x and e._last_y then
        local dx, dy = x - e._last_x, y - e._last_y

        if math.abs(dx) > 16 then x = e._last_x + (dx > 0 and 16 or -16) end
        if math.abs(dy) > 16 then y = e._last_y + (dy > 0 and 16 or -16) end
    end

    e._last_x = x
    e._last_y = y

    cam:setLoc(x, y, e.z)
end


return UpdateCamera