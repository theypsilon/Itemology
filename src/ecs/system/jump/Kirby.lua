local System; import 'ecs'
local Kirby = class(System)

function Kirby:requires()
    return {'KirbyJump', 'jumpState', 'body'}
end

function Kirby:update(e, dt, jump, state, body)
    jump.sm()
    if jump.sm.finished == true then
        e.KirbyJump = nil
        state.state  = 'fall'
    end
end

return Kirby