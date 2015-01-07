local System; import 'ecs'
local Space = class(System)

function Space:requires()
    return {'SpaceJump', 'jumpState', 'body'}
end

function Space:update(e, dt, jump, state, body)
    Space[jump.state](e, dt, jump, state, body)
end

function Space.state_1(e, dt, jump, state, body)
    local def = e.moveDef

    jump.gravity = body:getGravityScale()
    body:setGravityScale(jump.def.sjumpGravity)

    local maxFallSp = jump.def.sjumpMaxFallSpeed
    jump.state = "state_2"
    jump.step  = 0
    Space.state_2(e, dt, jump, state, body)
end

function Space.state_2(e, dt, jump, state, body)
    local step = jump.step + 1
    jump.step = step
    if step == #jump.def.jumpImp or not e.action.jump then
        jump.state = "state_3"
        if not e.action.jump then return end
    end
    body:applyLinearImpulse(0, -150)
end

function Space.state_3(e, dt, jump, state, body)
    if e.ground.on then
        jump.state = "state_4"
        return
    end
    local maxFallSp = jump.def.sjumpMaxFallSpeed
    if e.vy > maxFallSp then body:setLinearVelocity(e.vx, maxFallSp) end
end

function Space.state_4(e, dt, jump, state, body)
    body:setGravityScale(jump.gravity)
    e.SpaceJump = nil
    state.state = 'fall'
end

return Space