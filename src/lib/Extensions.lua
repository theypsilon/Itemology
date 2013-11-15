function table.flip ( tab )
    local newTable = {}
 
    for k,v in pairs ( tab ) do
        newTable[v] = k
    end
 
    return newTable
end

function table.keys ( tab )
    local new = {}
    for k in pairs(tab) do
        new[#new + 1] = k
    end
    return new
end

function table.count( tab )
    if type(tab) ~= 'table' then return 0 end
    local i = 0
    for _ in pairs(tab) do
        i = i + 1
    end
    return i
end

function table.copy(from, to, deep)
    return deep and table.deep_copy(from, to) or table.shallow_copy(from, to)
end

function table.deep_copy(from, to)
    local ret = (to == nil) and {} or to
    for k, v in pairs(from) do 
        ret[k] = type(v) == 'table' and table.deep_copy(v) or v 
    end
    return ret
end

function table.shallow_copy(from, to)
    local ret = (to == nil) and {} or to
    for k, v in pairs(from) do 
        ret[k] = v 
    end
    return ret
end

function table.compare(t1, t2)
    if type(t1) == type(t2) then
        if type(t1) == 'table' then
            local bool = true
            for k,v in pairs(t1) do bool = bool and table.compare(v,t2[k]) end
            return bool
        elseif type(t1) == 'function' then return true end
        return t1 == t2
    end
    return false
end

function table.each_recursive(t, f, index, notKeys, each_dict, path)

    if type(t) == 'table' then 
        each_dict = each_dict or {}
        if each_dict[t] then return else each_dict[t] = true end

        path = path or ''

        f(index, t, path)

        for k,v in pairs(t) do 
            if not notKeys then 
                table.each_recursive(k, f, nil, notKeys, each_dict, path .. '#') 
            end
            table.each_recursive(v, f,   k, notKeys, each_dict, 
                path .. ((type(k) == 'string' or type(k) == 'number') 
                    and k or inspect(k)) .. '.')
        end
    else
        f(index, t, path)
    end
end

function table.pack(...)
    return { n = select("#", ...), ... }
end

function table.make_const( mutable )
    for k,v in pairs(mutable) do
        if type(k) == 'table' then
            mutable[k] = nil
            k = table.make_const(k)
            mutable[k] = v
        end
        if type(v) == 'table' then 
            mutable[k] = table.make_const(v) 
        end
    end
    return setmetatable({}, {
        __index     = mutable,
        __newindex  = function() error("const-violation on table") end,
        __metatable = false,
    });
end

function table.map( tab , fn )
    local ret = {}
    for ik, iv in pairs(tab) do
        local fv, fk = fn(iv)
        ret[fk and fk or ik] = fv
    end
    return ret
end

function table.at( tab, ... )
    local dim  = {...}
    local last = nil
    for _, d in ipairs(dim) do
        last = tab[d]
        if last then
            tab = last
        else
            return nil
        end
    end
    return last
end

function table.set( tab, val, ... )
    local dim    = {...}
    local lt, li = nil
    local ld = nil
    for _, d in ipairs(dim) do ld = d end
    for _, d in ipairs(dim) do
        if d == ld then
            tab[d] = val
            return
        end
        tab    = tab[d]
    end
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