local Layer, Data; import()

local Map, Util; import 'map'

local Level = class()

local function lazyLoadEntityByName(self)
    if self.entityByName and not self.entityByName.val then 
        return self.entityByName 
    end
    return lazy(function()
        local table = {}
        for e,_ in pairs(self.entities) do
            local name = e._name or '<none>'
            local sub  = table[name]
            if sub then sub[#sub + 1] = e
            else table[name] = {e} end
        end
        return table
    end)
end

function Level:_init(mapfile)
    self.name = mapfile 
    self.map  = Map(mapfile)
    self.map:setLayer(Layer.main)

    self.entitiesInMap = {}
    self.entities      = {}

    self.entityByName = lazyLoadEntityByName(self)
end

local function clear_entity(self)
    if self.body and self.body.clear then
        self.body:clear()
        self.body.clear = nil
        self.body = nil
    end
    if self.animation and not self.prop then
        self.prop = self.animation.prop
        self.animation = nil
    end
    if self.prop then 
        self.prop:clear()
        self.prop.clear = nil
        self.prop = nil
    end
end

function Level:add(entity)
    if entity.clear then error 'what are you doing bro' end
    if not entity.clear then entity.clear = clear_entity end
    self.entities[entity] = true
    self:insertEntity(entity, self.map:toXYO(entity.x, entity.y))
    self.entityByName = lazyLoadEntityByName(self)
end

function Level:remove(entity)
    self.entities[entity] = nil
    self:removeEntity(entity, self.map:toXYO(entity.x, entity.y))
    self.entityByName = lazyLoadEntityByName(self)
end

function Level:getEntities(xo, yo, x1, y1)
    local w, h = self.map.mapWidth, self.map.mapHeight
    if xo < 0 or yo < 0 or xo > w or yo > h then return {} end
    if not x1 or not y1 then
        local list = self.entitiesInMap[yo * w + xo]
        if type(list) ~= 'table' then
            list = {}
            self.entitiesInMap[yo * w + xo] = list
        end
        return list
    else
        if xo > x1 or yo > y1 or x1 > w or y1 > h then return {} end
        local list = {}
        for x = xo, x1 do
            for y = yo, y1 do
                for e,_ in pairs(self:getEntities(x, y)) do
                    list[e] = true
                end
            end    
        end
        return list
    end
end

function Level:insertEntity (entity, xo, yo)
    self:getEntities(xo, yo)[entity] = true
end

function Level:removeEntity (entity, xo, yo)
    self:getEntities(xo, yo)[entity] = nil
end

function Level:tick(dt, xo, yo, x1, y1)
    for e,_ in pairs(self.entities) do
        local ixo, iyo = self.map:toXYO(e.x, e.y)
        e:tick(dt)
        assert(type(ixo) == 'number')
        assert(type(iyo) == 'number')
        if e.removed then
            if e.prop then e.prop:clear(); e.prop = nil end
            if e.body then e.body:clear(); e.body = nil end
            self.entities[e] = nil
            self:removeEntity(e, ixo, iyo)
        else
            local fxo, fyo = self.map:toXYO(e.x, e.y)
            assert(type(fxo) == 'number')
            assert(type(fyo) == 'number')
            if fxo ~= ixo or fyo ~= iyo then
                self:removeEntity(e, ixo, iyo)
                self:insertEntity(e, fxo, fyo)
            end
        end
    end
    if self.script then self.script() end
end

function Level:clear()
    self:clearEntities()
    self:clearStructure()
end

function Level:clearEntities()
    for e,_ in pairs(self.entities) do
        if e.clear then e:clear(); e.clear = nil end
    end
end

function Level:clearStructure()
    if self.structure and self.structure.clear then
        self.structure:clear()
        self.structure.clear = nil
        self.structure = nil
    end
end

function Level:initEntities(layer)
    layer = layer._name == 'LayerObject' and layer or self.map(layer)
    for k,v in pairs(layer.objects) do
        if v.x and v.y and v.type then
            local def = Data.entity[v.type]
            local e   = require(def.class)(self, def, v, layer, k)
            if e then 
                self:add(e) 
            end
        end
    end
end

function Level:initStructure(layer)
    layer = layer._name == 'LayerObject' and layer or self.map(layer)
    self.structure = Util.makeChainFixtures(Util.getSolidStructure(layer, true))
end

function Level:initProperties(camera)
    local p = self.map.properties
    if p and p.script then
        self.script = require('data.level.' .. p.script)(self, camera)
    end
end

return Level