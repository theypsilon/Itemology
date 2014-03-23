local Jumper = class()
function Jumper:_init(t)
    assert(t == 'jump'      or t == 'double_jump' 
        or t == 'wall_jump' or t == 'bounce', t)
    self.type = t
end

function Jumper:next(e)
    return false
end

local Jumps = {}
Jumps.SingleStandardJump = class(Jumper)
function Jumps.SingleStandardJump:_init(e)
	Jumper._init(self, 'jump')
	self.step = 1
	self.body = e.body
	self.def  = e.moveDef.jumpImp
	self.action = e.action
end

function Jumps.SingleStandardJump:next()
	self.body:applyLinearImpulse(0, -self.def[self.step])
	self.step = self.step + 1
	return self.step <= #self.def and self.action.jump
end

Jumps.DoubleStandardJump = class(Jumper)
function Jumps.DoubleStandardJump:_init(e)
	Jumper._init(self, 'double_jump')
	self.body = e.body
	self.def  = e.moveDef
	self.e    = e
end

function Jumps.DoubleStandardJump:next()
	local e = self.e
	local vx, vy = e.vx, e.vy
	local def = self.def
    if vx > def.djumpMaxVx then vx = def.djumpMaxVx end
    self.body:setLinearVelocity(vx, -def.djumpUp)
end

Jumps.WallStandardJump = class(Jumper)
function Jumps.WallStandardJump:_init(e)
	Jumper._init(self, 'double_jump')
	self.body = e.body
	self.def  = e.moveDef
	self.e    = e
end

local abs = math.abs

function Jumps.WallStandardJump:next()
	local touch = self.e.jumpState.sliding
	local def = self.def
	local dx = self.e.dx

    self.body:setLinearVelocity(
        -touch * ( def.wjumpVxPlus + abs(dx) * def.wjumpVxBase ),
        -def.wjumpUp
    )
end

Jumps.BounceStandardJump = class(Jumper)
function Jumps.BounceStandardJump:_init(e)
	Jumper._init(self, 'double_jump')
	self.body = e.body
	self.def  = e.moveDef
	self.e    = e
end

function Jumps.BounceStandardJump:next()
	local e      = self.e
	local vx, vy = e.vx, e.vy
	local def    = self.def
    if vx > def.djumpMaxVx then vx = def.djumpMaxVx end
    self.body:setLinearVelocity(vx, -def.djumpUp)
end

local SMJump = class(Jumper)
function SMJump:next()
	self.sm()
	return self.sm.finished ~= true
end

Jumps.FalconJump = class(SMJump)
function Jumps.FalconJump:_init(e)
	Jumper._init(self, 'double_jump')

    local dx, dy = vx > 0 and 1 or -1, vy > 0 and 1 or -1
	local vx, vy = e.vx, e.vy
	local def    = self.moveDef

    local vlimit    = def.fjumpInitVLimit
    local ifactor   = def.fjumpInitVFactor
    local cancelled = def.fjumpCancelValue
    local charge_t  = def.fjumpChargeTime
    local fly_t     = def.fjumpFlyTime
    local charge_m  = def.fjumpMinChargeValue
    local charge_f  = def.fjumpChargeFactor

    if abs(vx) < vlimit then vx = 0 
    else vx = vx > 0 and 1 or -1 end
    if abs(vy) < vlimit then vy = 0
    else vy = vy > 0 and 1 or -1 end

    local gravity = e.body:getGravityScale()

    e.body:setLinearVelocity(vx * ifactor, vy * ifactor)
    e.body:setGravityScale(def.fjumpGravity)
    e.move = nothing

    local x, y, cancel = 0, 0, 0


    e.body:setLinearVelocity(vx * ifactor, vy * ifactor)
    e.body:setGravityScale(def.fjumpGravity)
    e.move = nothing

    local x, y, cancel = 0, 0, 0

    local function try_cancel(c)
        if e.action.jump == (cancel %2 == 1) then cancel = cancel + 1 end
        if cancel == cancelled then c:fallthrough(3) end
    end

    self.sm = Job.interval(function(c)
        x, y = x + e.dx, y + e.dy
        try_cancel(c)
    end, 0, charge_t):after(function(c)
        if abs(x) < charge_m and abs(y) < charge_m then return c:next(3) end
        x, y = x * charge_f, y * charge_f
        cancel = 0
        c:next()
    end):after(Job.interval(function(c)
        e.body:setLinearVelocity(x, y)
        try_cancel(c)
    end, 0, fly_t))

    :finally(function()
        e.move = nil
        e.body:setGravityScale(gravity)
    end)
end

local Player = {}
Jumps.KirbyJump = class(SMJump)
function Jumps.KirbyJump:_init(e)
	Jumper._init(self, 'double_jump')

	self.body = e.body
	self.def  = e.moveDef
	self.e    = e

	Jumps.DoubleStandardJump.next(self)

    local time, cadence, maxFallSp = e.moveDef.kjumpFullTime,
                                     e.moveDef.kjumpCadenceTime,
                                     e.moveDef.kjumpFallSpeedLimit

    local step = 0
    self.sm = Job.chain(function(c)
        step = step + 1
        if not e.action.jump then c:next() end
        if e:onGround() or step > time then c:exit() end
        if e.vy > maxFallSp then e.body:setLinearVelocity(e.vx, maxFallSp) end
        if e.action.run then c:exit() end
    end):after(function(c)
        step = step + 1
        if e.action.jump then
            if c.last <= step then 
                Jumps.DoubleStandardJump.next(self)
                c.last = step + cadence 
            end
            return c:next(1)
        end
        if e.action.run then c:exit() end
        if e:onGround() or step > time then c:exit() end
        if e.vy > maxFallSp then e.body:setLinearVelocity(e.vx, maxFallSp) end
    end)

    self.sm.last = cadence
end

Jumps.TeleportJump = class(SMJump)
function Jumps.TeleportJump:_init(e)
	Jumper._init(self, 'double_jump')

    local vx, vy, dx, dy = e.vx, e.vy, e.dx, e.dy
    local vdx, vdy = vx > 50 and 1 or vx < -50 and -1 or dx,
                     vy > 50 and 1 or vy < -50 and -1 or dy

    local x, y = dx ~= -vdx and dx or 0, dy ~= -vdy and dy or 0

    if y == 1 then y = 0 end

    if x == 0 and y == 0 then y = -1 end

    local factor = (x ~= 0 and y ~= 0)   and
        e.moveDef.tjumpDiagonalFactor or
        e.moveDef.tjumpStraightFactor

    local tx, ty = e.pos.x + (x * factor), e.pos.y + (y * factor)

    e.body:setActive(false)
    local hit, hx, hy, fix = Physics.world:getRayCast(
        e.pos.x, 
        e.pos.y, 
        tx, ty
    )
    e.body:setActive(true )

    if hit then tx, ty = hx - (x*10), hy - (y*10) end

    e.body:setTransform(tx, ty)
    e.body:setLinearVelocity(vx, 0)

    local freezing = e.moveDef.tjumpFreezing

    if freezing > 0 then
        local gravity = e.body:getGravityScale()

        e.body:setGravityScale(0)
        e.moveVertical = nothing

        self.sm = Job.chain(function(c)
            if not e.action.jump or freezing <= 0 then c:exit() end
            e.body:setTransform(tx, ty)
            freezing = freezing - 1
        end)

        :finally(function()
            e.body:setGravityScale(gravity)
            e.moveVertical = nil
        end)
    end
end

local function movePeach(self)
    self:moveLateral(self:calcMainForces())    
end

Jumps.PeachJump = class(SMJump)
function Jumps.PeachJump:_init(e)
	Jumper._init(self, 'double_jump')
    local gravity = e.body:getGravityScale()

    e.body:setGravityScale(e.moveDef.pjumpGravity)
    e.body:setLinearVelocity(e.vx, 0)
    e.move = movePeach

    local fly = e.moveDef.pjumpFlyTime
    local rep = e.moveDef.pjumpRepeat

    self.sm = Job.interval(function(c)
        if not e.action.jump then c:next() end
    end, 0, fly):after(function(c)
        if e.move == movePeach then
            e.move = nil
            e.body:setGravityScale(gravity)
        end
        if e:onGround()               then return c:next() end
        if e.action.jump and c.ticks < (fly - 1) and rep > 0 then
            gravity = e.body:getGravityScale()
            e.body:setGravityScale(0)
            e.body:setLinearVelocity(e.vx, 0)
            e.move = movePeach
            rep = rep - 1
            c:next(1)  
        end
    end)
end

Jumps.DixieJump = class(SMJump)
function Jumps.DixieJump:_init(e)
	Jumper._init(self, 'double_jump')
    local gravity = e.body:getGravityScale()

    e.body:setLinearVelocity(e.vx, 0)
    e.move = movePeach

    local v = e.moveDef.xjumpFallSpeedLimit
    local speed, vxLimit = e.moveDef.xjumpJumpSpeed, 
                           e.moveDef.xjumpJumpVertLimit

    self.sm = Job.interval(function()
        local vx = abs(e.vx) < vxLimit and e.vx or sig(e.vx)*vxLimit
        e.body:setLinearVelocity(vx, -speed)
    end, 0, e.moveDef.xjumpJumpTime):after(function(c)
        if e:onGround() or e:isWounded() then c:exit() end
        if abs(e.vx) > vxLimit then
            e.body:setLinearVelocity(vxLimit * sig(e.vx), e.vy)
        end
        if e.vy > v then 
            e.body:setGravityScale(e.moveDef.xjumpGravity * gravity)
            c:fallthrough () end
    end):after(function(c)
        if not e.action.jump  or 
            e:onGround () or 
            e:isWounded() then c:exit() end

        if e.vy > v then e.body:setLinearVelocity(e.vx, v ) end
    end)

    :finally(function()
        if e.move == movePeach then
            e.move = nil
            e.body:setGravityScale(gravity)
        end
    end)

    if (e.vy > e.moveDef.xjumpRejumpVyLimit) or 
       (not e.moveDef.xjumpRejumpFalling and e.tasks.callbacks.falling)
    then self.sm:next(3) end
end

local function jump_factory(t, e)
	return Jumps[t](e)
end

return jump_factory