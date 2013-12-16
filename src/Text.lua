local Layer, Data; import()

local Text = {store = {}}
function Text:init()
    local def = Data.language.Config

    local lang = Data.language[def.lang]
    local font = MOAIFont.new()

    font:loadFromTTF(project .. 'res/fonts/FreePixel.ttf', lang.charcodes, 100, 163 )

    local style = MOAITextStyle.new()
    style:setFont(font)
    style:setSize(100)
    style:setScale(0.2)
    style:setColor(1,1,1)

    self.style = style

    self.init = function() end --error 'you didnt call Text:init() before' end
end

function Text:print(string, x, y, style, rect, yflip, layer)
    if self.init then self:init() end

    local textbox = MOAITextBox.new ()

    if not x or not y then x, y = 0, 0                                 end
    if not style      then style = self.style                          end
    if not rect       then rect = self.rect                            end

    assert(string,    'cant print nil')
    assert(style, 'style is mandatory')

    textbox:setString(string)
    textbox:setStyle(style)

    local w, h

    if rect then x, y, w, h = rect.x, rect.y, rect.w, rect.h
            else       w, h = x + 400, y + 400           end

    textbox:setRect(x, y, w, h)
    if yflip then textbox:setYFlip(true)    end

    if not layer then layer = Layer.text end
    if layer then layer:insertProp(textbox) end

    table.insert(self.store, textbox)
    return textbox
end

local debugList = {}

function Text:debug(object, index, string, deactivate, filter)

    if deactivate then 
        debugList[string or index .. ' = '] = nil
        return
    end

    local Tasks, Job = require 'Tasks', require 'Job'

    string = string or index .. ' = '

    local text = self:print('', nil, nil, nil, nil, nil, Layer.Debug)

    if debugList[string] then Layer.Debug:removeProp(debugList[string].t) end
    debugList[string] = {t=text, k=index, o=object, f=filter}

    gTasks:set('textDebug', function()
        local i = -1
        for s,v in pairs(debugList) do 
            local value = v.o[v.k]
            if v.f and not v.f(value) then
                value = ''
            else
                i = i + 1
                value = s .. tostring(value)
            end
            v.t:setString(value)
            v.t:setLoc(400, i*20)
        end
    end)
end

function Text:console(var, update)
    local str = export_var(var)
    if self.lastconsole == str and not update then return end

    self.lastconsole = str
    print(str)
end

function Text:clear()

end

return Text