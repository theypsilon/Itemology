local function gen_is_type(thetype)
    return function(var) return type(var) == thetype end
end

local is_nil      = gen_is_type('nil')
local is_function = gen_is_type('function')
local is_number   = gen_is_type('number'  )
local is_string   = gen_is_type('string'  )
local is_boolean  = gen_is_type('boolean' )
local is_table    = gen_is_type('table'   )
local is_userdata = gen_is_type('userdata')
local is_thread   = gen_is_type('thread'  )

local function is_callable(f)
    if is_function(f) then return true end
     local mt = getmetatable(f)
    return mt and is_callable(mt.__call)
end

local function is_integer(n)
    return is_number(n) and math.floor(n) == n
end

local function is_path(s)
    if not is_string(s) then return false end
     local path = s:match('(.-)([^\\/]-%.?([^%.\\/]*))$')
    return path ~= ''
end

local function file_exist(path)
    if not is_string(path) then return false end

    local f=io.open(path ,"r")
    if f~=nil then 
        io.close(f) 
        return true 
    else 
        return false 
    end
end

local function is_dir(path)
    if not is_string(path) then return false end

    path = string.gsub(path, "^(.-)[\\/]?$", "%1")
    local f, _, code = io.open(path, "rb")
    
    if f then 
        _, _, code = f:read("*a")
        f:close()
        if code == 21 then
            return true
        end
    elseif code == 13 then
        return true
    end
    
    return false
end

local exports = {
    is_nil      = is_nil     ,
    is_function = is_function,
    is_number   = is_number  ,
    is_string   = is_string  ,
    is_boolean  = is_boolean ,
    is_table    = is_table   ,
    is_userdata = is_userdata,
    is_thread   = is_thread  ,
    is_callable = is_callable,
    is_integer  = is_integer
}

require('lib.Import').make_exportable(exports)

return exports