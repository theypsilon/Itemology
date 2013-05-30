local  Layer = require 'map.Layer'
local  LayerObject = class('LayerObject', Layer)

local function add(table, key, value)
    if key == nil then key = #table + 1 end
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
        if v.xarg then
            local sub, label = converseXarg(v)
            result[label] = result[label] or {}
            add(result[label], sub.name, sub)
        end
    end
    return result, object.label
end

function table.deep_copy(old)
    local new = {}
    for k, v in pairs(old) do 
        new[k] = type(v) == 'table' and table.deep_copy(v) or v 
    end
    return new
end

function LayerObject:_init(layer, map)
    self = layer
    self.map = map
    local objects = self.objects
    self.objects = {}
    for _, v in ipairs(objects) do
        dump(v)
        local object = converseXarg(v)
        dump(object)
        os.exit()
        add(self.objects, name, object)
    end
    dump(self.objects)
end

function LayerObject:__call(name, index)
    return index and self.objects[name][index] or self.objects[name]
end

return LayerObject