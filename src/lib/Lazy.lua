local function call(t) return t.val end

local function special_case(t, k, v, val)
    t.val = nil
    if not val then
        local  meta = getmetatable(t) or {}
        if not meta.__call then 
            meta.__call = call
            setmetatable(t, meta)
        end
    end
    return v or k and t[k] or val
end

local function make_value(t, k, v)
    setmetatable(t, nil)

    local  val  = t:_callback()
    t._callback = nil

    if not val or val == t then return special_case(t, k, v, val)
    else t.val  = val end

    setmetatable(t, {__index = val, __newindex = val, __call = call})

    return v or k and val[k] or val
end

local proxy = {
    _name       = 'lazy', 
    __index     = make_value, 
    __newindex  = make_value, 
    __call      = make_value
}

local function lazy(callback)
    assert(type(callback) == 'function')
    return setmetatable({val = false, _callback = callback}, proxy)
end

local exports = {lazy = lazy}

require('lib.Import').make_exportable(exports)

return exports