local System; import 'ecs'
local PlayerFalling = class(System)

function PlayerFalling:requires()
    return {'ground', 'jumpState'}
end

function PlayerFalling:update(e, _, ground, jumpState)
    e.falling = false

    if ground.on then return end
    
    if jumpState.state ~= "fall" then return end

    --local jump = self:getDoubleJumpStateMachine()
    --jump:next(2)

    e.falling = true
end

return PlayerFalling