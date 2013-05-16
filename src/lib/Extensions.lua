function table.flip ( tab )
    local newTable = {}
 
    for k,v in pairs ( tab ) do
        newTable[v] = k
    end
 
    return newTable
end

function table.pack(...)
    return { n = select("#", ...), ... }
end

if inspect and debug then
    global('dump', 'dumpi', 'dumpfunctions')
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
            object   = inspect(object, level)
        end
        return object
    end

    dumpfunctions = false
    
    function dump(...)
        local args = table.pack(...)
        if args.n == 1 and type(args[1]) == 'function' then
            args = {debug.func(args[1], true)}
        elseif args.n == 0 then 
            args = {'<no params>'} 
        else
            for i = 1, args.n do args[i] = internal_dump(args[i]) end
        end
        print('dump:', unpack(args))
    end

    function dumpi(object, level)
        object = internal_dump(object,level)
        print(object)
    end

    function debug.func(func, withcode)
        withcode = withcode or dumpfunctions
        local desc   = debug.getinfo(func)
        local result = inspect(desc)
        if desc.short_src and withcode then
            local code = {}
            local i = 1
            for line in io.lines(desc.short_src) do 
                if i >= desc.linedefined and i <= desc.lastlinedefined then
                    code[#code+1] = line
                end
                i = i + 1
            end
            result = "\n" .. table.concat(code, "\n") .. "\n" .. result
        end
        return result
    end

end