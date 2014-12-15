local System; import 'ecs'
local ReactionPlayer = class(System)

function ReactionPlayer:requires()
    return {'reaction_pack'}
end

function ReactionPlayer:update(e, _, reaction_pack)
    local enemy, attacker = unpack(reaction_pack)
    self:reaction(e, enemy, attacker)
    e.reaction_pack = nil
end

function ReactionPlayer:reaction(e, enemy, attacker)
    local ex, ey = enemy.pos.x, enemy.pos.y
    local mx, my =  e.pos.x,  e.pos.y

    local dx, dy = ex - mx, ey - my
    local max    = math.sqrt(dx*dx + dy*dy)
    local rx, ry = dx / max, dy / max

    if not attacker then
        local iy = ry > .75 and -250 
                or ry > .50 and -235
                or ry > .25 and -210
                or              -190

        local px = e.vx * e.dx
        local ix = px > 0 and e.vx or px < 0 and 0 or e.vx / 2

        e.body:setLinearVelocity(ix, iy * (e.action.jump and 1.4 or 1))

        --e.physics.onEnemy = true
    else
        local ix, iy = 
            -rx*250 * (e.action.run  and 1.60 or 1.05), 
            -ry*100 * (e.action.jump and 3.00 or 1)

        e.body:applyLinearImpulse(ix * 1.1, iy * .5)
    end
    
end

return ReactionPlayer