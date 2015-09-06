local System; import 'ecs'
local UpdateCamera = class(System)

function UpdateCamera:requires()
	return {'cam'}
end

function UpdateCamera:update(e, _, cam)
    if not e._target then return end
    local area = e.area

    local x = self:_calcCorner(e, 'x', area.w) - area.x
    local y = self:_calcCorner(e, 'y', area.h) - area.y

    if e._last_x and e._last_y then
        local dx, dy = x - e._last_x, y - e._last_y

        if math.abs(dx) > 16 then x = e._last_x + (dx > 0 and 16 or -16) end
        if math.abs(dy) > 16 then y = e._last_y + (dy > 0 and 16 or -16) end
    end

    e._last_x = x
    e._last_y = y

    cam:setLoc(x, y, e.z)
end

local end_char = {x = 'w', y = 'h'}
local end_fix  = {x = -48, y = -24}

local abs = math.abs
function UpdateCamera:_calcCorner(e, index, length)
    local padding = e.padding[index]
    local tloc    = e._target.pos and e._target.pos[index] or e._target[index]
    local  loc    = e[index] or tloc
    local diff    = loc - tloc

    if abs(diff) > padding then
        if diff < 0 then loc = tloc - padding
                    else loc = tloc + padding end
    end

    e[index] = loc

    local corner = loc - length/2
    local ending = e._limit[end_char[index]] + end_fix[index]
    local begin  = e._limit[index]

    if corner + length > ending then corner = ending - length end 
    if corner < begin           then corner = begin           end

    return corner
end


return UpdateCamera