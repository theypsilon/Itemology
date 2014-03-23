local Text, Layer; import()
local Entity;      import 'entity'

local JumpingText = class(Entity)
function JumpingText:_init(level, msg, x, y)
    local rand = require 'Random' .next
    Entity._init(self, level, 0, 0)

    local style = MOAITextStyle.new()
    style:setFont(Text.style:getFont())
    style:setSize(100)
    style:setScale(0.1)
    style:setColor(1,.2,.2)

    self.animation = true

    self.text = Text:print(msg, x, y, style, nil, nil, Layer.main)
    self.text:setPriority(1000)

    self.jumping_values = {
        xa = (rand()*2 -1)*0.3,
        ya = (rand()*2 -1)*0.2,
        za = rand()*0.7 + 2,
        z  = 2
    }
end

function JumpingText:tick()
    Entity.tick(self)

    if self.ticks > 60 then self:remove() end

    local val = self.jumping_values
    local pos = self.pos

    pos.x, pos.y, val.z = pos.x + val.xa, pos.y + val.ya, val.z + val.za
    
    if val.z < 0 then
        val.z = 0
        val.za = val.za * -.5
        val.xa = val.xa *  .6
        val.ya = val.ya *  .6
    end
    val.za = val.za - .15
    self.text:setLoc(pos.x, pos.y - val.z)
end

function JumpingText:remove()
    Entity.remove(self)
    Layer.main:removeProp(self.text)
end

return JumpingText