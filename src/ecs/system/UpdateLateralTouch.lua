local System; import 'ecs'
local UpdateLateralTouch = class(System)

function UpdateLateralTouch:requires()
	return {'touch', 'body'}
end

function UpdateLateralTouch:update(e, _, touch, body)
    touch.on = body.lateralTouch
end


return UpdateLateralTouch