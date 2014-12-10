local System; import 'ecs'
local UpdateWalker = class(System)

function UpdateWalker:requires()
	return {'walk', 'direction', 'velocity', 'moveDef', 'body'}
end

local abs = math.abs
local function sig(v) return v > 0 and 1 or v < 0 and -1 or 0 end

function UpdateWalker:update(e, dt, walk, dir, v, def, body)
	assert(dir.x ~= nil)

    dt           = 1 / (dt * def.timeFactor)

	local maxVel = e.action and (e.action.run and def.maxVxRun) or def.maxVxWalk
	local force, ground = 10, true

	if e.ground then 
		ground = e.ground.on
		force  = e.ground.on and def.ogHorForce or def.oaHorForce
	end

    if dir.x ~= 0 then
        local vel = maxVel - abs(v.x)
        if abs(vel) > maxVel and sig(vel) == dir.x then vel = -vel end
        body:applyForce( dt * dir.x * force * vel, 0)

    end

    if v.x ~= 0 and (dir.x*v.x < 0 or (dir.x == 0 and ground)) then
        -- if fast, slowdown is weaker
        local slowdown = abs(v.x) > maxVel and def.slowRun or def.slowWalk
        body:applyForce(-dt * v.x * force * slowdown, 0)
    end
end

return UpdateWalker