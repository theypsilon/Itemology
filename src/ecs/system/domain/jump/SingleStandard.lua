local System; import 'ecs'
local SingleStandard = class(System)

function SingleStandard:requires()
    return {'SingleStandardJump', 'jumpState', 'physic_change'}
end

function SingleStandard:update(e, dt, jump, state, physic_change)
    local vy = jump.def[jump.step]
    physic_change:setLinearVelocity(e.vx, -vy)
    jump.step = jump.step + 1
    if not (jump.step <= #jump.def and jump.action.jump) then
        state.state = 'fall'
        e.SingleStandardJump = nil
    end
end

return SingleStandard