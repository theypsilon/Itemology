local inspect = require 'inspect.inspect'

local function dump_nest_limit_string(object, level)
    local  object_t = type(object)
    if     object_t == 'userdata' and getmetatable(object) then
        object   = getmetatable(object)
        object_t = type(object)
    end
    if     object_t == 'function' then
        object   = dump_function(object)
    elseif object_t ~= 'string'   then
        object   = inspect(object, level)
    end
    return object
end

local function dump_string(...)
    local args = table.pack(...)
    if args.n == 1 and type(args[1]) == 'function' then
        return dump_function(args[1], true)
    elseif args.n == 0 then 
        return '<no params>'
    else
        local str = ''
        for i = 1, args.n do 
            local v = dump_nest_limit_string(args[i])
            v = is_string(args[i]) and ("'" .. v .. "'") or tostring(v) 
            str = str .. v .. '    ' 
        end
        return str
    end
end

local function dump_function_string(func, withcode)
    assert(debug)
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

local function dump(...)
    local str = dump_string(...)
    print('dump:', str)
end

local function dump_nest_limit(object, level)
    object = dump_nest_limit_string(object,level)
    print(object)
end

local function dump_function(func, withcode)
    local str = dump_function_string(func, withcode)
    print(str)
end

local exports = {
    -- print to stdout
    dump                   = dump,
    dump_nest_limit        = dump_nest_limit,
    dump_function          = dump_function,

    -- shorthands
    dumpi                  = dump_nest_limit,
    dumpf                  = dump_function,

    -- no print, returns string
    dump_function_string   = dump_function_string,
    dump_string            = dump_string,
    dump_nest_limit_string = dump_nest_limit_string
}

return exports