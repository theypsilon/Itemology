local System; import 'ecs'
local WallStandard = class(System)

function WallStandard:requires()
    return {'WallStandardJump', 'jumpState', 'body'}
end

local abs = math.abs

function WallStandard:update(e, dt, jump, state, body)
    local touch = state.sliding
    local def = jump.def
    local dx = e.dx

    body:setLinearVelocity(
        -touch * ( def.wjumpVxPlus + abs(dx) * def.wjumpVxBase ),
        -def.wjumpUp
    )
    state.state = 'fall'
    e.WallStandardJump = nil
end

return WallStandard