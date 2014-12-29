local System; import 'ecs'
local Space = class(System)

function Space:requires()
    return {'SpaceJump', 'jumpState', 'body'}
end

function Space:update(e, dt, jump, state, body)
    jump.sm()
    if jump.sm.finished == true then
        e.SpaceJump = nil
        state.state  = 'fall'
    end
end

return Space