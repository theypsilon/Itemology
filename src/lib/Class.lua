local error, getmetatable, io, pairs, rawget, rawset, setmetatable, tostring, type =
    _G.error, _G.getmetatable, _G.io, _G.pairs, _G.rawget, _G.rawset, _G.setmetatable, _G.tostring, _G.type

local class = {}

local    metaclass = {}
function metaclass.__call(f, ...)
    local params = class.split_params({...})
    return class.new(params.mixin, params.string and params.string[1] or nil)
end

function metaclass.__index(t, name)
    local env = _G
    return function(base)
        local  klass = class.new(base, name)
        rawset(env, name, klass)
        return klass
    end
end

setmetatable(class, metaclass)

local function inherit(class, base)
    local init = class._init
    for k,v in pairs(base) do
        class[k] = v
    end
    if init and base._init and init ~= base._init then
        function class._init() 
            error('this class needs to define the _init method,'
                ..' cause his multiple bases define the same')
        end
    end
end

local function is_a_helper(class1, class2)
    if not class1 then return false end
    if class1 == class2 then return true end
    local bases = rawget(class1,'_base')
    if #bases > 0 then
        for _,b in ipairs(bases) do
            if is_a_helper(b, class2) then return true end
        end
    end
    return false
end

--

function class.new(base, name)
    local metaklass = {} 
    local     klass = setmetatable({}, metaklass)
    function metaklass.__call(t,...)
        local obj = setmetatable({}, klass)

        local ctor = rawget(klass, '_init')
        if ctor then 
            local res = ctor(obj,...)
            if res then 
                obj = res
                if class.get_class(obj) ~= klass then setmetatable(obj, klass) end
            end
        end

        if rawget(klass, '__gc') then class.make_finalizable(obj) end

        if not rawget(klass, '__tostring') then
            klass.__tostring = class.tostring
        end
        return obj
    end

    if base then

        if type(base) ~= 'table' or class.is_mixin(base) then
            base = {base}
        end

        for _,b in ipairs(base) do
            if not class.is_mixin(b) then
                error("must derive from a class/mixin",3)
            end        
            inherit(klass, b)
        end

        klass._base = base
    end
    
    klass.__index = klass
    klass.is_a    = class.is_a
    klass._name   = name

    return klass
end

function class.is_a(obj, klass)
    return is_a_helper(class.get_class(obj), klass)
end

function class.get_class(obj)
    local meta = getmetatable(obj)
    if type(meta.__userdata) == 'userdata' then meta = getmetatable(meta) end
    if class.is_class(meta) then return meta end
    return nil
end

function class.tostring(obj)
    local mt = getmetatable(obj)
    local name = rawget(mt,'_name')
    setmetatable(obj,nil)
    local str = tostring(obj)
    setmetatable(obj,mt)
    if name then str = name ..str:gsub('table','') end
    return str
end

function class.is_mixin(mixin)
    if type(mixin) ~= 'table' then return false end
    local any = false

    for k,_ in pairs(mixin) do
        if type(k) ~= 'string' then return false end
        any = true
    end
    return any
end

function class.is_class(c)
    return class.is_mixin(c) and c.__index == c
end

function class.make_finalizable(obj)
    local udata = newproxy(true)
    local umeta = getmetatable(udata)
    local klass = getmetatable(obj)
    if type(obj) ~= 'table'      then return false end
    if not class.is_class(klass) then return false end
    if not klass.__gc            then return false end
    setmetatable(umeta, klass)
    for k, v in pairs(obj) do
        umeta[k] = v
        obj  [k] = nil
    end
    setmetatable (obj, umeta)
    umeta.__index    = umeta
    umeta.__newindex = umeta
    umeta.__gc       = function(self) klass.__gc(self) end
    umeta.__userdata = udata
end

function class.split_params(param)
    local result = {}
    if class.is_mixin(param) then
        result.mixin  = {param}
    elseif type(param) == 'table' then
        for _,subparam in ipairs(param) do
            for k, subresult in pairs(class.split_params(subparam)) do
                if not result[k] then result[k] = subresult
                else for _, v in ipairs(subresult) do
                    table.insert(result[k], v) 
                end end
            end
        end
    else
        result[type(param)] = {param}
    end
    return result
end

class.properties = class()

function class.properties.__index(t,key)
    -- normal class lookup!
    local v = klass[key]
    if v then return v end
    -- is it a getter?
    v = rawget(klass,'get_'..key)
    if v then
        return v(t)
    end
    -- is it a field?
    return rawget(t,'_'..key)
end

function class.properties.__newindex(t,key,value)
    -- if there's a setter, use that, otherwise directly set table
    local p = 'set_'..key
    local setter = klass[p]
    if setter then
        setter(t,value)
    else
        rawset(t,key,value)
    end
end


return class