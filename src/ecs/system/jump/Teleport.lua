local System; import 'ecs'
local Physics; import()
local Teleport = class(System)

function Teleport:requires()
    return {'TeleportJump', 'jumpState', 'physic_change'}
end

function Teleport:update(e, dt, jump, state, physic_change)
    Teleport[jump.state](e, dt, jump, state, physic_change)
end

function Teleport.state_1(e, dt, jump, state, physic_change)
    local vx, vy, dx, dy = e.vx, e.vy, e.dx, e.dy
    local vdx, vdy = vx > 50 and 1 or vx < -50 and -1 or dx,
                     vy > 50 and 1 or vy < -50 and -1 or dy

    local x, y = dx ~= -vdx and dx or 0, dy ~= -vdy and dy or 0

    if y == 1 then y = 0 end

    if x == 0 and y == 0 then y = -1 end

    local factor = (x ~= 0 and y ~= 0)   and
        jump.def.tjumpDiagonalFactor or
        jump.def.tjumpStraightFactor

    local tx, ty = e.pos.x + (x * factor), e.pos.y + (y * factor)

    physic_change:setActive(false)
    local hit, hx, hy, fix = Physics.world:getRayCast(
        e.pos.x,
        e.pos.y,
        tx, ty
    )
    physic_change:setActive(true )

    if hit then tx, ty = hx - (x*10), hy - (y*10) end

    physic_change:setTransform(tx, ty)
    physic_change:setLinearVelocity(vx, 0)

    local freezing = jump.def.tjumpFreezing
    if freezing > 0 then
        e.moveVertical = nothing
        jump.gravity = physic_change:getGravityScale()
        physic_change:setGravityScale(0)
        jump.freezing = freezing
        jump.tx = tx
        jump.ty = ty
        jump.state = "state_2"
    else
        Teleport.state_4(e, dt, jump, state, physic_change)
    end
end

function Teleport.state_2(e, dt, jump, state, physic_change)
    local freezing = jump.freezing
    if not e.action.jump or freezing <= 0 then
        jump.state = "state_3"
    end
    physic_change:setTransform(jump.tx, jump.ty)
    jump.freezing = freezing - 1
end

function Teleport.state_3(e, dt, jump, state, physic_change)
    physic_change:setGravityScale(jump.gravity)
    e.moveVertical = nil
    Teleport.state_4(e, dt, jump, state, physic_change)
end

function Teleport.state_4(e, dt, jump, state, physic_change)
    e.TeleportJump = nil
    state.state  = 'fall'
end

return Teleport