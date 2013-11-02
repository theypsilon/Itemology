local function temp_add_prop(self, prop, ...)
    table.insert(self.temp, prop)
    self:insertProp(prop, ...)
end

local function clear_temp(self)
    for _, prop in pairs(self.temp) do
        self:removeProp(prop)
    end
    self.temp = {}
end

local function make_layer(t, index)
    print('creating layer "'..index..'"')

    local newLayer      = MOAILayer2D.new()
    newLayer.temp       = {}
    newLayer.insertTemp = temp_add_prop
    newLayer. clearTemp = clear_temp
    newLayer. clearProp = function(prop)
        newLayer:removeProp(prop) 
    end

    newLayer:setViewport(viewport)
    
    MOAIRenderMgr.setRenderTable{newLayer}

    rawset(t, index, newLayer)
    
    return newLayer
end

return setmetatable({}, { 
    __index    = make_layer, 
    __newindex = function() error 'impossible' end 
})