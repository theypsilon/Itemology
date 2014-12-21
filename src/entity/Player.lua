local Animation, Physics, Text, Data, Tasks, Update, Job; import()
local Mob , Position; import 'entity'
local Move, Collision, InputPower; import 'entity.player'
local Factory; import 'ecs.component'

local Player = class(Mob, Move, Collision, InputPower)

function Player:_init(level, def, p)
	Mob._init(self, level, p.x, p.y)

    self.animation = Animation(def.animation)
    self.prop      = self.animation.prop

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

    self.attackState = { state='rest' }
    self.attackResource = {
        Bullet = math.huge,
        Yoshi  = math.huge
    }
    self.attackSelector = {
        attack  = 'Bullet',
        special = 'Yoshi'
    }

    self.walk      = { dx = 0, left = false}
    self.direction = { x = 0, y = 0 }
    self.velocity  = { x = 0, y = 0 }

    self:_setListeners(self)
    self:_setInput(p)
    self:_setPower(p)
    self:_setInitialMove(p)

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

    local dx = -1* (self.action.left and 1 or 0) + (self.action.right and 1 or 0)
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
    self.damage[enemy] = self.ticks + (delay and delay or 1)
end

return Player