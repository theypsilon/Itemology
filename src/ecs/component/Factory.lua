local Factory = {}
local Physics; import()

function Factory.makeBody(fixtures, prop, parent)
	return Physics:registerBody(fixtures, prop, parent)
end

local BEGIN  = MOAIBox2DArbiter.BEGIN
local BEGEND = BEGIN + MOAIBox2DArbiter.END 

local function ground_foot_sensor(p, fa, fb, a)
    local body  = fa:getBody()
    local enemy = fb:getBody().parent
    if enemy then return end
    if p == BEGIN then             
        body.groundContactFixture = fb
        body.groundCount = body.groundCount + 1 
    elseif p == MOAIBox2DArbiter.END then
        body.groundCount = body.groundCount - 1
    end
end

local function head_foot_sensor(p, fa, fb, a)
    local self  = fa:getBody().parent
    local enemy = fb:getBody().parent

    if not self.ground.on and fb.name == 'head' and self.vy >= 0
    and enemy and enemy.hurtBy then
        self.jump_enemy = enemy
    end
end

local function hand_sensor(side)
    return function(p, fa, fb, a)
        if fb.name ~= nil then
            local body = fa:getBody()
            body.lateralTouch = body.lateralTouch 
                + (p == BEGIN and side or -side)
        end
    end
end

function Factory.makeAllFromFixtures(fixtures, prop, parent)
    local components = {}

    local body   = Physics:registerBody(fixtures, prop, parent)
    local fix    = body.fixtures

    if fix.foot[1] and fix.foot[2] then
        body.groundCount   = 0
        for _,sensor in pairs{fix.foot[1], fix.foot[2]} do
            sensor:setCollisionHandler(ground_foot_sensor, BEGEND)
        end
        components.ground  = { on = false }
    end

    if fix.kill then
        fix.kill:setCollisionHandler(head_foot_sensor, BEGIN)
        components.bounce  = 0
    end

    if fix.hand_left and fix.hand_right then
        body.lateralTouch  = 0
        fix.hand_left:setCollisionHandler(hand_sensor(-1), BEGEND)
        fix.hand_right:setCollisionHandler(hand_sensor( 1), BEGEND)
        components.touch   = { on = 0 }
    end

    components.body = body
    return components
end

return Factory