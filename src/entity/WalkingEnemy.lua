local Animation, Physics; import()
local Mob, Position; import 'entity'

local WalkingEnemy = class.WalkingEnemy(Mob)

function WalkingEnemy:_init(level, definition, p)
    Mob._init(self, level, p.x, p.y)

    self.animation = Animation(definition.animation)
    self.prop      = self.animation.prop

    self.body = Physics:registerBody(definition.fixture, self.prop, self)

    self:_setListeners()

    self.pos = Position(self.body)
    self.pos:set(p.x, p.y)

    self.initial_x, self.initial_y = p.x, p.y

    local _
    _, self.limit_map_y = level.map:getBorder()

    p = p.properties
    self.moveDef = definition.move
    self.dir     = p and tonumber(p.dir) or 1
end

function WalkingEnemy:_setListeners()
    local fix = self.body.fixtures
    fix['area']:setCollisionHandler( 
        function(phase, fix_a, fix_b, arbiter)
            if phase == MOAIBox2DArbiter.BEGIN then
                local victim = fix_b:getBody().parent
                if victim and victim.hurt then victim:hurt(self, true) end
            end
        end, 
        MOAIBox2DArbiter.BEGIN  
    )

    local function floorSensor(var)
        self[var] = 0
        return function(phase, fix_a, fix_b, arbiter)
            if phase == MOAIBox2DArbiter.BEGIN then
                self[var] = self[var] + 1
                if fix_b:getBody().tag == 'platform' then
                    self.platform = fix_b:getBody()
                end
            elseif phase == MOAIBox2DArbiter.END then
                self[var] = self[var] - 1
                if fix_b:getBody().tag == 'platform' then
                    self.platform = nil
                end
            end
        end
    end

    fix['sensorL']:setCollisionHandler(floorSensor('gLeft' ), MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)
    fix['sensorR']:setCollisionHandler(floorSensor('gRight'), MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)
end

local abs = math.abs

function WalkingEnemy:tick(dt)

    local vx, vy  = self.body:getLinearVelocity()

    self:move(dt, vx, vy)

    self.x, self.y = self.pos:get()

    if self.y > self.limit_map_y then
        self.pos:set(self.initial_x, self.initial_y)
        self.body:setLinearVelocity(0, 0)
    end

    self:animate(vx, vy)

    Mob.tick(self)
end

function WalkingEnemy:move(dt, vx, vy)
    if not vx or not vy then vx, vy = self.body:getLinearVelocity() end

    local def = self.moveDef 

    dt = dt * def.timeFactor

    if (abs(vx) < 5 or not self:onGround(vx)) then
        self.dir = self.dir * -1 
    end

    -- horizontal walk
    self.body:setLinearVelocity(self.dir*def.velocity,vy)

    -- falling down
    if def.addGravity + vy > def.maxVyFall 
    then self.body:applyLinearImpulse(0, def.maxVyFall - vy - def.addGravity)
    else self.body:applyLinearImpulse(0, def.addGravity) end
end

function WalkingEnemy:onGround(vx)
    return self[vx > 0 and 'gRight' or 'gLeft'] ~= 0
end

function WalkingEnemy:animate(vx, vy)
    local def, maxVxWalk = self.animation.extra, self.moveDef.maxVxWalk

    if not vx or not vy then vx, vy = self.body:getLinearVelocity() end

    self.animation:setMirror(vx < 0)
    self.animation:next()
end

function WalkingEnemy:draw(...)
    Mob.draw(self, ...)
end

local Broken = require 'entity.particle.Broken'

function WalkingEnemy:hurt(rival)
    if rival._name == 'Player' then
        local Particle = require 'entity.particle.Animation'
        self.level:add(Particle(self.level, data.animation.Goomba, 'die', self))
        self:remove()

        rival:hurt(self)
    end
end

return WalkingEnemy