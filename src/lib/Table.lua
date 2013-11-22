local function flip ( tab )
    local newTable = {}
 
    for k,v in pairs ( tab ) do
        newTable[v] = k
    end
 
    return newTable
end

local function keys ( tab )
    local new = {}
    for k in pairs(tab) do
        new[#new + 1] = k
    end
    return new
end

local function count( tab )
    if type(tab) ~= 'table' then return 0 end
    local i = 0
    for _ in pairs(tab) do
        i = i + 1
    end
    return i
end

local function copy(from, to, deep)
    return deep and deep_copy(from, to) or shallow_copy(from, to)
end

local function deep_copy(from, to)
    local ret = (to == nil) and {} or to
    for k, v in pairs(from) do 
        ret[k] = type(v) == 'table' and deep_copy(v) or v 
    end
    return ret
end

local function shallow_copy(from, to)
    local ret = (to == nil) and {} or to
    for k, v in pairs(from) do 
        ret[k] = v 
    end
    return ret
end

local function compare(t1, t2)
    if type(t1) == type(t2) then
        if type(t1) == 'table' then
            local bool = true
            for k,v in pairs(t1) do bool = bool and compare(v,t2[k]) end
            return bool
        elseif type(t1) == 'function' then return true end
        return t1 == t2
    end
    return false
end

local function each_recursive(t, f, index, notKeys, each_dict, path)

    if type(t) == 'table' then 
        each_dict = each_dict or {}
        if each_dict[t] then return else each_dict[t] = true end

        path = path or ''

        f(index, t, path)

        for k,v in pairs(t) do 
            if not notKeys then 
                each_recursive(k, f, nil, notKeys, each_dict, path .. '#') 
            end
            each_recursive(v, f,   k, notKeys, each_dict, 
                path .. ((type(k) == 'string' or type(k) == 'number') 
                    and k or inspect(k)) .. '.')
        end
    else
        f(index, t, path)
    end
end

local function make_const( mutable )
    for k,v in pairs(mutable) do
        if type(k) == 'table' then
            mutable[k] = nil
            k = make_const(k)
            mutable[k] = v
        end
        if type(v) == 'table' then 
            mutable[k] = make_const(v) 
        end
    end
    return setmetatable({}, {
        __index     = mutable,
        __newindex  = function() error("const-violation on table") end,
        __metatable = false,
    });
end

local function map( tab , fn )
    local ret = {}
    for ik, iv in pairs(tab) do
        local fv, fk = fn(iv)
        ret[fk and fk or ik] = fv
    end
    return ret
end

local function at( tab, ... )
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

local function set( tab, val, ... )
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

local function pack(...)
    return { n = select("#", ...), ... }
end

local exports = {
    flip            = flip,
    keys            = keys,
    count           = count,
    copy            = copy,
    deep_copy       = deep_copy,
    shallow_copy    = shallow_copy,
    compare         = compare,
    each_recursive  = each_recursive,
    make_const      = make_const,
    at              = at,
    set             = set,
    pack            = pack
}

require('lib.Import').make_exportable(exports)

return exports