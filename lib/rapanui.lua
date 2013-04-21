local norn = {}
local oldclass = class
setmetatable(_G,{__newindex = function(t, key, value) 
    if key:sub(0,2) == 'RN' then
        rawset(t, key, value)
    elseif _G[key] == nil then
        table.insert(norn, key)
        rawset(t, key, value)
    end
end})

for _,v in ipairs(norn) do print(v) end

-- rapanui pultes the global scope with anoying functions as 'class'
import({'rapanui-sdk/rapanui'},'rapanui/','rapanui-sdk')

class = oldclass

setmetatable(_G,nil)