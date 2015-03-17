local System; import 'ecs'
local ResolveCollisionPortal = class(System)

function ResolveCollisionPortal:requires()
    return {'portal'}
end


local function get_component(vertical, e)
    local  orientation = e[vertical and 'vx' or 'vy']
    if not orientation then
        local x, y = e.body:getLocation()
        orientation = vertical and x or y
    end
    return orientation
end

local function onBegin(self, e)
    local orientation = (self.orientation and not self.requesting[e]) 
        and self.orientation or get_component(self.vertical, e)
    self.travelling[e] = orientation > 0 and 1 or -1
end

local function onEnd(self, e)
    assert(self.travelling[e])
    local orientation = get_component(self.vertical, e)

    if (orientation * self.travelling[e] > 0 and not self.requesting[e]) or
       (orientation * self.travelling[e] < 0 and     self.requesting[e]) 
    then
        local exit = e.level.entityByName()[self.link][1]

        local offset = self.vertical and 
            (e.pos.y - self.pos.y) or (e.pos.x - self.pos.x)
        if exit.vertical ~= self.vertical then
            offset = -offset
            local vx, vy = e.body:getLinearVelocity()
            e.physic_change:setLinearVelocity(vy, vx)
        end
        local x, y
        if exit.vertical then
            x = exit.pos.x
            y = exit.pos.y + offset
        else
            x = exit.pos.x + offset
            y = exit.pos.y
        end
        e.body:setTransform(x, y)

        if not self.requesting[true] then
            exit.requesting[e] = true
        end
    end

    self.requesting[e] = nil
    self.travelling[e] = nil
end

local function process_package(self, e, package)
    local p, fa, fb, a = unpack(package)
    if fb.name ~= 'area' then return end
    local traveller = fb:getBody().parent
    if not traveller or not traveller.body then end
    local handler = p == MOAIBox2DArbiter.END and onEnd or onBegin
    handler(e, traveller)
end

function ResolveCollisionPortal:update(e, dt, portal)
    if table.empty(portal) then return end

    for _, package in pairs(portal) do
        process_package(self, e, package)
    end

    e.portal = {}
end


return ResolveCollisionPortal