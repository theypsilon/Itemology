local Text; import()

local Player = {}

local BEGIN = MOAIBox2DArbiter.BEGIN

function Player:_setListeners()
    local begend = BEGIN + MOAIBox2DArbiter.END 

    local fix = self.body.fixtures

    fix['area']:setCollisionHandler(Player.area, begend)

    self.groundCount = 0

    for _,sensor in pairs{fix['foot1'], fix['foot2']} do
        sensor:setCollisionHandler(Player.footSensor, begend)
    end

    fix['foot3']:setCollisionHandler(Player.jumpSensor, BEGIN)

    self.touch = 0

    fix['hand1']:setCollisionHandler(Player.handSensor(-1), begend)
    fix['hand2']:setCollisionHandler(Player.handSensor( 1), begend)
end

function Player.footSensor(p, fa, fb, a)
    local self  = fa:getBody().parent
    local enemy = fb:getBody().parent
    if p == BEGIN then             
        if not enemy then self.groundCount = self.groundCount + 1 end
    elseif p == MOAIBox2DArbiter.END and not enemy then
        self.groundCount = self.groundCount - 1
    end
end

function Player.jumpSensor(p, fa, fb, a)
    local self  = fa:getBody().parent
    local enemy = fb:getBody().parent

    if not self:onGround() and fb.name == 'head' and self.vy >= 0
    and enemy and enemy.hurt then
        self.tasks:once('reaction', function() enemy:hurt(self) end)
    end
end

function Player.handSensor(side)
    return function(p, fa, fb, a)
        if fb.name ~= nil then
            local self = fa:getBody().parent
            self.touch = self.touch + (p == BEGIN and side or -side)
        end
    end
end

function Player.area(p, fa, fb, a)
    local  contact = fb:getBody().parent
    if not contact then return end
    Player.contact[contact._name](fa:getBody().parent, contact, p, a, fb)
end

Player.contact = {}

function Player.contact.WalkingEnemy(self, enemy, p)
    if p ~= BEGIN then return end

    self.tasks:once('hurt', function() self:hurt(enemy, true) end, 2)
end

function Player.contact.Object (self, object, p)
    Player.object[object.class](self, object, p)
end

Player.object = {}

function Player.object.Door(self, o, p)
    if p == BEGIN         then self.door = o
    elseif self.door == o then self.door = nil end
end

function Player.object.Power(self, o, p)
    if p ~= BEGIN then return end

    self.tasks:once(o.power, function()
        self:findPower(o)

        local remove = tonumber(o.remove) or 1

        if remove <= 1 
        then o:remove()
        else o.remove = remove - 1 end
    end)
end

return Player