local System; import 'ecs'
local Physics; import()
local Teleport = class(System)

function Teleport:requires()
    return {'TeleportJump', 'jumpState', 'body'}
end

function Teleport:update(e, dt, jump, state, body)
    Teleport[jump.state](e, dt, jump, state, body)
end

function Teleport.state_1(e, dt, jump, state, body)
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

    body:setActive(false)
    local hit, hx, hy, fix = Physics.world:getRayCast(
        e.pos.x,
        e.pos.y,
        tx, ty
    )
    body:setActive(true )

    if hit then tx, ty = hx - (x*10), hy - (y*10) end

    body:setTransform(tx, ty)
    e.physic_change:setLinearVelocity(vx, 0)

    local freezing = jump.def.tjumpFreezing
    if freezing > 0 then
        e.moveVertical = nothing
        jump.gravity = body:getGravityScale()
        body:setGravityScale(0)
        jump.freezing = freezing
        jump.tx = tx
        jump.ty = ty
        jump.state = "state_2"
    else
        Teleport.state_4(e, dt, jump, state, body)
    end
end

function Teleport.state_2(e, dt, jump, state, body)
    local freezing = jump.freezing
    if not e.action.jump or freezing <= 0 then
        jump.state = "state_3"
    end
    body:setTransform(jump.tx, jump.ty)
    jump.freezing = freezing - 1
end

function Teleport.state_3(e, dt, jump, state, body)
    body:setGravityScale(jump.gravity)
    e.moveVertical = nil
    Teleport.state_4(e, dt, jump, state, body)
end

function Teleport.state_4(e, dt, jump, state, body)
    e.TeleportJump = nil
    state.state  = 'fall'
end

return Teleport