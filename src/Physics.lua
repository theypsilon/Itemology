local Data; import()

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

function Physics.registerFixtures(def, body, category, mask, group)
    local outFixtures = {}
    for k, v in pairs(def) do
        local out = Physics.addFixture(v, body, category, mask, group)
        if is_userdata(out) then out.name = k end
        outFixtures[k] = out
    end

    if body.density then body:resetMassData() end

    return outFixtures
end

function Physics.addFixture(def, body, category, mask, group)
    if is_array(def) then
        local fixtures  = {}
        for k, v in pairs(def) do
            fixtures[k] = Physics.addFixture(v, body, category, mask, group)
            fixtures[k].name = k
        end
        return fixtures
    end

    local fix = dict[def.option](body,  unpack(def.args))
    if def.restitution then fix:setRestitution(def.restitution) end
    if def.friction    then fix:setFriction   (def.friction   ) end
    if def.sensor      then fix:setSensor     (def.sensor     ) end
    if def.density     then fix:setDensity    (def.density    ) 
                                            body.density = true end

    local filters = category or mask or group
    if filters then
        local categoryBits, maskBits, groupIndex = fix:getFilter()
        fix:setFilter(
            category or categoryBits, 
            mask     or maskBits, 
            group    or groupIndex
        )
    end

    fix.kills  = def.kills
    fix.sensor = def.sensor

    return fix
end

function Physics:makeItemBody(x, y, option, params, prop)
    assert(is_number(x) and is_number(y), tostring(x) .. ':' .. tostring(y))
    assert(is_string(option), option)
    assert(is_array(params), var_export(params))
    return Physics:registerBody({
        option = 'static',
        fixtures = {
            ['area']={
                    option = option,
                    args   = params,
                    sensor = true
            },
        },
        x = x,
        y = y,

        fixCategory = Data.fixture.Filters.C_ITEM,
        fixMask     = Data.fixture.Filters.M_ITEM
    }, prop)
end

function Physics:clear()
    for _,v in pairs(self.bodies) do if v.clear then v:clear(); v.clear = nil end end
    self.bodies = {}--self.bodies = setmetatable({}, {__mode = 'kv'})
end

return Physics