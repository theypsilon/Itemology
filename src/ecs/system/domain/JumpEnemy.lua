local System; import 'ecs'
local Data; import()
local JumpEnemy = class(System)

function JumpEnemy:requires()
    return {'jump_enemy'}
end

function JumpEnemy:update(e, _, jump_enemy)
    if e.bounce < e.ticks then
        if e._name == 'Player' then
            local P = require 'entity.particle.Animation'
            jump_enemy.level:add(P(jump_enemy.level, Data.animation.Goomba, 'die', jump_enemy.pos))
            jump_enemy.removed = true
        end
        e.reaction_pack = {jump_enemy, nil}
        e.bounce = e.ticks + 2
    end
    e.jump_enemy = nil
end

return JumpEnemy