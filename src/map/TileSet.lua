local resource, layer = require 'resource', require 'Layer'

return function(ts, dir)
    local spa = ts.spacing
    if false and spa and spa > 0 then
        local src = resource.getImage(dir .. ts.image, true)
        local img = MOAIImage.new()
        img:init(ts.imagewidth, ts.imageheight)
        local tw,  th  = ts.tilewidth, ts.tileheight
        local twp, thp = tw + spa, th + spa
        for x = 0, ts.imagewidth do
            for y = 0, ts.imageheight do
                local xos, yos, xod, yod = twp * x, thp * y, tw * x, th * y
                img:copyBits(src, xos, yos, xod, yod, tw, th)
            end
        end
        local texture = MOAITexture.new()
        --texture:setFilter(MOAITexture.GL_NEAREST_MIPMAP_NEAREST)
        texture:load(img)

        local w, h = ts.imagewidth, ts.imageheight
                
        -- local quad = MOAIGfxQuad2D.new ()
        -- quad:setTexture ( texture )
        -- quad:setRect ( -w/2, h/2, w/2, -h/2 )
         
        -- local prop = MOAIProp2D.new()
        -- prop:setDeck ( quad )
        -- prop:setLoc(w/2, h/2)
        -- prop:setPriority(1000)
        -- layer.text:insertProp ( prop )

        ts.tex = texture
    else
        ts.tex = resource.getImage(dir .. ts.image)
    end
    return ts
end