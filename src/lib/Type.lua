local function gen_is_type(thetype)
    return function(var) return type(var) == thetype end
end

local is_function = gen_is_type('function')
local is_number   = gen_is_type('number'  )
local is_string   = gen_is_type('string'  )
local is_boolean  = gen_is_type('boolean' )
local is_table    = gen_is_type('table'   )
local is_userdata = gen_is_type('userdata')

local function is_callable(f)
    return is_function(f) or 
        is_callable(getmetatable(f).__call)
end

local function is_integer(n)
    return is_number(n) and math.floor(n) == n
end

local exports = {
    is_function = is_function,
    is_number   = is_number  ,
    is_string   = is_string  ,
    is_boolean  = is_boolean ,
    is_table    = is_table   ,
    is_userdata = is_userdata,
    is_callable = is_callable,
    is_integer  = is_integer
}

require('lib.Import').make_exportable(exports)

return exports