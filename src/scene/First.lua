local scene = {}

function scene.load()
	require 'entity.Player'

    local level     = Level ("plattform.tmx")
    local spawn     = level.map('objects')('spawn')
    local collision = level.map('platforms') 
    local player    = Player(level, spawn.x, spawn.y)
    local cameras   = {}

    local col = require 'map.Collision'
    local sol, pol, drawMap = col.go(level.map)

    dump(drawMap())
    local e = {}
    for k,v in pairs(pol) do
        e[k] = v
    end
    dump(e)
    dump(table.count(pol))

    local scriptDeck = MOAIScriptDeck.new ()
    scriptDeck:setRect (0, 0, 2000, 2000)
    scriptDeck:setDrawCallback ( function()
        MOAIDraw.drawLine(unpack(pol))
    end )

    local prop = MOAIProp2D.new ()
    prop:setDeck ( scriptDeck )
    prop:setLoc (0, 0)
    prop:setPriority(1)
    layer.main:insertProp ( prop )

    

    cameras[Camera(player)] = true
    
    -- cameras[Camera(player, {x=0,   y=0  , w=w/2, h=h/2}, {x=40, y=40})] = true
    -- cameras[Camera(player, {x=w/2, y=0  , w=w/2, h=h/2}              )] = true
    -- cameras[Camera(player, {x=0  , y=h/2, w=w/2, h=h/2}, {x=80, y=65})] = true
    -- cameras[Camera(player, {x=w/2, y=h/2, w=w/2, h=h/2}, {x=10, y=10})] = true
    
    scene.cameras, scene.level, scene.player = cameras, level, player

end 

function scene.draw()
    for camera,_ in pairs(scene.cameras) do
        camera:draw()
    end

    -- love.graphics.print(
    --     "tick " .. scene.player._ticks .. 
    --     " fps " .. tostring(love.timer.getFPS()) ..
    --     "\nx: " .. scene.player.x ..
    --     "\ny: " .. scene.player.y , 
    --     20, 20 )
end
function scene.update(dt)
    if scene.pause then return end
    for camera,_ in pairs(scene.cameras) do
        camera._level:tick(dt)
    end
    physics:update()
end

function scene.focus(inside)
    scene.pause = not inside
end

return scene