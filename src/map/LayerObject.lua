local  Layer = require 'map.Layer'
local  LayerObject = class('LayerObject', Layer)

local function add(table, key, value)
    local place = table[key]
    if place then
        if type(place) == 'table' then table.insert(place, value)
                                  else place =     {place, value} end
    else
        table[key] = value
    end
end

local function converseXarg(object)
    local result = object.xarg
    for _, v in ipairs(object) do
        local sub, label = converseXarg(v)
        if not result[label] then result[label] = {} end
        local index = sub.name or (#result[label] + 1)
        add(result[label], index, sub)
    end
    return result, object.label
end



function LayerObject:_init(layer, map)
    self = layer
    self.map = map
    local objects = self.objects
    self.objects = {}
    for _, v in ipairs(objects) do
        local object = converseXarg(table.copy(v))
        dump(v)
        dumpi(object, 3)
        os.exit()
        add(self.objects, name, object)
    end
    dump(self.objects)
end

function LayerObject:__call(name, index)
    return index and self.objects[name][index] or self.objects[name]
end

return LayerObject