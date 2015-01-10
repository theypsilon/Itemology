local System; import 'ecs'
local AnimateJumper = class(System)

function AnimateJumper:requires()
    return {'animation_jumper', 'vx', 'vy', 'moveDef', 'action'}
end

local abs = math.abs
function AnimateJumper:update(e, dt, animation, vx, vy, def, action)
    local extra, maxVxWalk = animation.extra, def.maxVxWalk

    if abs(vx) > extra.toleranceX then 
        e.lookLeft = vx < 0
        if abs(vy) < extra.toleranceY  then 
            animation:setAnimation(
                abs(vx)*extra.walkRunUmbral <= maxVxWalk and 'walk' or 'run')
        end
    else 
        animation:setAnimation('stand')
    end

    local dx = -1* (action.left and 1 or 0) + (action.right and 1 or 0)
    if abs(vy) > extra.toleranceY then
        animation:setAnimation(abs(vx)*extra.walkRunUmbral <= maxVxWalk and
            'jump' or (vy < 0) and
            'fly'  or 'fall')
    elseif dx*vx < 0 then
        animation:setAnimation('skid')
    end

    animation:setMirror(e.lookLeft == true)
    animation:next()
end

return AnimateJumper