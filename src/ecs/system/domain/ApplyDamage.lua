local Data; import()
local System; import 'ecs'
local ApplyDamage = class(System)

function ApplyDamage:requires()
    return {'damage', 'level', 'hp', 'ticks', 'pos'}
end

local healthyMask = Data.fixture.Filters.M_FRIEND
local woundedMask = healthyMask - Data.fixture.Filters.C_ENEMY

local PText = require 'entity.particle.JumpingText'
local PAnim = require 'entity.particle.Animation'

function ApplyDamage:update(e, dt, damage, level, hp, ticks, pos)
    local dmg = 0

    for enemy, expire in pairs(damage) do
        if enemy.removed then
            damage[enemy] = nil
        elseif ticks >= expire then 
            dmg = dmg + 1
            e.reaction_pack = {enemy, true}
            damage[enemy] = nil
        end
    end

    if dmg > 0 and e.wounded == nil then

        e.hp = hp - dmg
        if e.hp <= 0 then 
            level:add(PAnim(level, Data.animation.TinyMario, 'die', pos))
            e.removed = true
        end
        level:add(PText(level, tostring(-dmg), pos.x, pos.y))
        e.mask_fixture = {area = woundedMask}

        e.wounded = 0
    end
end

return ApplyDamage