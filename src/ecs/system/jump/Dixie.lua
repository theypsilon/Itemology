local System; import 'ecs'
local Dixie = class(System)

function Dixie:requires()
    return {'DixieJump', 'jumpState', 'body'}
end

function Dixie:update(e, dt, jump, state, body)
    Dixie[jump.state](e, dt, jump, state, body)
end

function Dixie.set_walk(e, dt, jump, state, body)
    jump.gravity = body:getGravityScale()
    jump.walk = e.walk
    e.walk = nil
    e.walk_peach = true

    body:setGravityScale(jump.def.pjumpGravity)
end

function Dixie.state_1(e, dt, jump, state, body)
    Dixie.set_walk(e, dt, jump, state, body)
    jump.jump_time = jump.def.xjumpJumpTime
    jump.state = "state_2"

    if (not jump.def.xjumpRejumpFalling and state.state == "fall")
        or e.vy > jump.def.xjumpRejumpVyLimit then
        jump.state = "state_4"
    end
end

local abs = math.abs
local function sig(v) return v > 0 and 1 or v < 0 and -1 or 0 end

function Dixie.state_2(e, dt, jump, state, body)
    jump.jump_time = jump.jump_time - 1
    if jump.jump_time <= 0 then
        jump.state = "state_3"
    end
    local speed, vxLimit = jump.def.xjumpJumpSpeed,
                           jump.def.xjumpJumpVertLimit
    local vx = abs(e.vx) < vxLimit and e.vx or sig(e.vx)*vxLimit
    e.body:setLinearVelocity(vx, -speed)
end

function Dixie.state_3(e, dt, jump, state, body)
    if e.ground.on or e.wounded then
        jump.state = "state_5"
    end

    local vxLimit = jump.def.xjumpJumpVertLimit

    if abs(e.vx) > vxLimit then
        e.body:setLinearVelocity(vxLimit * sig(e.vx), e.vy)
    end

    if e.vy > jump.def.xjumpFallSpeedLimit then 
        body:setGravityScale(jump.def.xjumpGravity * jump.gravity)
        jump.state = "state_4"
        Dixie.state_4(e, dt, jump, state, body)
    end
end

function Dixie.state_4(e, dt, jump, state, body)
    if not e.action.jump or e.ground.on or e.wounded then
        jump.state = "state_5"
    end

    local v = jump.def.xjumpFallSpeedLimit
    if e.vy > v then
        e.body:setLinearVelocity(e.vx, v )
    end
end

function Dixie.state_5(e, dt, jump, state, body)
    body:setGravityScale(jump.gravity)
    e.walk_peach = nil
    e.walk = jump.walk
    e.DixieJump = nil
    state.state = "fall"
end

return Dixie