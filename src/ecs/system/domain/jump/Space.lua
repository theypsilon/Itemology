local System; import 'ecs'
local Space = class(System)

function Space:requires()
    return {'SpaceJump', 'jumpState', 'physic_change'}
end

function Space:update(e, dt, jump, state, physic_change)
    Space[jump.state](e, dt, jump, state, physic_change)
end

function Space.state_1(e, dt, jump, state, physic_change)
    jump.gravity = physic_change:getGravityScale()
    physic_change:setGravityScale(jump.def.sjumpGravity)

    local maxFallSp = jump.def.sjumpMaxFallSpeed
    jump.state = "state_2"
    jump.step  = 0
    Space.state_2(e, dt, jump, state, physic_change)
end

function Space.state_2(e, dt, jump, state, physic_change)
    local step = jump.step + 1
    jump.step = step
    if step == 30 or not e.action.jump then
        jump.state = "state_3"
        if not e.action.jump then return end
    end
    physic_change:setLinearVelocity(e.vx, -150)
end

function Space.state_3(e, dt, jump, state, physic_change)
    if e.ground.on then
        jump.state = "state_4"
        return
    end
    local maxFallSp = jump.def.sjumpMaxFallSpeed
    if e.vy > maxFallSp then physic_change:setLinearVelocity(e.vx, maxFallSp) end
end

function Space.state_4(e, dt, jump, state, physic_change)
    physic_change:setGravityScale(jump.gravity)
    e.SpaceJump = nil
    state.state = 'fall'
end

return Space