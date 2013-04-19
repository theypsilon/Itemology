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

function import(paths, floorpath, match)
    local oldrequire = require
    require = type(floorpath) == 'string' and hackedRequire(floorpath, match) or require
    for _,v in pairs(paths) do
        require(v)
    end
    require = oldrequire
end