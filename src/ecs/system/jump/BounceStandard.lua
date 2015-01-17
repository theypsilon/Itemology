local System; import 'ecs'
local BounceStandard = class(System)

function BounceStandard:requires()
    return {'BounceStandardJump', 'jumpState', 'body'}
end

function BounceStandard:update(e, dt, jump, state, body)
    local vx, vy = e.vx, e.vy
    local def    = jump.def
    if vx > def.djumpMaxVx then vx = def.djumpMaxVx end
    e.physic_change:setLinearVelocity(vx, -def.djumpUp)
    state.state = 'fall'
    e.BounceStandardJump = nil
end

return BounceStandard