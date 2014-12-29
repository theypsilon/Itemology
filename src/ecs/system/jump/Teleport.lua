local System; import 'ecs'
local Teleport = class(System)

function Teleport:requires()
    return {'TeleportJump', 'jumpState', 'body'}
end

function Teleport:update(e, dt, jump, state, body)
    jump.sm()
    if jump.sm.finished == true then
        e.TeleportJump = nil
        state.state  = 'fall'
    end
end

return Teleport