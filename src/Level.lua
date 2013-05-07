class.Level()

function Level:_init(mapfile)
    self.map = tiled.load(mapfile)
    self.entitiesInMap = {}
    self.entities      = {}
end

function Level:add(entity)
    self.entities[entity] = true
    self:insertEntity(entity, entity.x, entity.y)
end

function Level:remove(entity)
    self.entities[entity] = nil
    self:removeEntity(entity, entity.x, entity.y)
end

function Level:getEntities(xo, yo)
    local w, h = self.map.width, self.map.height
    if xo < 0 or yo < 0 or xo > w or yo > h then return {} end
    local list = self.entitiesInMap[yo * self.w + xo]
    if type(list) ~= 'table' then
        list = {}
        self.entitiesInMap[yo * self.w + xo] = list
    end
    return list
end

function Level:insertEntity (entity, xo, yo)
    self:getEntities(xo, yo)[entity] = true
end

function Level:removeEntity (entity, xo, yo)
    self:getEntities(xo, yo)[entity] = nil
end

function Level:tick(dt)
    for e,_ in pairs(self.entities) do
        local ixo, iyo = e.x, e.y
        e:tick(dt)
        local fxo, fyo = e.x, e.y
        if fxo ~= ixo or fyo ~= iyo then
            self:removeEntity(e, ixo, iyo)
            self:insertEntity(e, fxo, fyo)
        end
    end
end