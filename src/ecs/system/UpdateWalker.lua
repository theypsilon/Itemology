local System; import 'ecs'
local UpdateWalker = class(System)

function UpdateWalker:requires()
	return {'walk', 'direction', 'velocity', 'moveDef', 'body'}
end

local abs = math.abs
local function sig(v) return v > 0 and 1 or v < 0 and -1 or 0 end

local factor = 0.1/6.0

function UpdateWalker:update(e, dt, walk, dir, v, def, body)
	assert(dir.x ~= nil)

    dt           = 1 / (dt * def.timeFactor)

	local maxVel = e.action and (e.action.run and def.maxVxRun) or def.maxVxWalk
	local force, ground = 10, true

	if e.ground then 
		ground = e.ground.on
		force  = e.ground.on and def.ogHorForce or def.oaHorForce
	end

    local apply

    if dir.x ~= 0 and abs(v.x) < maxVel then
        local vel = maxVel - abs(v.x)
        apply = v.x + (vel * factor * force * dir.x * dt)
    end

    if v.x ~= 0 then
        if dir.x == 0 and ground then
            -- if fast, slowdown is weaker
            local slowdown = abs(v.x) > maxVel and def.slowRun or def.slowWalk
            local vel = apply and apply or v.x
            apply = vel * slowdown * (force / 10)
        end

        if dir.x * v.x < 0 then
            if e._name == "Player" then print(dir.x, apply) end
            -- if fast, slowdown is weaker
            local slowdown = abs(v.x) > maxVel and def.slowRun or def.slowWalk
            local vel = apply and apply or v.x
            apply = vel * slowdown * (force / 10)
        end
    end

    if apply then body:setLinearVelocity(apply, e.vy) end
end

return UpdateWalker