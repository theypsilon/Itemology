local Player = {}

local BEGIN = MOAIBox2DArbiter.BEGIN

function Player:_setListeners()
    local begend = BEGIN + MOAIBox2DArbiter.END 

    local fix = self.body.fixtures

    fix['area']:setCollisionHandler(Player.area, begend)
end

function Player.area(p, fa, fb, a)
    local  contact = fb:getBody().parent
    if not contact then return end
    pcall(function()
        Player.contact[contact._name](fa:getBody().parent, contact, p, a, fb)
    end)
end

Player.contact = {}

function Player.contact.WalkingEnemy(self, enemy, p, a, fb)
    if p ~= BEGIN then return end

    if fb.kills then
        self.damage[enemy] = self.ticks + 1
    end
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

    self.collision_power = o
end

return Player