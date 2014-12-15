local Data; import()
local System; import 'ecs'
local WoundedPlayer = class(System)

function WoundedPlayer:requires()
    return {'wounded'}
end

local healthyMask = Data.fixture.Filters.M_FRIEND

function WoundedPlayer:update(e, _, wounded)
    local layer = e.level.map('platforms').layer

    local n = wounded % 10

    if     n == 0 then layer:removeProp(e.prop)
    elseif n == 5 then layer:insertProp(e.prop) end

    wounded = wounded + 1

    if wounded == 100 then
        e.mask_fixture = healthyMask
        wounded = nil
    end

    e.wounded = wounded
end

return WoundedPlayer