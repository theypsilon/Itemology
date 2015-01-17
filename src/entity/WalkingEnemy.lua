local Animation, Physics; import()
local Factory; import 'ecs.component'

local function setListeners(self)
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

local function WalkingEnemy(level, definition, p)
    local e = {}
    local pos = {x = p.x, y = p.y}

    e.pos = pos
    e.ticks  = 0
    e.level  = level
    e.map    = level.map

    e.animation = Animation(definition.animation)
    e.prop      = e.animation.prop

    e.walk      = { dx = 0, left = false}
    e.direction = { x  = 0,    y = 0    }
    e.velocity  = { x  = 0,    y = 0    }
    e.ground    = { on = false          }
    e.walkingai = true

    e.body = Physics:registerBody(definition.fixture, e.prop, e)
    e.physic_change = Factory.makePhysicChange()

    setListeners(e)

    e.body:setTransform(pos.x, pos.y)

    e.initial_x, e.initial_y = pos.x, pos.y

    local _
    _, e.limit_map_y = level.map:getBorder()

    e.moveDef = definition.motion
    e.walkDir = p.properties and p.properties.dir or 1
    e._name = "WalkingEnemy"
    return e
end

return WalkingEnemy