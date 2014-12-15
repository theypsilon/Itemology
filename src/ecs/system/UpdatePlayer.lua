local Data; import()
local System; import 'ecs'
local UpdatePlayer = class(System)

local Mob = require 'entity.Mob'
local Text = require 'Text'

function UpdatePlayer:requires()
	return {'player', 'action'}
end

local function to(bool) return bool and 1 or 0 end

local healthyMask = Data.fixture.Filters.M_FRIEND
local woundedMask = healthyMask - Data.fixture.Filters.C_ENEMY

local PText = require 'entity.particle.JumpingText'
local PAnim = require 'entity.particle.Animation'

function UpdatePlayer:applyDamage(e)
    local dmg = 0

    local ticks = e.ticks

    for enemy, expire in pairs(e.damage) do
        if enemy.removed then
            e.damage[enemy] = nil
        elseif ticks >= expire then 
            dmg = dmg + 1
            e.reaction_pack = {enemy, true}
            e.damage[enemy] = nil
        end
    end

    if dmg > 0 and e.wounded == nil then

        e.hp = e.hp - dmg
        if e.hp <= 0 then 
            e.level:add(
                PAnim(e.level, Data.animation.TinyMario, 'die', e.pos))
            e:remove()
        end
        e.level:add(PText(e.level, tostring(-dmg), e.pos.x, e.pos.y))
        e.mask_fixture = {area = woundedMask}

        e.wounded = 0
    end

end

function UpdatePlayer:update(e, dt, player, action)

    e.dx           = -1 * to(action.left) + to(action.right)
    e.dy           = -1 * to(action.up  ) + to(action.down )
    e.dt           = 1 / (dt * e.moveDef.timeFactor)

    Text:console( iter(e.tasks.callbacks)
        :map(function(k, v) return {k, is_object(v) and v.cur} end)
        :totable())

    e.tasks()

    self:applyDamage(e)
end

return UpdatePlayer