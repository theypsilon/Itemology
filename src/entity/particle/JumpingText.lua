local Text, Layer, Random; import()

local function JumpingText(level, msg, x, y)
    local e = {}
    e.pos = {x = 0, y = 0}
    e.ticks  = 0
    e.level  = level
    e.map    = level.map

    local style = MOAITextStyle.new()
    style:setFont(Text.style:getFont())
    style:setSize(100)
    style:setScale(0.1)
    style:setColor(1,.2,.2)

    e.animation_jumping_text = true

    e.prop = Text:print(msg, x, y, style, nil, nil, Layer.main)
    e.prop:setPriority(1000)

    local rand = Random.next
    e.jumping_values = {
        xa = (rand()*2 -1)*0.3,
        ya = (rand()*2 -1)*0.2,
        za = rand()*0.7 + 2,
        z  = 2
    }
    e._name="particle.JumpingText"
    return e
end

return JumpingText