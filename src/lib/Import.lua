local function add_package_path(path)
    if path == '' then return end
    package.path = package.path .. ';' .. path .. '?.lua'
    package.path = package.path .. ';' .. path .. '?/init.lua'
end

local function assert_string(string)
    if type(string) ~= 'string' then
        error('wrong format, string expected, but got '..type(string))
    end
end

local function is_dir(path)
    local  endchar = path:sub(-1)
    return endchar == '/' or endchar == '.'
end

local function get_file(path)
    local i = #path
    while i > 0 and not is_dir(path:sub(i,i)) do
        i = i - 1
    end
    return path:sub(i+1,#path)
end

local function hack_require(pathTable)
    for k, v in pairs(pathTable) do
        if type(k) == 'table' then
            for _, path in ipairs(k) do
                pathTable[path] = v
            end
            pathTable[k] = nil
        else assert_string(k) end
    end
    local require = require
    return function(path)
        assert_string(path)
        local search = pathTable[path]
        if search == nil then
            return require(path)
        else
            return require(is_dir(search) and search..path or search)
        end
    end
end

local function import(pathTable, envscope, declwithdirs)
    local oldpackage = package.path
    local oldrequire = require
    local env = envscope or {}
    for k,v in pairs(pathTable) do
        if type(k) == 'number' then
            if is_dir(v) then
                add_package_path(v)
            else
                env[declwithdirs and v or get_file(v)] = require(v)
            end
            pathTable[k] = nil
        end
    end
    require = hack_require(pathTable)
    for k,_ in pairs(pathTable) do
        env[declwithdirs and k or get_file(k)] = require(k)
    end
    require      = oldrequire
    package.path = oldpackage
    return env
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