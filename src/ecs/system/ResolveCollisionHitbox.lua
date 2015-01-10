local System; import 'ecs'
local ResolveCollisionHitbox = class(System)

function ResolveCollisionHitbox:requires()
    return {'hitbox_collision'}
end

function ResolveCollisionHitbox:update(e, dt, collision)
    local p, fa, fb, a = unpack(collision)
    local body = fb:getBody()
    if not body then return end
    local  contact = body.parent
    if not contact then return end
    pcall(function()
        ResolveCollisionHitbox.contact[contact._name](e, contact, p, a, fb)
    end)
end

local BEGIN = MOAIBox2DArbiter.BEGIN

ResolveCollisionHitbox.contact = {}

function ResolveCollisionHitbox.contact.WalkingEnemy(self, enemy, p, a, fb)
    if p ~= BEGIN then return end

    if fb.kills then
        self.damage[enemy] = self.ticks + 1
    end
end

function ResolveCollisionHitbox.contact.Object (self, object, p)
    ResolveCollisionHitbox.object[object.class](self, object, p)
end

ResolveCollisionHitbox.object = {}

function ResolveCollisionHitbox.object.Door(self, o, p)
    if p == BEGIN         then self.door = o
    elseif self.door == o then self.door = nil end
end

function ResolveCollisionHitbox.object.Power(self, o, p)
    if p ~= BEGIN then return end

    self.collision_power = o
end

return ResolveCollisionHitbox