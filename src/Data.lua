local meta = {}

function meta.__index(table, key)
    local letter = key:sub(0,1)
    local path   = rawget(table,'_path') or ''
    if letter == letter:upper() then
        rawset(table, key, require('data' .. path .. '.' .. key))
        return table[key]
    else
        table[key] = setmetatable({_path = path .. '.' .. key}, meta)
        return table[key]
    end
end

function meta.__newindex(table, key, value)
    rawset(table, key, value)
end

data = setmetatable({},meta)

function data._update()

    local function reload_data(path, node)
        local new = reload.file(path)
        if new then
            for k,_ in pairs(node) do node[k] = nil end
            for k,v in pairs(new)  do node[k] = v   end
        end
    end

    local function recursive_search(node, path)
        for k,v in pairs(node) do
            local letter = k:sub(0,1)
            if letter == '_' then

            elseif letter == letter:upper() then
                reload_data(path .. '.' .. k, v)
            else
                recursive_search(v, path .. '.' .. k)
            end
        end
    end

    recursive_search(data, 'data')
end

