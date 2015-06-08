local System; import 'ecs'
local WallStandard = class(System)

function WallStandard:requires()
    return {'WallStandardJump', 'jumpState', 'physic_change'}
end

local abs = math.abs

function WallStandard:update(e, dt, jump, state, physic_change)
    local touch = state.sliding
    local def = jump.def
    local dx = e.dx

    physic_change:setLinearVelocity(
        -touch * ( def.wjumpVxPlus + abs(dx) * def.wjumpVxBase ),
        -def.wjumpUp
    )
    state.state = 'fall'
    e.WallStandardJump = nil
end

return WallStandard