local super = require 'entity.Entity'

local Text, Layer = require 'Text', require 'Layer'

local JumpingText = class.JumpingText(super)

function JumpingText:_init(level, msg, x, y)
    local rand = require('Random').next
    super._init(self, level, 0, 0)

    local style = MOAITextStyle.new()
    style:setFont(Text.style:getFont())
    style:setSize(100)
    style:setScale(0.1)
    style:setColor(1,.2,.2)

    self.text = Text:print(msg, x, y, style, nil, nil, Layer.main)
    self.text:setPriority(1000)

    self.xa, self.ya, self.za = (rand()*2 -1)*0.3, (rand()*2 -1)*0.2, rand()*0.7 + 2
    self.z = 2
end

function JumpingText:tick()
    super.tick(self)

    if self._ticks > 60 then self:remove() end

    self.x, self.y, self.z = self.x + self.xa, self.y + self.ya, self.z + self.za
    if self.z < 0 then
        self.z = 0
        self.za = self.za * -.5
        self.xa = self.xa *  .6
        self.ya = self.ya *  .6
    end
    self.za = self.za - .15
    self.text:setLoc(self.x, self.y - self.z)
end

function JumpingText:remove()
    super.remove(self)
    Layer.main:removeProp(self.text)
end

return JumpingText