--
-- strict.lua
-- checks uses of undeclared global variables
-- All global variables must be 'declared' through a regular assignment
-- (even assigning nil will do) in a main chunk before being used
-- anywhere or assigned to inside a function.
--

local env = _G

local mt = getmetatable(env)
if mt == nil then
  mt = {}
  setmetatable(env, mt)
else
  assert(not mt.__newindex)
  assert(not mt.__declared)
  assert(not mt.__index   )
end

mt.__declared = {}

mt.__newindex = function (t, n, v)
  if __STRICT and not mt.__declared[n] then
    local w = debug.getinfo(2, "S").what
    if w ~= "main" and w ~= "C" then
      error("assign to undeclared variable '"..n.."' in ", 2)
    end
    mt.__declared[n] = true
  end
  rawset(t, n, v)
end
  
mt.__index = function (t, n)
  if __STRICT and not mt.__declared[n] and debug.getinfo(2, "S").what ~= "C" then
    error("variable '"..n.."' is not declared", 2)
  end
  return rawget(t, n)
end

local function global(...)
  local params = {...}
  if params[1]  and  type(params[1]) == 'table' 
  then for k, v in  pairs(params[1]) do mt.__declared[k] = true; env[k] = v end
  else for _, v in ipairs(params)    do mt.__declared[v] = true end 
  end
end

local function defined(var) return mt.__declared[var] or rawget(env,var) ~= nil end

local exports = {
  __STRICT = true,
  global   = global,
  defined  = defined
}

require('lib.Import').make_exportable(exports)

return exports