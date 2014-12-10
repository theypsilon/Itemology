local Animation, Physics, Data; import()
local Mob, Position; import 'entity'

local WalkingEnemy = class(Mob)

function WalkingEnemy:_init(level, definition, p)
    local pos = p.x and p or p.pos

    if not pos then pos = {x = 100, y = 400} end

    Mob._init(self, level, pos.x, pos.y)

    self.animation = Animation(definition.animation)
    self.prop      = self.animation.prop

    self.walk      = { dx = 0, left = false}
    self.direction = { x  = 0,    y = 0    }
    self.velocity  = { x  = 0,    y = 0    }
    self.ground    = { on = false          }
    self.walkingai = true

    self.body = Physics:registerBody(definition.fixture, self.prop, self)

    self:_setListeners()

    self.body:setTransform(pos.x, pos.y)

    self.initial_x, self.initial_y = pos.x, pos.y

    local _
    _, self.limit_map_y = level.map:getBorder()

    self.moveDef = definition.motion
    self.walkDir = p.properties and p.properties.dir or 1
end

function WalkingEnemy:_setListeners()
    local fix = self.body.fixtures
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

    local begend = MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END
    fix.hole_left :setCollisionHandler(floorSensor('gLeft' ), begend)
    fix.hole_right:setCollisionHandler(floorSensor('gRight'), begend)
end

local abs = math.abs

function WalkingEnemy:morePath(vx)
    return self[vx > 0 and 'gRight' or 'gLeft'] ~= 0
end

function WalkingEnemy:animate()
    self.animation:next()
end

function WalkingEnemy:draw(...)
    Mob.draw(self, ...)
end

function WalkingEnemy:hurtBy(rival)
    if rival._name == 'Player' then
        local P = require 'entity.particle.Animation'
        self.level:add(P(self.level, Data.animation.Goomba, 'die', self.pos))
        self:remove()
    end
end

return WalkingEnemy