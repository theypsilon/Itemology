class.Physics()

function Physics:_init()
    local world = MOAIBox2DWorld.new()

    world:setGravity( 0, 10 )
    world:setUnitsToMeters( .10 )
    world:setIterations( 10, 10 )
    world:setAutoClearForces(true)
    world:start()

    self.world = world
end

function Physics:update()
end

local dict = {}
dict['static'   ] = MOAIBox2DBody.STATIC
dict['dynamic'  ] = MOAIBox2DBody.DYNAMIC
dict['kinematic'] = MOAIBox2DBody.KINETIC

local   bodyTable = MOAIBox2DBody.getInterfaceTable()
     dict['rect'] = bodyTable.addRect
        bodyTable = nil

function Physics:addBody(def)

    local body = self.world:addBody (
        dict[def.option],
        def.x or nil,
        def.y or nil
    )

    if def.prop          then def.prop:setAttrLink ( 
        MOAIProp2D.INHERIT_TRANSFORM, 
        body, 
        MOAIProp2D.TRANSFORM_TRAIT 
    ) end

    if def.mass          then body:setMassData(def.mass) body:resetMassData() end
    if def.fixedRotation then body:setFixedRotation(def.fixedRotation)        end
    if def.parent        then body.parent = def.parent                        end

    local outFixtures = {}
    dict['rect'] = body.addRect

    for _, value in ipairs(def.fixtures) do
        local fix = dict[value.option](body,  unpack(value.args))
        if value.density     then fix:setDensity    (value.density    ) end
        if value.restitution then fix:setRestitution(value.restitution) end
        if value.friction    then fix:setFriction   (value.friction   ) end
        if value.sensor      then fix:setSensor     (value.sensor     ) end

        outFixtures[#outFixtures + 1] = fix
    end

    return body, outFixtures
end

global{ physics = Physics() }