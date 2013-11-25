local function add_package_path(path)
    if path == '' then return end
    package.path = package.path .. ';' .. path .. '?.lua'
    package.path = package.path .. ';' .. path .. '?/init.lua'
end

local function empty_locals(level)
    local variables, idx = {}, 1

    while true do
        local ln, lv = debug.getlocal(level, idx)
        if ln == nil then               break end
        if lv == nil then variables[ln] = idx end
        idx = 1 + idx
    end

    return variables
end

local function import(path)
    path = path and (path .. '.') or ''
    for k,v in pairs(empty_locals(3)) do 
        debug.setlocal(2, v, require(path .. k)) 
    end
end

local    metaexport = {}
function metaexport.__call(t, env)
    env = env or _G
    for k, v in pairs(t) do
        assert(not rawget(env, k) , k .. ' is already defined')
        assert(type(k) == 'string', 'only strings are allowed')
        rawset(env, k, v)
    end
end

local function make_exportable(exports)
    assert(not getmetatable(exports), 'cant make this exportable')
    setmetatable(exports, metaexport)
    return exports
end

return make_exportable {
    add_package_path = add_package_path,
    import           = import,
    make_exportable  = make_exportable
}