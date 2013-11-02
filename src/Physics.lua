local Physics = {}

local data = require 'Data'

function Physics:init(def)
    if not self.started then
        local world = MOAIBox2DWorld.new()
        world:setGravity  (unpack(def.gravity))
        world:setUnitsToMeters   (def.unitsToMeters)
        world:setIterations      (def.iterations)
        world:setAutoClearForces (def.autoClearForces)
        world:start()

        self.world  = world
        self.bodies = {}--setmetatable({}, {__mode = 'kv'})

        self.started = true
    end
end

local dict, bodyTable = {}, MOAIBox2DBody.getInterfaceTable()

dict['static'   ] = MOAIBox2DBody.STATIC
dict['dynamic'  ] = MOAIBox2DBody.DYNAMIC
dict['kinematic'] = MOAIBox2DBody.KINETIC

dict['rect'     ] = bodyTable.addRect
dict['circle'   ] = bodyTable.addCircle
dict['chain'    ] = bodyTable.addChain

bodyTable = nil

function Physics:registerBody(def, prop, parent)

    local body = self.world:addBody (
        dict[def.option],
        def.x or nil,
        def.y or nil
    )

    if prop then prop:setAttrLink ( 
        MOAIProp2D.INHERIT_TRANSFORM, 
        body, 
        MOAIProp2D.TRANSFORM_TRAIT 
    ) end

    if def.mass          then body:setMassData(def.mass) body:resetMassData() end
    if def.fixedRotation then body:setFixedRotation(def.fixedRotation)        end
    if parent            then body.parent = parent                            end

    local outFixtures = {}

    for k, value in pairs(def.fixtures) do
        local fix = dict[value.option](body,  unpack(value.args))
        if value.density     then fix:setDensity    (value.density    ) end
        if value.restitution then fix:setRestitution(value.restitution) end
        if value.friction    then fix:setFriction   (value.friction   ) end
        if value.sensor      then fix:setSensor     (value.sensor     ) end

        fix.name = k

        outFixtures[k] = fix
    end

    body.fixtures = outFixtures
    body.clear = function(self) 
        for k,v in pairs(self.fixtures) do v:destroy() end
        self:destroy() 
    end -- ALLOCATE (memory-leak)

    local GC = require 'Test'
    body.gc = GC()

    self.bodies[#self.bodies + 1] = body

    return body, outFixtures
end

function Physics:clear()
    for _,v in pairs(self.bodies) do if v.clear then v:clear(); v.clear = nil end end
    self.bodies = {}--self.bodies = setmetatable({}, {__mode = 'kv'})
end

return Physics