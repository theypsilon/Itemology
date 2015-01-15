project = './'
package.path = package.path .. ';?/init.lua'
package.path = package.path .. ';src/?.lua'
package.path = package.path .. ';src/?/init.lua'

require 'Globals'

setmetatable(_G, nil)