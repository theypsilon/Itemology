local System; import 'ecs'
local SenseLateralTouch = class(System)

function SenseLateralTouch:requires()
	return {'touch', 'body'}
end

function SenseLateralTouch:update(e, _, touch, body)
    touch.on = body.lateralTouch
end


return SenseLateralTouch