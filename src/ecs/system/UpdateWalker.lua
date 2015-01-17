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

    if not e.physic_change.setLinearVelocity then
        die(e.physic_change)
    end

    if dir.x ~= 0 and abs(v.x) < maxVel then
        local vel = maxVel - abs(v.x)
        local change = (vel * factor * force * dir.x * dt)
        apply = v.x + change
    end

    if v.x ~= 0 then
        force = force / 10
        if dir.x == 0 and ground then
            -- if fast, slowdown is weaker
            local slowdown = abs(v.x) > def.maxVxWalk and def.slowRun or def.slowWalk
            local vel = apply and apply or v.x
            apply = vel * slowdown * force
        end

        if dir.x * v.x < 0 then
            local margin = abs(v.x - (sig(dir.x) * maxVel))

            -- if fast, slowdown is weaker
            local slowdown = abs(v.x) > def.maxVxWalk and def.slowRun or def.slowWalk
            local vel = apply and apply or v.x
            local change = margin * slowdown * force * dir.x * .1
            apply = vel + change
        end
    end

    if apply then e.body:setLinearVelocity(apply, e.vy) end
end

return UpdateWalker