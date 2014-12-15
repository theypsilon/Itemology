local System; import 'ecs'
local JumpEnemy = class(System)

function JumpEnemy:requires()
    return {'jump_enemy'}
end

function JumpEnemy:update(e, _, jump_enemy)
    if e.bounce < e.ticks then
        jump_enemy:hurtBy(e)
        e.reaction_pack = {jump_enemy, nil}
        e.bounce = e.ticks + 2
    end
    e.jump_enemy = nil
end

return JumpEnemy