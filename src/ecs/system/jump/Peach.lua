local System; import 'ecs'
local Peach = class(System)

function Peach:requires()
    return {'PeachJump', 'jumpState', 'body'}
end

function Peach:update(e, dt, jump, state, body)
    jump.sm()
    if jump.sm.finished == true then
        e.PeachJump = nil
        state.state  = 'fall'
    end
end

return Peach