local Animation, Data; import()
local Factory; import 'ecs.component'

local function Player(level, def, p)
    local e = {}
    e.pos = {x = p.x, y = p.y}
    e.ticks  = 0
    e.level  = level
    e.map    = level.map

    e.animation_jumper = Animation(def.animation)
    e.prop = e.animation_jumper.prop

    for k, v 
    in pairs(Factory.makeAllFromFixtures(def.fixture, e.prop, e)) do
        e[k] = v
    end

    e.input  = Data.key.Player1
    e.action = {}

    e.jumpState = { state = 'stand', jumped = true }
    e.jumpResource = { 
        SingleStandardJump = math.huge,
        DoubleStandardJump = 0,
        WallStandardJump   = math.huge,
        BounceStandardJump = math.huge,  
    }
    e.jumpSelector = { 
        jump        = 'SingleStandardJump', 
        double_jump = 'DoubleStandardJump',
        wall_jump   = 'WallStandardJump', 
        bounce      = 'BounceStandardJump', 
    }

    e.walk      = { dx = 0, left = false}
    e.direction = { x = 0, y = 0 }
    e.velocity  = { x = 0, y = 0 }

    e.body.fixtures['area']:setCollisionHandler(function(...)
        e.hitbox_collision = {...}
    end, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END)

    e.action    = {
        left    = true,
        right   = true,
        up      = true,
        down    = true,
        run     = true,
        jump    = false,
        special = false,
        plus    = false,
        select  = false,
        hack    = false
    }
    e.keyconfig = Data.key.Player1

    e.power_type = {
        djump  = {'pow_jump', 'double_jump', 'DoubleStandardJump'},
        pjump  = {'pow_jump', 'double_jump', 'PeachJump'},
        xjump  = {'pow_jump', 'double_jump', 'DixieJump'},
        fjump  = {'pow_jump', 'double_jump', 'FalconJump'},
        tjump  = {'pow_jump', 'double_jump', 'TeleportJump'},
        kjump  = {'pow_jump', 'double_jump', 'KirbyJump'},
        sjump  = {'pow_jump', 'jump', 'SpaceJump'},
        nojump = {'none'    , 'double_jump', 'DoubleStandardJump'}
    }
    e.power = iter(e.power_type)
        :filter(function(k, v) return v[1] == 'pow_jump' end)
        :map(function(k, v) return k, 0 end)
        :tomap()

    e.body:setTransform(p.x, p.y)
    e.prop:setPriority(5000)

    e.player = true

    level.player = e

    local _
    _, e.limit_map_y = level.map:getBorder()

    e.moveDef = require 'data.motion.Mario'

    e.hp = e.moveDef.hitpoints
    e.damage = {}
    e._name = "Player"
    return e
end

return Player