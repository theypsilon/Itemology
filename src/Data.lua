local Tasks; import()

local meta = {}
function meta.__index(table, key)
    local letter = key:sub(0,1)
    local path   = rawget(table,'_path') or ''
    if letter == letter:upper() then
        local new = require('data' .. path .. '.' .. key)
        rawset(table, key, new)
        return table[key]
    else
        table[key] = setmetatable({_path = path .. '.' .. key}, meta)
        return table[key]
    end
end

function meta.__newindex(table, key, value)
    rawset(table, key, value)
end

local data = setmetatable({},meta)

local function reload_data(path, node, alwaysload)
    node = node  or require(path)
    local new = reload.file(path, alwaysload)
    if alwaysload and not table.compare(node, new) then
        error('data objects are readonly, but "' .. path .. '" has been touched')
    elseif new then
        for k,_ in pairs(node) do node[k] = nil end
        for k,v in pairs(new)  do node[k] = v   end
    end
end

function data._autoUpdate(alwaysload)

    local function recursive_search(node, path, alwaysload)
        for k,v in pairs(node) do
            local letter = k:sub(0,1)
            if letter == '_' then

            elseif letter == letter:upper() then
                reload_data(path .. '.' .. k, v, alwaysload)
            else
                recursive_search(v, path .. '.' .. k, alwaysload)
            end
        end
    end

    recursive_search(data, 'data', alwaysload)
end

function data._update()
    reload_data('data.move.Mario')
    reload_data('data.move.Goomba')
end

if data.MainConfig.dev.sanitychecks   then
    Tasks:set('dataAssertImmutable', function() data._autoUpdate(true) end)
end
if data.MainConfig.dev.autoreloaddata then
    Tasks:set('dataAutoUpdate'     , data._autoUpdate                     )
end
if data.MainConfig.dev.reloaddata     then
    Tasks:set('dataUpdate'         , data._update                         )
end

global{data = data}

return data