local Animation, Text, Data; import()
local Collision, InputPower; import 'entity.player'
local Factory; import 'ecs.component'

local Player = class(Collision, InputPower)

function Player:_init(level, def, p)
    self.pos = {x = p.x, y = p.y}
    self.ticks  = 0
    self.level  = level
    self.map    = level.map

    self.animation_jumper = Animation(def.animation)
    self.prop = self.animation_jumper.prop

    for k, v 
    in pairs(Factory.makeAllFromFixtures(def.fixture, self.prop, self)) do
        self[k] = v
    end

    self.input  = Data.key.Player1
    self.action = {}

    self.jumpState = { state = 'stand', jumped = true }
    self.jumpResource = { 
        SingleStandardJump = math.huge,
        DoubleStandardJump = 0,
        WallStandardJump   = math.huge,
        BounceStandardJump = math.huge,  
    }
    self.jumpSelector = { 
        jump        = 'SingleStandardJump', 
        double_jump = 'DoubleStandardJump',
        wall_jump   = 'WallStandardJump', 
        bounce      = 'BounceStandardJump', 
    }

    self.walk      = { dx = 0, left = false}
    self.direction = { x = 0, y = 0 }
    self.velocity  = { x = 0, y = 0 }

    self:_setListeners(self)
    self:_setInput(p)
    self:_setPower(p)

    self.body:setTransform(p.x, p.y)
    self.prop:setPriority(5000)

    self.player = true

    level.player = self

    local _
    _, self.limit_map_y = level.map:getBorder()

    self.moveDef = require 'data.motion.Mario'

    self.hp = self.moveDef.hitpoints
    self.damage = {}
    Text:debug(self, 'hp')
end

return Player