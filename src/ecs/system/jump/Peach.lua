local System; import 'ecs'
local Peach = class(System)

function Peach:requires()
    return {'PeachJump', 'jumpState', 'body'}
end

function Peach:update(e, dt, jump, state, body)
    Peach[jump.state](e, dt, jump, state, body)
end

function Peach.set_walk(e, dt, jump, state, body)
    jump.gravity = body:getGravityScale()
    jump.walk = e.walk
    e.walk = nil
    e.walk_peach = true

    body:setGravityScale(jump.def.pjumpGravity)
end

function Peach.state_1(e, dt, jump, state, body)
    Peach.set_walk(e, dt, jump, state, body)
    jump.fly = jump.def.pjumpFlyTime
    jump.rep = e.moveDef.pjumpRepeat
    jump.state = "state_2"
end

function Peach.state_2(e, dt, jump, state, body)
    local fly = jump.fly
    if e.action.jump and fly > 0 then
        e.body:setLinearVelocity(e.vx, 0)
        jump.fly = fly - 1
    else
        jump.state = "state_3"
    end
end

function Peach.state_3(e, dt, jump, state, body)
    if e.walk_peach then
        e.walk_peach = nil
        e.walk = jump.walk
        body:setGravityScale(jump.gravity)
    end
    if e.ground.on or jump.fly == 0 then
        e.walk_peach = nil
        e.walk = jump.walk
        e.PeachJump = nil
        state.state = "fall"
    elseif e.action.jump and jump.fly > 0 and jump.rep > 0 then
        Peach.set_walk(e, dt, jump, state, body)
        jump.rep = jump.rep - 1
        jump.state = "state_2"
    end
end

return Peach