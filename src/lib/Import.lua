local function hackedRequire(floorpath, match)
    local len     = type(match) == 'string' and match:len() or nil
    local require = require
    return function(path)
        if len and path:sub(0,len) == match then
            return require(floorpath .. path)
        else
            return require(path)
        end
    end
end

function import(paths, floorpath, match, envscope)
    local oldrequire = require
    require = type(floorpath) == 'string' and hackedRequire(floorpath, match) or require
    local env = envscope or {}
    for _,v in pairs(paths) do
        if type(v) == 'table' then
            if not v[1] or not v[2] then error 'wrong import usage' end
            env[v[2]] = require(v[1])
        else
            env[v] = require(v)
        end
    end
    require = oldrequire
    return env
end