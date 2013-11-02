local Layer = class('Layer')

function Layer:_init(layer, map)
    error 'this class is abstract'
end


local dispatch = nil
function Layer.factory(layer, ...)
    if not dispatch then
        dispatch = {
            tilelayer   = require 'map.LayerTile',
            objectlayer = require 'map.LayerObject',
        }
    end
    return dispatch[layer.type](layer, ...)
end

function Layer:setLayer(renderLayer)
    if self.layer and self.layer ~= renderLayer then
        self.layer:removeProp(self.prop)
    end

    self.layer = renderLayer
    renderLayer:insertProp(self.prop)

    self.prop.clear = renderLayer.clearProp -- ALLOCATE (possible memory-leak)
end

function Layer:setLoc(x, y)
    if self.x ~= x or self.y ~= y then
        self.x = x
        self.y = y
        self.prop:setLoc(x, y)
    end
end

function Layer:draw(x, y)
    local prop = self.prop
    flow.tempLayer:insertProp(prop)
    prop:setLoc(x or 0, y or 0)
end

return Layer