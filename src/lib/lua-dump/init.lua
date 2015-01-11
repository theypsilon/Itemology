local current_dir = (...):gsub('%.','/')

if string.sub(current_dir, -5) == "/init" then
    current_dir = string.sub(current_dir, 0, -6)
end

local backup_path = package.path
package.path = package.path .. ";" .. current_dir .. "/?.lua"

local lib = require 'dump'

package.path = backup_path

return lib