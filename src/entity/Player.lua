local super = require 'entity.Mob'

local Position, Animation, physics, input = require 'entity.Position', require 'Animation', require 'Physics', require 'Input'
local task, flow, Text = require 'TaskQueue', require 'Flow', require 'Text'

local Player = class('Player', super, require 'entity.player.Move')

function Player:_init(level, def, p)
	super._init(self, level, p.x, p.y)

    self.animation = Animation(def.animation)
    self.prop      = self.animation.prop

    self.body = physics:registerBody(def.fixture, self.prop, self)

    require('entity.player.Collision')._setListeners(self)
    self:_setInput(p)
    self:_setPower(p)
    self:_setInitialMove(p)

    self.pos = Position(self.body)
    self.pos:set(p.x, p.y)

    self.hp = 3
    self.wounded = 0
    self.damage = {}
    Text:debug(self, 'hp')

    local _
    _, self.limit_map_y = level.map:getBorder()

    self.moveDef = def.move

    self.prop:setPriority(5000)

    level.player = self
end

function Player:_setInput()

    -- walk
    self.dir = {left = 0, right = 0, up = 0, down = 0}
    for k,_ in pairs(self.dir) do
        input.bindAction(k, function() self.dir[k] = 1 end, function() self.dir[k] = 0 end)
    end

    -- jump
    input.bindAction('b2', 
        function() self.keyJump = true end, 
        function() self.keyJump = false; self:resetJump() end)

    -- run
    input.bindAction('b1', function() self.keyRun = true end, function() self.keyRun = false end)

    -- debug - print location
    input.bindAction('r', function() 
        print(self.pos:get())
        self:wallhack(true)
    end, function() self:wallhack(false) end)    
end

function Player:_setPower()
    self.power = {djump = 0}
    Text:debug(self.power, 'djump')
end

local abs = math.abs

function Player:tick(dt)

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

	super.tick(self)
end

function Player:animate()
    local def, maxVxWalk = self.animation.extra, self.moveDef.maxVxWalk

    local vx, vy = self.vx, self.vy

    if abs(vx) > def.toleranceX then 
        self.lookLeft = vx < 0
        if abs(vy) < def.toleranceY  then 
            self.animation:setAnimation(abs(vx)*def.walkRunUmbral <= maxVxWalk and 'walk' or 'run') 
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

    if self.wounded > 0 then
        local layer = self.level.map('platforms').layer
        if self.wounded % 10 == 0 then
            layer:removeProp(self.prop)
        elseif self.wounded % 10 == 5 then
            layer:insertProp(self.prop)
        end
    end
end

function Player:hurt(enemy)
    self.damage[enemy] = 1
end

function Player:applyDamage()
    local dmg = 0
    for enemy,hp in pairs(self.damage) do
        if not enemy.removed then dmg = dmg + hp end
        self:reaction(enemy)
    end

    if self.wounded > 0 then
        self.wounded = self.wounded - 1
        self.damage  = {}
        return
    end

    if dmg > 0 then
        self.wounded = 100
        self.hp = self.hp - dmg
        local PText = require 'entity.particle.JumpingText'
        local PAnim = require 'entity.particle.Animation'
        if self.hp <= 0 then 
            self.level:add(PAnim(self.level, data.animation.TinyMario, 'die', self))
            self:remove() 
        end
        self.level:add(PText(self.level, tostring(-dmg), self.x, self.y))
    end

    self.damage = {}
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

function Player:draw(...)
	super.draw(self, ...)
end

return Player