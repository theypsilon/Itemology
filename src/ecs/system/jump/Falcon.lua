local System; import 'ecs'
local Falcon = class(System)

function Falcon:requires()
    return {'FalconJump', 'jumpState', 'body'}
end

function Falcon:update(e, dt, jump, state, body)
    Falcon[jump.state](e, dt, jump, state, body)
end

local abs = math.abs
function Falcon.state_1(e, dt, jump, state, body)
    local vx, vy = e.vx, e.vy
    local def    = jump.def

    local vlimit    = def.fjumpInitVLimit
    local ifactor   = def.fjumpInitVFactor

    if abs(vx) < vlimit then vx = 0
    else vx = vx > 0 and 1 or -1 end
    if abs(vy) < vlimit then vy = 0
    else vy = vy > 0 and 1 or -1 end

    jump.gravity = body:getGravityScale()

    body:setLinearVelocity(vx * ifactor, vy * ifactor)
    body:setGravityScale(def.fjumpGravity) --TODO NOT WORKING
    jump.walk = e.walk
    e.walk = nil
    jump.x = 0
    jump.y = 0
    jump.cancel = 0
    jump.step = def.fjumpChargeTime - 1
    jump.state = 'state_2'
end

function Falcon.is_cancelled(e, jump)
    local cancelled = jump.def.fjumpCancelValue
    local cancel = jump.cancel
    if e.action.jump == (cancel %2 == 1) then cancel = cancel + 1 end
    jump.cancel = cancel
    return cancel == cancelled
end

function Falcon.state_2(e, dt, jump, state, body)
    jump.x, jump.y = jump.x + e.dx, jump.y - e.dy
    if jump.step <= 0 then
        jump.state = "state_3"
    else
        jump.step = jump.step - 1
    end
    if Falcon.is_cancelled(e, jump) then
        Falcon.state_5(e, dt, jump, state, body)
    end
end

function Falcon.state_3(e, dt, jump, state, body)
    local def = jump.def
    local charge_m = def.fjumpMinChargeValue
    local charge_f = def.fjumpChargeFactor
    local x, y = jump.x, jump.y
    if abs(x) < charge_m and abs(y) < charge_m then
        jump.state = "state_5"
        return
    end
    jump.x, jump.y = x * charge_f, y * charge_f
    jump.cancel = 0
    jump.step = def.fjumpFlyTime - 1
    jump.state = "state_4"
end

function Falcon.state_4(e, dt, jump, state, body)
    body:setLinearVelocity(jump.x, jump.y)
    if jump.step <= 0 then
        jump.state = "state_5"
    else
        jump.step = jump.step - 1
    end
    if Falcon.is_cancelled(e, jump) then
        Falcon.state_5(e, dt, jump, state, body)
    end
end

function Falcon.state_5(e, dt, jump, state, body)
    e.walk = jump.walk
    body:setGravityScale(jump.gravity)
    e.FalconJump = nil
    state.state = "fall"
end

return Falcon