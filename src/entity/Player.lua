local Animation, Physics, Text, Data, Tasks, Update, Job; import()
local Mob , Position; import 'entity'
local Move, Jump, Collision, InputPower; import 'entity.player'

local Player = class(Mob, Move, Jump, Collision, InputPower)

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

    self.hp = 3
    self.damage = {}
    Text:debug(self, 'hp')

    local _
    _, self.limit_map_y = level.map:getBorder()

    self.moveDef = def.move

    self.prop:setPriority(5000)

    level.player = self
end

function Player:tick(dt)

    self.tasks()

    self. x, self. y  = self.pos.x, self.pos.y
    self.vx, self.vy  = self.body:getLinearVelocity()
    self.dx           = -1 * self.dir.left + self.dir.right    

    self:move(dt)

    if self.y > self.limit_map_y then 
        local spawn = self.level.map('objects')('start')
        self.pos:set(spawn.x, spawn.y)
        self.body:setLinearVelocity(0, 0)
    end

    self:applyDamage()

    self:animate()

	Mob.tick(self)
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

function Player:hurt(enemy)
    self.damage[enemy] = 1
end

local healthyMask = Data.fixture.Filters.M_FRIEND
local woundedMask = healthyMask - Data.fixture.Filters.C_ENEMY

local PText = require 'entity.particle.JumpingText'
local PAnim = require 'entity.particle.Animation'

function Player:applyDamage()
    local dmg = 0
    for enemy,hp in pairs(self.damage) do
        if not enemy.removed then dmg = dmg + hp end
        self:reaction(enemy)
    end

    self.damage = {}

    if dmg > 0 and not self.wounded then

        self.hp = self.hp - dmg
        if self.hp <= 0 then 
            self.level:add(
                PAnim(self.level, Data.animation.TinyMario, 'die', self))
            self:remove() 
        end
        self.level:add(PText(self.level, tostring(-dmg), self.x, self.y))
        self:maskFixtures{area = woundedMask}

        self.wounded = true
        local layer  = self.level.map('platforms').layer

        self.tasks:set('wounded', Job.interval(function(c)
            local  n = c.ticks % 10
            if     n == 0 then layer:removeProp(self.prop)
            elseif n == 5 then layer:insertProp(self.prop) end
        end, 0, 100)):after(function(c) 
            self:maskFixtures(healthyMask)
            self.wounded = nil
            c:next() 
        end)
        
    end

end

function Player:reaction(enemy)
    local ex, ey = enemy.x, enemy.y
    local mx, my = self.pos:get()

    local dx, dy = ex - mx, ey - my
    local max = math.sqrt(dx*dx + dy*dy)
    local rx, ry = dx / max, dy / max
    local ix, iy = -rx*250, -ry*200 * (self.keyJump and 1.5 or 1)

    if enemy.removed then
        local _
        ix, _  = self.body:getLinearVelocity()
    else
        ix, iy = ix * 1.5, iy * .5
    end

    self.body:setLinearVelocity(ix, iy)

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