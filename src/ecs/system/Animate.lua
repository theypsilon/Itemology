local System; import 'ecs'
local Animate = class(System)

local Mob = require 'entity.Mob'

function Animate:requires()
	return {'animation'}
end

function Animate:update(e, dt)
    if e.animate then e:animate()
    elseif e.tick then e:tick()
    else e.animation:next() end
end


return Animate