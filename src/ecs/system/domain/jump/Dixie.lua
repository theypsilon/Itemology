local System; import 'ecs'
local Dixie = class(System)

function Dixie:requires()
    return {'DixieJump', 'jumpState', 'physic_change'}
end

function Dixie:update(e, dt, jump, state, physic_change)
    Dixie[jump.state](e, dt, jump, state, physic_change)
end

function Dixie.set_walk(e, dt, jump, state, physic_change)
    jump.gravity = physic_change:getGravityScale()
    jump.walk = e.walk
    e.walk = nil
    e.walk_peach = true

    physic_change:setGravityScale(jump.def.pjumpGravity)
end

function Dixie.state_1(e, dt, jump, state, physic_change)
    Dixie.set_walk(e, dt, jump, state, physic_change)
    jump.jump_time = jump.def.xjumpJumpTime
    jump.state = "state_2"

    if (not jump.def.xjumpRejumpFalling and state.state == "fall")
        or e.vy > jump.def.xjumpRejumpVyLimit then
        jump.state = "state_4"
    end
end

local abs = math.abs
local function sig(v) return v > 0 and 1 or v < 0 and -1 or 0 end

function Dixie.state_2(e, dt, jump, state, physic_change)
    jump.jump_time = jump.jump_time - 1
    if jump.jump_time <= 0 then
        jump.state = "state_3"
    end
    local speed, vxLimit = jump.def.xjumpJumpSpeed,
                           jump.def.xjumpJumpVertLimit
    local vx = abs(e.vx) < vxLimit and e.vx or sig(e.vx)*vxLimit
    physic_change:setLinearVelocity(vx, -speed)
end

function Dixie.state_3(e, dt, jump, state, physic_change)
    if e.ground.on or e.wounded then
        jump.state = "state_5"
    end

    local vxLimit = jump.def.xjumpJumpVertLimit

    if abs(e.vx) > vxLimit then
        physic_change:setLinearVelocity(vxLimit * sig(e.vx), e.vy)
    end

    if e.vy > jump.def.xjumpFallSpeedLimit then 
        physic_change:setGravityScale(jump.def.xjumpGravity * jump.gravity)
        jump.state = "state_4"
        Dixie.state_4(e, dt, jump, state, physic_change)
    end
end

function Dixie.state_4(e, dt, jump, state, physic_change)
    if not e.action.jump or e.ground.on or e.wounded then
        jump.state = "state_5"
    end

    local v = jump.def.xjumpFallSpeedLimit
    if e.vy > v then
        physic_change:setLinearVelocity(e.vx, v )
    end
end

function Dixie.state_5(e, dt, jump, state, physic_change)
    physic_change:setGravityScale(jump.gravity)
    e.walk_peach = nil
    e.walk = jump.walk
    e.DixieJump = nil
    state.state = "fall"
end

return Dixie