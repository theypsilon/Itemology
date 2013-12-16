local inspect = require(project .. 'lib.inspect.inspect')

assert(debug)

local function internal_dump(object, level)
    local  object_t = type(object)
    if     object_t == 'userdata' and getmetatable(object) then
        object   = getmetatable(object)
        object_t = type(object)
    end
    if     object_t == 'function' then
        object   = dumpf(object)
    elseif object_t ~= 'string'   then
        object   = inspect(object, level)
    end
    return object
end

local function export_var(...)
    local args = table.pack(...)
    if args.n == 1 and type(args[1]) == 'function' then
        return dumpf(args[1], true)
    elseif args.n == 0 then 
        return '<no params>'
    else
        local str = ''
        for i = 1, args.n do 
            local v = internal_dump(args[i])
            v = is_string(args[i]) and ("'" .. v .. "'") or tostring(v) 
            str = str .. v .. '    ' 
        end
        return str
    end
end

local function dump(...)
    local str = export_var(...)
    print('dump:', str)
end

local function dumpi(object, level)
    object = internal_dump(object,level)
    print(object)
end

local function dumpf(func, withcode)
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

local exports = {
    dump            = dump,

    dumpi           = dumpi,
    dump_nest_limit = dumpi,

    dumpf           = dumpf,
    dump_function   = dumpf,

    export_var      = export_var,
}

require('lib.Import').make_exportable(exports)

return exports