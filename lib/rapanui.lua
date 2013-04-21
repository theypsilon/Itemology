local oldclass = class
local oldrequire = require
function require(path)
    if path == 'config' then path = 'rapanui_config' end
    return oldrequire(path)
end

-- rapanui pultes the global scope with anoying functions as 'class'
import({'rapanui-sdk/rapanui'},'rapanui/','rapanui-sdk')

class   = oldclass
require = oldrequire