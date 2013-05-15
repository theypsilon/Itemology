function table.flip ( tab )
    local newTable = {}
 
    for k,v in pairs ( tab ) do
        newTable[v] = k
    end
 
    return newTable
end

if inspect and debug then
    global('dump', 'dumpi')
    if dump then error 'dump already defined' end
    local function internal_dump(object, level)
        local  object_t = type(object)
        if     object_t == 'userdata' and getmetatable(object) then
            object   = getmetatable(object)
            object_t = type(object)
        end
        if     object_t == 'function' then
            object   = debug.func(object)
        elseif object_t ~= 'string'   then
            object   = inspect(object,level)
        end
        return object
    end
    
    function dump(...)
        local args = table.pack(...)
        for k,v in ipairs(args) do
            args[k] = internal_dump(v)
        end
        print(unpack(args))
    end

    function dumpi(object, level)
        object = internal_dump(object,level)
        print(object)
    end

    function debug.func(f)
        return inspect(debug.getinfo(f))
    end
end