local System; import 'ecs'
local Dixie = class(System)

function Dixie:requires()
    return {'DixieJump', 'jumpState', 'body'}
end

function Dixie:update(e, dt, jump, state, body)
    jump.sm()
    if jump.sm.finished == true then
        e.DixieJump = nil
        state.state  = 'fall'
    end
end

return Dixie