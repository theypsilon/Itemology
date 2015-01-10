local System; import 'ecs'
local Animate = class(System)

function Animate:requires()
	return {'animation'}
end

function Animate:update(e, dt, animation)
    local animation_result = e.animation_result
    if animation_result then
        animation_result.changed, animation_result.alive = animation:next()
    else
        animation:next()
    end
end


return Animate