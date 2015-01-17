local System; import 'ecs'
local DoubleStandard = class(System)

function DoubleStandard:requires()
    return {'DoubleStandardJump', 'jumpState', 'body'}
end

function DoubleStandard:update(e, dt, jump, state, body)
    local vx, vy = e.vx, e.vy
    local def = jump.def
    if vx > def.djumpMaxVx then vx = def.djumpMaxVx end
    e.physic_change:setLinearVelocity(vx, -def.djumpUp)
    state.state = 'fall'
    e.DoubleStandardJump = nil
end

return DoubleStandard