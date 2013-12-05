local Text; import()

local Player = {}

function Player:_setListeners()
    local begend = MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END 

    local fix = self.body.fixtures

    fix['area']:setCollisionHandler(Player.area, begend)

    self.groundCount = 0

    for _,sensor in pairs{fix['foot1'], fix['foot2']} do
        sensor:setCollisionHandler(Player.footSensor, begend)
    end

    self.touch = 0; Text:debug(self, 'touch')

    fix['hand1']:setCollisionHandler(Player.handSensor(-1), begend)
    fix['hand2']:setCollisionHandler(Player.handSensor( 1), begend)
end

function Player.footSensor(p, fa, fb, a)
    local self  = fa:getBody().parent
    local enemy = fb:getBody().parent
    if p == MOAIBox2DArbiter.BEGIN then             
        if not enemy then self.groundCount = self.groundCount + 1 end
        if not self:onGround() and fb.name == 'head' and self.vy >= 0
        and enemy and enemy.hurt then
            enemy:hurt(self)
        end
    elseif p == MOAIBox2DArbiter.END and not enemy then
        self.groundCount = self.groundCount - 1
    end
end

function Player.handSensor(side)
    return function(p, fa, fb, a)
        if fb.name ~= nil then
            local self = fa:getBody().parent
            self.touch = self.touch + (p == MOAIBox2DArbiter.BEGIN and side or -side)
        end
    end
end

function Player.area(p, fa, fb, a) 
    local object = fb:getBody().object
    if object then Player.object[object.class](fa:getBody().parent, object, p, a)
    end
end

Player.object = {}

function Player.object.Door(self, o, p, a)
    if p == MOAIBox2DArbiter.BEGIN then self.door = o
    elseif self.door == o          then self.door = nil end
end

function Player.object.Power(self, o, p, a)
    if p ~= MOAIBox2DArbiter.BEGIN then return end

    self.tasks:once(o.power, function()
        self.power [o.power] = o.charges + 
                             (o.add and self.power[o.power] or 0)

        local remove = tonumber(o.remove) or 1

        if remove <= 1 
        then o.parent:remove()
        else o.remove = remove - 1 end
    end)
end

return Player