local Layer = class('Layer')

function Layer:_init(layer, map)
    -- dump(layer)
    -- os.exit()
end


local dispatch = nil
function Layer.factory(layer, ...)
    if not dispatch then
        dispatch = {
            tilelayer   = require 'map.LayerObject',
            objectlayer = require 'map.LayerTile',
        }
    end
    return dispatch[layer.type](layer, ...)
end

return Layer