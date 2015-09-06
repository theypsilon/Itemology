local System; import 'ecs'
local UpdateTicks = class(System)

function UpdateTicks:requires()    return {'ticks'}      end
function UpdateTicks:update(e, dt)
    e.ticks = e.ticks + 1
end

return UpdateTicks