local Tasks, Scenes, Text, Data, Job, Physics; import()

local abs = math.abs

local Player = {}

function Player:setDoubleJump()
    if  self.tasks.callbacks.jumping or 
        self.walltouch or
        not self:onGround() then return end

    self.tasks:set('jumping', self:getDoubleJumpStateMachine())
end

function Player:getDoubleJumpStateMachine()
    local jump = Job.bistate()

    return Job.interval(function(c)
        if not self.keyJump then return c:next() end
        self:doJump(c.ticks + 1)
    end, 0, #self.moveDef.jumpImp):after(function(c)
        if self:onGround()         then         return  c:exit() end
        if self:moveWallJump(true) then jump    = Job.bistate(4) end
        if jump(self.keyJump) then self:doDoubleJump(); c:next() end
    end):after(function(c)
        if self:onGround()  then  return c:exit() end
        if self:moveWallJump(true) then c:next(3) end
    end)

    :with('rejump', function(c) 
        jump = Job.bistate()
        c:fallthrough(3)
    end)
end

function Player:reDoubleJump()
    local jumping = self.tasks.callbacks.jumping
    
    if jumping and jumping.cur > 3 then
        local djump = self.tasks.callbacks.djumping
        local wjump = self.tasks.callbacks.walljumping
        if djump then
            djump:exit()
            djump:update()
        end
        if wjump then
            wjump:exit()
            wjump:update()
        end
        jumping.jump = nil
        jumping:next('rejump')
    end
end

function Player:setSingleJump()
    if  self.tasks.callbacks.jumping or 
        self.walltouch or
        not self:onGround() then return end

    self.tasks:set('jumping', Job.interval(function(c)
        if not self.keyJump then return c:next() end
        self:doJump(c.ticks + 1)
    end, 0, #self.moveDef.jumpImp)) :after(function(c)
        if self:onGround()  then return c:next() end
        self:moveWallJump(true)
    end)
end

function Player:setSpaceJump()
    if not self:usePower('sjump') then return end

    if  self.tasks.callbacks.jumping or 
        self.walltouch or
        not self:onGround() then return end

    local def = self.moveDef

    local gravity = self.body:getGravityScale()
    self.body:setGravityScale(self.moveDef.sjumpGravity)

    self.moveVertical = nothing
    local maxFallSp = self.moveDef.sjumpMaxFallSpeed

    self.tasks:set('jumping', Job.interval(function(c)
        if not self.keyJump then return c:next() end
        self:doJump(c.ticks + 1)
    end, 0, #self.moveDef.jumpImp)) :after(function(c)
        if self:onGround()  then return c:next() end
        if self.vy > maxFallSp then self.body:setLinearVelocity(self.vx, maxFallSp) end
        self:moveWallJump(true)
    end)

    :finally(function()
        self.moveVertical = nil
        self.body:setGravityScale(gravity)
    end)
end

local function prepare_touch(touch)
    return touch == 0 and 0 or touch / abs(touch)
end

function Player:moveWallJump(fromJumping)
    if self.tasks.callbacks.walljumping then return end
    if not fromJumping and self.tasks.callbacks.jumping then return end

    local vy, dx = self.vy, self.dx

    local initial_touch = prepare_touch(self.touch)

    if  initial_touch ~= 0 and 
        initial_touch == dx and 
        self.lastwalljump ~= initial_touch and
        not self:onGround()
    then

        local prevSetJump = self.setJump 

        local ws = self.moveDef.wallSlidingSpeed

        local jump = Job.bistate()

        self.tasks:set('walljumping', Job.chain(function(c)
            local touch = prepare_touch(self.touch)

            if touch ~= initial_touch or self:onGround() then return c:next() end

            if jump(self.keyJump) then
                local def = self.moveDef
                self.body:setLinearVelocity(
                    -touch * ( def.wjumpVxPlus + abs(dx) * def.wjumpVxBase ),
                    -def.wjumpUp
                )
                self.lastwalljump = touch
                return c:next()
            end

            if self.vy > ws then self.body:setLinearVelocity(self.vx, ws) end
        end))

        return true
    end
end

function Player:onGround()
    return self.groundCount ~= 0
end

function Player:doJump(step)
    local jump = self.moveDef.jumpImp
    self.body:applyLinearImpulse(0, -jump[step])
end

-- DOUBLE JUMP

function Player:doFalconJump()
    if not self:usePower('fjump') then return end

    self.lastwalljump = false

    local vx, vy = self.body:getLinearVelocity()
    local dx, dy = vx > 0 and 1 or -1, vy > 0 and 1 or -1

    local def = self.moveDef

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

    local gravity = self.body:getGravityScale()

    self.body:setLinearVelocity(vx * ifactor, vy * ifactor)
    self.body:setGravityScale(def.fjumpGravity)
    self.move = nothing

    local x, y, cancel = 0, 0, 0

    local function try_cancel(c)
        if self.keyJump == (cancel %2 == 1) then cancel = cancel + 1 end
        if cancel == cancelled then c:fallthrough(4) end
    end

    self.tasks:set('djumping', Job.interval(function(c)
        x, y = x + self.dx, y + self.dy
        try_cancel(c)
    end, 0, charge_t)):after(function(c)
        if abs(x) < charge_m and abs(y) < charge_m then return c:next(4) end
        x, y = x * charge_f, y * charge_f
        cancel = 0
        c:next()
    end):after(Job.interval(function(c)
        self.body:setLinearVelocity(x, y)
        try_cancel(c)
    end, 0, fly_t))

    :finally(function()
        self.move = nil
        self.body:setGravityScale(gravity)
    end)
end


function Player:doKirbyJump(    )
    if not self:usePower('kjump') then return end

    self.lastwalljump = false 

    self:doStandardDoubleJump(true)

    local time, cadence, maxFallSp = self.moveDef.kjumpFullTime,
                                     self.moveDef.kjumpCadenceTime,
                                     self.moveDef.kjumpFallSpeedLimit

    local step = 0
    self.tasks:set('djumping', Job.chain(function(c)
        step = step + 1
        if not self.keyJump then c:next() end
        if self:onGround() or step > time then c:exit() end
        if self.vy > maxFallSp then self.body:setLinearVelocity(self.vx, maxFallSp) end
        if self.keyRun then c:exit() end
    end)):after(function(c)
        step = step + 1
        if self.keyJump then
            if c.last <= step then 
                self:doStandardDoubleJump(true)
                c.last = step + cadence 
            end
            return c:next(1)
        end
        if self.keyRun then c:exit() end
        if self:onGround() or step > time then c:exit() end
        if self.vy > maxFallSp then self.body:setLinearVelocity(self.vx, maxFallSp) end
    end).last = cadence
end

function Player:doTeleportJump()
    if not self:usePower('tjump') then return end

    self.lastwalljump = false

    local vx, vy, dx, dy = self.vx, self.vy, self.dx, self.dy
    local vdx, vdy = vx > 0 and 1 or vx < 0 and -1 or dx,
                     vy > 0 and 1 or vy < 0 and -1 or dy

    local x, y = dx ~= -vdx and dx or 0, dy ~= -vdy and dy or 0

    if y == 1 then y = 0 end

    if x == 0 and y == 0 then y = -1 end

    local factor = x ~= 0 and y ~= 0    and
        self.moveDef.tjumpDiagonalFactor or
        self.moveDef.tjumpStraightFactor

    local tx, ty = self.x + (x * factor), self.y + (y * factor)

    self.body:setActive(false)
    local hit, hx, hy, fix = Physics.world:getRayCast(self.x, self.y, tx, ty)
    self.body:setActive(true )

    if hit then tx, ty = hx - vdx * 10, hy - vdy * 10 end

    self.pos:set(tx, ty)

    self.tasks:set('djumping', Job.chain(function(c)
        if self:onGround() then c:next() end
    end))
end

local function movePeach(self, dt)
    dt = 1 / (dt * self.moveDef.timeFactor)

    self:moveLateral(dt, self:calcMainForces(dt))    
end

function Player:doPeachJump()
    if not self:usePower('pjump') then return end

    self.lastwalljump = false

    local gravity = self.body:getGravityScale()

    self.body:setGravityScale(self.moveDef.pjumpGravity)
    self.body:setLinearVelocity(self.vx, 0)
    self.move = movePeach

    local fly = self.moveDef.pjumpFlyTime

    self.tasks:set('djumping', Job.interval(function(c)
        if not self.keyJump then c:next() end
    end, 0, fly)):after(function(c)
        if self.move == movePeach then
            self.move = nil
            self.body:setGravityScale(gravity)
        end
        if self:onGround()               then return c:next() end
        if self.keyJump and c.ticks < (fly - 1) then
            gravity = self.body:getGravityScale()
            self.body:setGravityScale(0)
            self.body:setLinearVelocity(self.vx, 0)
            self.move = movePeach
            c:next(1)  
        end
    end)
end

function Player:doDixieJump()
    if not self:usePower('xjump') then return end

    self.lastwalljump = false

    local gravity = self.body:getGravityScale()

    self.body:setGravityScale(self.moveDef.xjumpGravity * gravity)
    self.body:setLinearVelocity(self.vx, 0)
    self.move = movePeach

    local v = self.moveDef.xjumpFallSpeedLimit

    self.tasks:set('djumping', Job.chain(function(c)
        if not self.keyJump then c:next() end
        if self:onGround() then c:fallthrough() end
        if self.vy > v then self.body:setLinearVelocity(self.vx, v ) end
    end))

    :finally(function()
        if self.move == movePeach then
            self.move = nil
            self.body:setGravityScale(gravity)
        end
    end)
end

function Player:doStandardDoubleJump(free)
    if not free and not self:usePower('djump') then return end
    if not free then self.lastwalljump = false end
    
    local def = self.moveDef

    local vx, vy = self.vx, self.vy
    local vx = self.dx*abs(vx)
    if vx > def.djumpMaxVx then vx = def.djumpMaxVx end
    self.body:setLinearVelocity(vx, -def.djumpUp)
end

return Player