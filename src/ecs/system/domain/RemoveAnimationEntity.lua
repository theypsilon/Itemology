local System; import 'ecs'
local RemoveAnimationEntity = class(System)

function RemoveAnimationEntity:requires()
    return {'animation_result', 'animation_entity'}
end

function RemoveAnimationEntity:update(e, dt, result)
    if not result.alive then
        e.removed = true
    end
end

return RemoveAnimationEntity