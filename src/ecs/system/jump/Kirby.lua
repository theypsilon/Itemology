local DoubleStandard; import 'ecs.system.jump'
local System; import 'ecs'
local Kirby = class(System)

function Kirby:requires()
    return {'KirbyJump', 'jumpState', 'body'}
end

function Kirby:update(e, dt, jump, state, body)
    Kirby[jump.state](e, dt, jump, state, body)
end

local function doDoubleStandard(e, dt, body, jump)
    DoubleStandard.update(nil, {vx=e.vx, vy=e.vy}, dt, {def=jump.def}, {}, body)
end

function Kirby.state_1(e, dt, jump, state, body)
    doDoubleStandard(e, dt, body, jump)
    jump.cadence = jump.def.kjumpCadenceTime
    jump.state = "state_2"
    jump.step  = 0
end

function Kirby.state_2(e, dt, jump, state, body)
    local time = jump.def.kjumpFullTime
    jump.step = jump.step + 1
    local step = jump.step
    if not e.action.jump then jump.state = "state_3" end
    if e.ground.on or step > time then jump.state = "state_4" end
    local maxFallSp = jump.def.kjumpFallSpeedLimit
    if e.vy > maxFallSp then body:setLinearVelocity(e.vx, maxFallSp) end
    if e.action.run then jump.state = "state_4" end
end

function Kirby.state_3(e, dt, jump, state, body)
    local time = jump.def.kjumpFullTime
    jump.step = jump.step + 1
    local step = jump.step
    if e.action.jump then
        if jump.cadence <= step then
            doDoubleStandard(e, dt, body, jump)
            jump.cadence = step + jump.def.kjumpCadenceTime
        end
        jump.state = "state_2"
        return
    end
    if e.action.run then c:exit() end
    if e.ground.on or step > time then jump.state = "state_4" end
    local maxFallSp = jump.def.kjumpFallSpeedLimit
    if e.vy > maxFallSp then body:setLinearVelocity(e.vx, maxFallSp) end
end

function Kirby.state_4(e, dt, jump, state, body)
    e.KirbyJump = nil
    state.state = "fall"
end

return Kirby