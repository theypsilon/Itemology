local System; import 'ecs'
local Falcon = class(System)

function Falcon:requires()
    return {'FalconJump', 'jumpState', 'body'}
end

function Falcon:update(e, dt, jump, state, body)
    jump.sm()
    if jump.sm.finished == true then
        e.FalconJump = nil
        state.state  = 'fall'
    end
end

return Falcon