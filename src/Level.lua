class.Level()

function Level:_init(mapfile)
    self.map = tiled.load(mapfile)

    self.entitiesInMap = {}
    self.entities      = {}
end

function Level:toXYO(x, y)
    return  math.floor(x / self.map.tileWidth),
            math.floor(y / self.map.tileHeight)
end

function Level:getCenter()
    return  self.map.tileWidth  * self.map.width  / 2,
            self.map.tileHeight * self.map.height / 2
end

function Level:getBorder()
    return  self.map.tileWidth  * self.map.width,
            self.map.tileHeight * self.map.height
end

function Level:add(entity)
    self.entities[entity] = true
    self:insertEntity(entity, self:toXYO(entity.x, entity.y))
end

function Level:remove(entity)
    self.entities[entity] = nil
    self:removeEntity(entity, self:toXYO(entity.x, entity.y))
end

function Level:getEntities(xo, yo, x1, y1)
    local w, h = self.map.width, self.map.height
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

function Level:tick(dt)
    for e,_ in pairs(self.entities) do
        local ixo, iyo = self:toXYO(e.x, e.y)
        e:tick(dt)
        if (e.removed) then
            self.entities[e] = nil
            self:removeEntity(e, ixo, iyo)
        else
            local fxo, fyo = self:toXYO(e.x, e.y)
            if fxo ~= ixo or fyo ~= iyo then
                self:removeEntity(e, ixo, iyo)
                self:insertEntity(e, fxo, fyo)
            end
        end
    end
end