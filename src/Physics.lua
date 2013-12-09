local Physics = {}
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

local function clear_error() error 'im already cleared' end

function bodyTable:clear()
    for k,v in pairs(self.fixtures) do v:destroy() end
    self:destroy()
    self.fixtures = nil
    self.clear    = false--clear_error
end

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

    if def.mass          then body:setMassData(def.mass)               end
    if def.fixedRotation then body:setFixedRotation(def.fixedRotation) end
    if def.bullet        then body:setBullet(def.bullet)               end
    if def.gravityScale  then body:setGravityScale(def.gravityScale)   end
    if parent            then body.parent = parent                     end

    body.fixtures = self.registerFixtures( 
        def.fixtures or {}, body,
        def.fixCategory, def.fixMask, def.fixGroup 
    )

    self.bodies[#self.bodies + 1] = body

    return body
end

function Physics.registerFixtures(fixtures, body, category, mask, group)
    local filters = category or mask or group

    local outFixtures = {}

    local density

    for k, value in pairs(fixtures) do
        local fix = dict[value.option](body,  unpack(value.args))
        if value.restitution then fix:setRestitution(value.restitution) end
        if value.friction    then fix:setFriction   (value.friction   ) end
        if value.sensor      then fix:setSensor     (value.sensor     ) end
        if value.density     then fix:setDensity    (value.density    ) 
                                                         density = true end

        if filters then
            local categoryBits, maskBits, groupIndex = fix:getFilter()
            fix:setFilter(
                category or categoryBits, 
                mask     or maskBits, 
                group    or groupIndex
            )
        end

        fix.name   = k
        fix.sensor = value.sensor

        outFixtures[k] = fix
    end

    if density then body:resetMassData() end

    return outFixtures
end

function Physics:clear()
    for _,v in pairs(self.bodies) do if v.clear then v:clear(); v.clear = nil end end
    self.bodies = {}--self.bodies = setmetatable({}, {__mode = 'kv'})
end

return Physics