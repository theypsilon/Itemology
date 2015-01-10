local System; import 'ecs'
local Text, Layer; import()

local ShowResources = class(System)

function ShowResources:_init(...)
    System._init(self, ...)
    self.jumpResource_texts = {}
end

function ShowResources:requires()
	return {'jumpResource'}
end

function ShowResources:update(e, _, res)
    local i = 1
    local new_texts = {}
    for k, v in pairs(res) do
        local string = k .. " = " .. v
        local text
        if self.jumpResource_texts[k] then
            text = self.jumpResource_texts[k]
        end
        if not self.jumpResource_texts[k] then
            text = Text:print('', 0, 0, nil, nil, nil, Layer.Debug)
            Layer.Debug:insertProp(text)
        end
        text:setString(string)
        text:setLoc(200, 20 + 20*i)
        self.jumpResource_texts[k] = text
        i = i + 1
    end
end


return ShowResources