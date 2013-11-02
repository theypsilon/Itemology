local super = require 'entity.Mob'

local Position, Animation, physics, input = require 'entity.Position', require 'Animation', require 'Physics', require 'Input'
local task, flow, scenes = require 'TaskQueue', require 'Flow', require 'Scenes'
local collisions = {}

local Player = class.Player(super)

function Player:_init(level, def, prop)
	super._init(self, level, prop.x, prop.y)

    local def = data.entity.Player

    self.animation = Animation(def.animation)
    self.prop      = self.animation.prop

    self.body = physics:registerBody(def.fixture, self.prop, self)

    self:_setListeners()
    self:_setInput()

    self.pos = Position(self.body)
    self.pos:set(prop.x, prop.y)

    self.jumping = 0
    self.hp = 10
    self.damage = {}

    local _
    _, self.limit_map_y = level.map:getBorder()

    self.moveDef = def.move

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
        function() self.keyJump = false; self.jumping = 0 end)

    -- run
    input.bindAction('b1', function() self.keyRun = true end, function() self.keyRun = false end)
end

function Player:_setListeners()
    local begend = MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END 

    local fix = self.body.fixtures

    fix['area']:setCollisionHandler(collisions.area, begend)

    self.groundCount = 0

    for _,sensor in pairs{fix['sensor1'], fix['sensor2']} do
        sensor:setCollisionHandler(collisions.floorSensor, begend)
    end
end

local abs = math.abs

function Player:tick(dt)

    local vx, vy  = self.body:getLinearVelocity()

    self:move(dt, vx, vy)

	self.x, self.y = self.body:getPosition()

    if self.y > self.limit_map_y then 
        local spawn = self.level.map('objects')('spawn')
        self.pos:set(spawn.x, spawn.y)
        self.body:setLinearVelocity(0, 0)
    end

    self:applyDamage()

    self:animate(vx, vy)

	super.tick(self)
end

function Player:move(dt, vx, vy)
    if not vx or not vy then vx, vy = self.body:getLinearVelocity() end

    local dx     = -1*self.dir.left + self.dir.right

    self:moveDoor()

    local def = self.moveDef
    local force, maxVel, slowdown = def.ogHorForce, def.maxVxWalk, def.slowWalk

    dt = 1 / (dt * def.timeFactor)

    -- if fast, slowdown is weaker
    if abs(vx) > maxVel then slowdown = def.slowRun end

    -- if running, maxspeed is different
    if (self:onGround()                 and self.keyRun) 
        or (0.9*abs(vx) > def.maxVxWalk and self.keyRun)
        or def.alwaysRun 
       then maxVel = def.maxVxRun end

    self:moveJump(dt)

    -- which forces apply on character
    if not self:onGround() and dx ~= 0 then force = def.oaHorForce end

    -- horizontal walk/run
    if dx ~= 0 and abs(vx) < maxVel then
        self.body:applyForce( dt*dx*force*(maxVel-abs(vx)), 0)
    end

    -- fake friction in horizontal axis
    if vx ~= 0 and (dx*vx < 0 or (dx == 0 and self:onGround())) then
        self.body:applyForce(-dt*vx*force*slowdown, 0)
    end

    -- falling down
    if def.addGravity + vy > def.maxVyFall 
    then self.body:applyLinearImpulse(0, def.maxVyFall - vy - def.addGravity)
    else self.body:applyLinearImpulse(0, def.addGravity) end
    
end

function Player:moveJump(dt)
    if self:onGround() and self.keyJump and self.jumping == 0 then
        self.jumping = 1
        self:doJump(dt)
    elseif self.keyJump then
        local jump = self.moveDef.jumpImp
        if     self.jumping == 0 then self.jumping = #jump
        elseif self.jumping  > 0 and  self.jumping < #jump then
            self.jumping = self.jumping + 1
            self:doJump(dt)
        end
    end
end

function Player:onGround()
    return self.groundCount ~= 0
end

function Player:doJump(dt)
    local jump = self.moveDef.jumpImp
    self.body:applyLinearImpulse(0, -jump[self.jumping])
end

function Player:moveDoor()
    if self.dir.up == 1 and self.door then
        if self.door.level and self.door.level ~= self.level.name then
            task.setOnce('changeMap', function() scenes.run('First') end)
        else
            local link = self.door.layer.objects[self.door.link]
            self.pos:set(link.x, link.y)
        end
        self.dir.up = 0
    end
end

function Player:animate(vx, vy)
    local def, maxVxWalk = self.animation.extra, self.moveDef.maxVxWalk

    if not vx or not vy then vx, vy = self.body:getLinearVelocity() end

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
end

function Player:hurt(enemy)
    self.damage[enemy] = 1
end

function Player:applyDamage()
    for enemy,hp in pairs(self.damage) do
        if not enemy.removed then self.hp = self.hp - hp end
        self:reaction(enemy)
    end

    if self.hp == 0 then self.removed = true
    else self.damage = {} end
end

function Player:reaction(enemy)
    local ex, ey = enemy.x, enemy.y
    local mx, my = self.pos:get()

    local dx, dy = ex - mx, ey - my
    local max = math.sqrt(dx*dx + dy*dy)
    local rx, ry = dx / max, dy / max
    local ix, iy = -rx*250, -ry*200 * (self.keyJump and 1.5 or 1)

    if enemy.removed then
        local vx, vy = self.body:getLinearVelocity()
        if ix*vx < 0 then ix = -ix end
    end

    self.body:setLinearVelocity(ix, iy)

end

function Player:draw(...)
	super.draw(self, ...)
end

function collisions.floorSensor(p, fa, fb, a)
    local self  = fa:getBody().parent
    local enemy = fb:getBody().parent
    if p == MOAIBox2DArbiter.BEGIN then             
        if not enemy then self.groundCount = self.groundCount + 1 end
        if not self:onGround() and fb.name == 'head' 
        and enemy and enemy.hurt then
            enemy:hurt(self)
        end
    elseif p == MOAIBox2DArbiter.END and not enemy then
        self.groundCount = self.groundCount - 1
    end
end

function collisions.area(p, fa, fb, a) 
    local object = fb:getBody().object
    if object then collisions.object[object.class](fa:getBody().parent, object, p, a) end
end

collisions.object = {}

function collisions.object.Door(self, object, p, a)
    if p == MOAIBox2DArbiter.BEGIN then self.door = object
    elseif self.door == object     then self.door = nil end
end

return Player