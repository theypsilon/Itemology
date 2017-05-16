local Layer; import()
local System; import 'ecs'
local UpdateCamera = class(System)

function UpdateCamera:requires()
	return {'cam'}
end

function UpdateCamera:update(e, _, cam)
    if not cam.target then return end
    local area = cam.area

    local x = self:_calcCorner(cam, 'x', area.w) - area.x
    local y = self:_calcCorner(cam, 'y', area.h) - area.y

    if cam.last_x and cam.last_y then
        local dx, dy = x - cam.last_x, y - cam.last_y

        if math.abs(dx) > 16 then x = cam.last_x + (dx > 0 and 16 or -16) end
        if math.abs(dy) > 16 then y = cam.last_y + (dy > 0 and 16 or -16) end
    end

    cam.last_x = x
    cam.last_y = y
end

local end_char = {x = 'w', y = 'h'}
local end_fix  = {x = -48, y = -24}

local abs = math.abs
function UpdateCamera:_calcCorner(cam, index, length)
    local padding = cam.padding[index]
    local tloc    = cam.target.pos and cam.target.pos[index] or cam.target[index]
    local  loc    = cam[index] or tloc
    local diff    = loc - tloc

    if abs(diff) > padding then
        if diff < 0 then loc = tloc - padding
                    else loc = tloc + padding end
    end

    cam[index] = loc

    local corner = loc - length/2
    local ending = cam.limit[end_char[index]] + end_fix[index]
    local begin  = cam.limit[index]

    if corner + length > ending then corner = ending - length end 
    if corner < begin           then corner = begin           end

    return corner
end


return UpdateCamera