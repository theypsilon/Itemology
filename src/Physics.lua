class.Physics()

function Physics:_init()
    local world = MOAIBox2DWorld.new()
    self.world = world
end

function Physics:start()
    self.world:start(data.world.First)
end

function Physics:update()
end

local dict, bodyTable = {}, MOAIBox2DBody.getInterfaceTable()

dict['static'   ] = MOAIBox2DBody.STATIC
dict['dynamic'  ] = MOAIBox2DBody.DYNAMIC
dict['kinematic'] = MOAIBox2DBody.KINETIC

dict['rect'     ] = bodyTable.addRect
dict['circle'   ] = bodyTable.addCircle

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

    for k, value in pairs(def.fixtures) do
        local fix = dict[value.option](body,  unpack(value.args))
        if value.density     then fix:setDensity    (value.density    ) end
        if value.restitution then fix:setRestitution(value.restitution) end
        if value.friction    then fix:setFriction   (value.friction   ) end
        if value.sensor      then fix:setSensor     (value.sensor     ) end

        outFixtures[k] = fix
    end

    return body, outFixtures
end

global{ physics = Physics() }

physics:start()