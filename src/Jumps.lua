local Job, Physics; import()

local function SingleStandardJump(e)
    local component = {}
	component.step   = 1
	component.def    = e.moveDef.jumpImp
	component.action = e.action
    return component
end

local function DoubleStandardJump(e)
    local component = {}
	component.def  = e.moveDef
    return component
end

local function WallStandardJump(e)
    local component = {}
	component.def  = e.moveDef
    return component
end

local function BounceStandardJump(e)
    local component = {}
	component.def  = e.moveDef
    return component
end

local function FalconJump(e)
    local component = {}

    local vx, vy = e.vx, e.vy
    local dx, dy = vx > 0 and 1 or -1, vy > 0 and 1 or -1
	local def    = e.moveDef

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

    component.sm = Job.interval(function(c)
        x, y = x + e.dx, y - e.dy
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
    return component
end

local function SpaceJump(e)
    local component = {}

    local def = e.moveDef

    local gravity = e.body:getGravityScale()
    e.body:setGravityScale(e.moveDef.sjumpGravity)

    local maxFallSp = e.moveDef.sjumpMaxFallSpeed

    component.sm = Job.interval(function(c)
        if not e.action.jump then return c:next() end
        e.body:applyLinearImpulse(0, -150)
    end, 0, #e.moveDef.jumpImp) :after(function(c)
        if e.ground.on  then return c:next() end
        if e.vy > maxFallSp then e.body:setLinearVelocity(e.vx, maxFallSp) end
    end)

    :finally(function()
        e.body:setGravityScale(gravity)
    end)
    return component
end

local function KirbyJump(e)
    local component = {}

	component.def  = e.moveDef

	DoubleStandardJump.__call(component)

    local time, cadence, maxFallSp = e.moveDef.kjumpFullTime,
                                     e.moveDef.kjumpCadenceTime,
                                     e.moveDef.kjumpFallSpeedLimit

    local step = 0
    component.sm = Job.chain(function(c)
        step = step + 1
        if not e.action.jump then c:next() end
        if e.ground.on or step > time then c:exit() end
        if e.vy > maxFallSp then e.body:setLinearVelocity(e.vx, maxFallSp) end
        if e.action.run then c:exit() end
    end):after(function(c)
        step = step + 1
        if e.action.jump then
            if c.last <= step then 
                DoubleStandardJump.__call(component)
                c.last = step + cadence 
            end
            return c:next(1)
        end
        if e.action.run then c:exit() end
        if e.ground.on or step > time then c:exit() end
        if e.vy > maxFallSp then e.body:setLinearVelocity(e.vx, maxFallSp) end
    end)

    component.sm.last = cadence
    return component
end

local function TeleportJump(e)
    local component = {}

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

        component.sm = Job.chain(function(c)
            if not e.action.jump or freezing <= 0 then c:exit() end
            e.body:setTransform(tx, ty)
            freezing = freezing - 1
        end)

        :finally(function()
            e.body:setGravityScale(gravity)
            e.moveVertical = nil
        end)
    end
    return component
end

local function PeachJump(e)
    local component = {}
    local gravity = e.body:getGravityScale()

    print(gravity)

    e.body:setGravityScale(e.moveDef.pjumpGravity)
    e.body:setLinearVelocity(e.vx, 0)
    e.move = movePeach

    local fly = e.moveDef.pjumpFlyTime
    local rep = e.moveDef.pjumpRepeat

    component.sm = Job.interval(function(c)
        if not e.action.jump then c:next() end
    end, 0, fly):after(function(c)
        if e.move == movePeach then
            e.move = nil
            e.body:setGravityScale(gravity)
        end
        if e.ground.on               then return c:next() end
        if e.action.jump and c.ticks < (fly - 1) and rep > 0 then
            gravity = e.body:getGravityScale()
            e.body:setGravityScale(0)
            e.body:setLinearVelocity(e.vx, 0)
            e.move = movePeach
            rep = rep - 1
            c:next(1)  
        end
    end)
    return component
end

local function DixieJump(e)
    local component = {}
    local gravity = e.body:getGravityScale()

    e.body:setLinearVelocity(e.vx, 0)
    e.move = movePeach

    local v = e.moveDef.xjumpFallSpeedLimit
    local speed, vxLimit = e.moveDef.xjumpJumpSpeed, 
                           e.moveDef.xjumpJumpVertLimit

    component.sm = Job.interval(function()
        local vx = abs(e.vx) < vxLimit and e.vx or sig(e.vx)*vxLimit
        e.body:setLinearVelocity(vx, -speed)
    end, 0, e.moveDef.xjumpJumpTime):after(function(c)
        if e.ground.on or e:isWounded() then c:exit() end
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
    then component.sm:next(3) end
    return component
end

local Jumps = {}
Jumps.SpaceJump          = SpaceJump
Jumps.SingleStandardJump = SingleStandardJump
Jumps.DoubleStandardJump = DoubleStandardJump
Jumps.WallStandardJump   = WallStandardJump
Jumps.BounceStandardJump = BounceStandardJump
Jumps.FalconJump         = FalconJump
Jumps.KirbyJump          = KirbyJump
Jumps.TeleportJump       = TeleportJump
Jumps.PeachJump          = PeachJump
Jumps.DixieJump          = DixieJump
return Jumps