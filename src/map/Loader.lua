local loader = {}

function loader.lua(source)
    local  map = dofile(source)
    return map
end

local xml, decompress, base64 = nil, nil, nil
local function loadAuxLibs()
    if not xml or not decompress or not base64 then
        global{TILED_LOADER_PATH = 'lib.ATL/'}
        xml        = require 'lib.ATL.external.xml'
        decompress = require 'lib.ATL.external.deflatelua'
        base64     = require 'lib.ATL.Base64'
    end
end

local function decodeData(package)
    local data = {}

    if package.xarg.encoding == "base64" then
    
        -- If a compression method is used
        if package.xarg.compression == "gzip" or package.xarg.compression == "zlib"  then
            -- Select the appropriate function
            local decomp = package.xarg.compression == "gzip" and decompress.gunzip or decompress.inflate_zlib
            -- Decompress the string into bytes
            local bytes = {}
            decomp({input = base64.decode("string", package[1]), output = function(b) bytes[#bytes+1] = b end})
            -- Glue the bytes into ints
            for i=1,#bytes,4 do
                data[#data+1] = base64.glueInt(bytes[i],bytes[i+1],bytes[i+2],bytes[i+3])
            end
        -- If there is no compression then just convert to ints
        else
            data = base64.decode("int", package[1])
        end

    else
        for _,v in ipairs(package) do
            if v.label == "tile" then 
                data[#data+1] = tonumber(v.xarg.gid)
            end
        end
    end

    return data
end

local function set_numbers(table)
    for k,v in pairs(table) do
        local number = tonumber(v)
        if type(v) == 'string' and number then
            table[k] = number
        end
    end
    return table
end

function loader.tmx(source)
    loadAuxLibs()

    local content = xml.string_to_table(io.input(source):read("*all"))
    content = (function()
        for _, node in ipairs(content) do
            if node.label == 'map' then
                return node
            end
        end
        error('contents of "'..source..'" not labeled as map')
    end)()

    local map = content.xarg
    map.layers      = {}
    map.tilesets    = {}
    map.luaversion  = _VERSION
    map.version     = map.version     or '1.1'
    map.orientation = map.orientation or 'orthogonal'

    for _, node in ipairs(content) do
        if node.label == 'tileset' then
            local tileset       = node.xarg

            tileset.image       = node[1].xarg.source
            tileset.imageheight = node[1].xarg.height
            tileset.imagewidth  = node[1].xarg.width
            tileset.margin      = tileset.margin     or 0
            tileset.properties  = tileset.properties or {}
            tileset.spacing     = tileset.spacing    or 0
            tileset.tiles       = tileset.tiles      or {}

            map.tilesets[#map.tilesets + 1] = set_numbers(tileset)
        elseif node.label == 'layer' then
            local layer = node.xarg

            layer.data      = decodeData(node[1])
            layer.encoding  = layer.encoding  or 'lua'
            layer.opacity   = layer.opacity   or 1
            layer.poperties = layer.poperties or {}
            layer.x         = layer.x         or 0
            layer.y         = layer.y         or 0
            layer.type      = layer.type      or 'tilelayer'
            layer.visible   = type(layer.visible) == 'boolean' and layer.visible or true

            map.layers[#map.layers + 1] = set_numbers(layer)
        elseif node.label == 'objectgroup' then
            local layer = node.xarg
            layer.type  = 'objectlayer'
            layer.objects = {}
            for _,o in ipairs(node) do
                table.insert(layer.objects, o)
            end
            
            map.layers[#map.layers + 1] = set_numbers(layer)
        end
    end

    return set_numbers(map)
end

return loader