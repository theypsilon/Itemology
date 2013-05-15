local Layer = class('Layer')

function Layer:_init(map, layer)

end

local LayerObject = require 'map.LayerObject'
local LayerTile   = require 'map.LayerTile'

Layer.factory = {
    tilelayer   = LayerTile,
    objectlayer = LayerObject,
}

return Layer, LayerObject, LayerTile