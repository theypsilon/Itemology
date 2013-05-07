class.Level()

function Level:_init(mapfile)
    self.map = tiled.load(mapfile)
    self.entitiesInMap = {}
    self.entities      = {}
end

function Level:add(entity)
    table.insert(self.entities, entity) 
    self:insertEntity(entity, entity.x, entity.y)
end

function Level:remove(entity)
    for k,v in ipairs(self.entities) do
        if v == entity then self.entities[k] = nil return end
    end
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

function Level:insertEntity(entity, xo, yo)
    table.insert(self:getEntities(xo, yo), entity)
end

function Level:removeEntity(entity, xo, yo)
    local list = self:getEntities(xo, yo)
    for k,v in ipairs(list) do
        if v == entity then list[k] = nil return end
    end
end

function Level:tick(dt)
    for _,e in ipairs(self.entities) do
        local ixo, iyo = e.x, e.y
        e:tick(dt)
        local fxo, fyo = e.x, e.y
        if fxo ~= ixo or fyo ~= iyo then
            self:removeEntity(e, ixo, iyo)
            self:insertEntity(e, fxo, fyo)
        end
    end
end