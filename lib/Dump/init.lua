local current_dir = (...)

if string.sub(current_dir, -4) == "init" then
    current_dir = string.sub(current_dir, 0, -6)
end

local backup_require = require
require = function(path) return backup_require(current_dir .. "." .. path) end
local lib = require 'dump'
require = backup_require

return lib