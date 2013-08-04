local  Layer = require 'map.Layer'
local  LayerObject = class('LayerObject', Layer)

local copy = table.shallow_copy

local function parseObjects(objects)
    local parsed = {}

    for _, element in ipairs(objects) do
        local child, label = parseObjects(element), element.label

        copy(element.xarg, child)

        if label == 'properties'   then
            parsed.  properties = child
        elseif label == 'property' then
            parsed[child.name]  = child.value
        else
            local  index  = child.name and child.name or (#parsed + 1)
            parsed[index] = child
            child.name    = nil
        end
    end
    return parsed
end

function LayerObject:_init(layer, map)
    copy(layer, self)

    self.objects = parseObjects(layer.objects)
    self.map     = map
end

function LayerObject:__call(name, index)
    return index and self.objects[name][index] or self.objects[name]
end

return LayerObject