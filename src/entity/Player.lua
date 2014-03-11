local Animation, Physics, Text, Data, Tasks, Update, Job; import()
local Mob , Position; import 'entity'
local Move, Jump, Action, Special, Collision, InputPower; import 'entity.player'

local Player = class(Mob, Move, Jump, Action, Special, Collision, InputPower)

function Player:_init(level, def, p)
	Mob._init(self, level, p.x, p.y)

    self.animation = Animation(def.animation)
    self.prop      = self.animation.prop

    self.body = Physics:registerBody(def.fixture, self.prop, self)

    self:_setListeners(self)
    self:_setInput(p)
    self:_setPower(p)
    self:_setInitialMove(p)

    self.tasks = Tasks()

    self.pos = Position(self.body)
    self.pos:set(p.x, p.y)

    self.prop:setPriority(5000)

    self.player = true

    level.player = self

    local _
    _, self.limit_map_y = level.map:getBorder()

    self.moveDef = require 'data.motion.Mario'
    if self.moveDef.update then
        self.tasks:set('def_update', function()
            package.loaded  ['data.motion.Mario']   = nil
            self.moveDef = require 'data.motion.Mario'
        end, 40)
    end

    self.hp = self.moveDef.hitpoints
    self.damage = {}
    Text:debug(self, 'hp')
end

function Player:tick(dt)

    self. x, self. y  = self.pos:get()
    self.vx, self.vy  = self.body:getLinearVelocity()
    self.dx           = -1 * self.dir.left + self.dir.right
    self.dy           = -1 * self.dir.up   + self.dir.down
    self.dt           = 1 / (dt * self.moveDef.timeFactor)

    self.tasks()
    self:monitorTasks()
    self:move()

    if self.y > self.limit_map_y + 100 then self:remove() end

    self:applyDamage()

    self:animate()

	Mob.tick(self)
end

function Player:monitorTasks()
    Text:console( iter(self.tasks.callbacks)
        :map(function(k, v) return {k, is_object(v) and v.cur} end)
        :totable())
end

local abs = math.abs
function Player:animate()
    local def, maxVxWalk = self.animation.extra, self.moveDef.maxVxWalk

    local vx, vy = self.vx, self.vy

    if abs(vx) > def.toleranceX then 
        self.lookLeft = vx < 0
        if abs(vy) < def.toleranceY  then 
            self.animation:setAnimation(
                abs(vx)*def.walkRunUmbral <= maxVxWalk and 'walk' or 'run')
        end
    else 
        self.animation:setAnimation('stand')
    end

    local dx = -1*self.dir.left + self.dir.right
    if abs(vy) > def.toleranceY then
        self.animation:setAnimation(abs(vx)*def.walkRunUmbral <= maxVxWalk and
            'jump' or (vy < 0) and
            'fly'  or 'fall')
    elseif dx*vx < 0 then
        self.animation:setAnimation('skid')
    end

    self.animation:setMirror(self.lookLeft == true)
    self.animation:next()
end

function Player:hurtBy(enemy, delay)
    self.damage[enemy] = self._ticks + (delay and delay or 1)
end

local healthyMask = Data.fixture.Filters.M_FRIEND
local woundedMask = healthyMask - Data.fixture.Filters.C_ENEMY

local PText = require 'entity.particle.JumpingText'
local PAnim = require 'entity.particle.Animation'

function Player:applyDamage()
    local dmg = 0

    local ticks = self._ticks

    for enemy, expire in pairs(self.damage) do
        if enemy.removed then
            self.damage[enemy] = nil
        elseif ticks >= expire then 
            dmg = dmg + 1
            self:reaction(enemy, true)
            self.damage[enemy] = nil
        end
    end

    if dmg > 0 and not self:isWounded() then

        self.hp = self.hp - dmg
        if self.hp <= 0 then 
            self.level:add(
                PAnim(self.level, Data.animation.TinyMario, 'die', self.pos))
            self:remove()
        end
        self.level:add(PText(self.level, tostring(-dmg), self.pos.x, self.pos.y))
        self:maskFixtures{area = woundedMask}

        local layer  = self.level.map('platforms').layer

        self.tasks:set('wounded', Job.interval(function(c)
            local  n = c.ticks % 10
            if     n == 0 then layer:removeProp(self.prop)
            elseif n == 5 then layer:insertProp(self.prop) end
        end, 0, 100))

        :finally(function() self:maskFixtures(healthyMask) end)
    end

end

function Player:isWounded()
    return self.tasks.callbacks.wounded ~= nil
end

function Player:reaction(enemy, attacker)
    local ex, ey = enemy.x, enemy.y
    local mx, my = self.pos:get()

    local dx, dy = ex - mx, ey - my
    local max    = math.sqrt(dx*dx + dy*dy)
    local rx, ry = dx / max, dy / max

    if not attacker then
        local iy = ry > .75 and -250 
                or ry > .50 and -235
                or ry > .25 and -210
                or              -190

        local px = self.vx * self.dx
        local ix = px > 0 and self.vx or px < 0 and 0 or self.vx / 2

        self.body:setLinearVelocity(ix, iy * (self.keyJump and 1.4 or 1))

        self:reDoubleJump()
    else
        local ix, iy = 
            -rx*250 * (self.keyRun  and 1.60 or 1.05), 
            -ry*100 * (self.keyJump and 3.00 or 1)

        self.body:applyLinearImpulse(ix * 1.1, iy * .5)
    end
    
end

local function setFixtureMask(fix, mask)
    local categoryBits, maskBits, groupIndex = fix:getFilter()
    fix:setFilter(categoryBits, mask, groupIndex)
end

function Player:maskFixtures (value, name)
    if is_table(value) then
        for k, v in pairs(value) do self:maskFixtures(v, k) end
        return
    end

    assert(is_positive(value), tostring(value) .. ': is not positive')

    if is_string(name) then setFixtureMask(self.body.fixtures[name], value)
    else 
        for _,f in pairs(self.body.fixtures) do setFixtureMask(f, value) end
    end
end

function Player:removeMasksFixtures()
    local _, maskBits, _ = table.first(self.body.fixtures):getFilter()
    self:maskFixtures(0)
    self.removed_mask_fixtures = maskBits
end

function Player:restoreMaskFixtures()
    if is_nil(self.removed_mask_fixtures) then return end
    self:maskFixtures(self.removed_mask_fixtures)
    self.removed_mask_fixtures = nil
end

function Player:draw(...)
	Mob.draw(self, ...)
end

return Player