local Animation, Data, Job, Physics; import()
local Bullet; import 'entity.particle'

local function trigger_bullet(self, dir, scalar, onhit)
    scalar = scalar or 400
    local speed = {dir[1] * scalar, dir[2] * scalar}

    self.level: add(
                    Bullet(
                        self.level, 
                        Data.animation.Bullet, 
                        self.pos, 
                        speed, 
                        self, 
                        onhit
                    )
    )
end

local function BulletAttack(e)
	local tick = 0
	trigger_bullet(e, {e.lookLeft and -1 or 1, 0})
	return function()
		tick = tick + 1
		return tick ~= 10
	end
end

local f = require 'data.fixture.Filters'

local function make_portal(self, x, y, nx, ny)
    nx, ny = math.abs(nx), math.abs(ny)

    local xo, yo = x - ny * 24, y - nx * 24
    local x1, y1 =     ny * 48,     nx * 48

    local offset = 0

    print 'portal!!'

    if self.portal then
        self.portal = nil
    else
        self.portal = {xo, yo, x1, y1}
    end

    Physics:registerBody{
        option = 'dynamic',
        fixtures = {{
            option = 'rect',
            args = {-offset, -offset, x1 + offset, y1 + offset},
            sensor = true
        }},
        x = xo,
        y = yo,
        fixedRotation = true,
        bullet = true,
        gravityScale = 0,

        fixCategory = f.C_FRIEND_SHOOT,
        fixMask     = f.M_FRIEND_SHOOT
    }
end

local function special_shoot(self, dirx, diry)
    trigger_bullet(self, {dirx, diry}, nil, function(bullet, impact, a)
        if impact.structure then
            local nx, ny = a:getContactNormal()
            local x ,  y = bullet.pos.x, bullet.pos.y

            local hit, hx, hy = Physics.world:getRayCast(
                x, y, 
                bullet.speed[1] + x, 
                bullet.speed[2] + y
            )

            if hit then x, y = hx, hy end

            local body
            local walls = {}

            self.tasks:once('creating_shadow', function()

                local fixtures = {}
                for i = -24, 24, 12 do
                    walls   [#fixtures + 1] = true
                    fixtures[#fixtures + 1] = {
                        option = 'circle',
                        args = {ny*i, nx*i, 2},
                        sensor = true,
                    }
                end

                for i = -18, 18, 12 do
                    local x = nx == 0 and 0 or nx * 10
                    local y = ny == 0 and 0 or ny * 10
                    fixtures[#fixtures + 1] = {
                        option = 'circle',
                        args = {ny*i + x, nx*i + y, 5},
                        sensor = true,
                    }
                end

                body = Physics:registerBody{
                    option = 'dynamic',
                    fixtures = fixtures,
                    x = x,
                    y = y,
                    fixedRotation = true,
                    bullet = true,
                    gravityScale = 0,

                    fixCategory = f.C_FRIEND_SHOOT,
                    fixMask     = f.M_FRIEND_SHOOT
                }

                for _,fix in pairs(body.fixtures) do
                    fix:setCollisionHandler(function(p, fa, fb, a)
                        if fb:getBody() == impact then fix.touched = true end
                    end, MOAIBox2DArbiter.BEGIN)
                end

            end)

            self.tasks:once('delete_shadow', function()
                local touched = true
                for k, fix in pairs(body.fixtures) do
                    if (walls[k] and not fix.touched)
                    or (fix.touched and not walls[k]) then touched = false end
                end
                if touched then make_portal(self, x, y, nx, ny) end
                body:clear()
            end, 10)
        end
        return true
    end)
end

local function YoshiAttack(e)

	local jump = e.jumpState
	if jump.state ~= 'stand' and jump.state ~= 'fall' then return end

    local a = Animation(Data.animation.Cursor)

    local prop = a.prop

    local dist = 50

    local cos, sin, rad = math.cos, math.sin, math.rad

    local look = e.lookLeft == true and -1 or 1

    e.jumpState.can_double_jump = false
    e.jumpState.can_wall_jump   = false

    local bShoot = 0

    local angle, dir = -20, 1.8
    local sm = Job.chain(function(c)
        local x, y = e.pos.x, e.pos.y

        angle = angle + dir
        
        if  e.action.down == 1 or 
            e.removed          or 
            e:isWounded() then return c:exit() end

        --if e.action.run        then angle =  0 end
        if e.action.up   == 1 then angle = 90 end

        if e.action.special == (bShoot %2 == 1) then bShoot = bShoot + 1 end
        if bShoot == 2 then c:next() end

        if angle < -20 or angle > 90 then dir = -dir end

        local radians = rad(angle)
        prop:setLoc(x + look * cos(radians) * dist, y - sin(radians) * dist)
        a:next()
    end):after(function(c)
        local radians = rad(angle)

        special_shoot(e, look * cos(radians), -sin(radians))

        c:next()
    end):finally(function()
	    e.jumpState.can_double_jump = true
	    e.jumpState.can_wall_jump   = true
        prop:clear() 
    end)

	return function()
		if     not sm.finished then sm() end
		return not sm.finished or e.action.special
	end
end

local Attacks = {
	Bullet = BulletAttack,
	Yoshi  = YoshiAttack,
}
return Attacks