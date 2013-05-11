local scene = {}

function scene.load()
	require 'entity.Player'

    local level    = Level("plattform.tmx")
    local player   = Player(level, 100, 100)
    local cameras  = {}
    local w, h     = love.graphics.getWidth(), love.graphics.getHeight()
    cameras[Camera(player, {x=0,   y=0  , w=w/2, h=h/2}, {x=40, y=40})] = true
    cameras[Camera(player, {x=w/2, y=0  , w=w/2, h=h/2}              )] = true
    cameras[Camera(player, {x=0  , y=h/2, w=w/2, h=h/2}, {x=80, y=65})] = true
    cameras[Camera(player, {x=w/2, y=h/2, w=w/2, h=h/2}, {x=10, y=10})] = true
    scene.cameras, scene.level, scene.player = cameras, level, player
end

function scene.draw()
    for camera,_ in pairs(scene.cameras) do
        camera:draw()
    end
    love.graphics.print(
        "tick " .. scene.player._ticks .. 
        "\nx: " .. scene.player.x ..
        "\ny: " .. scene.player.y , 
        20, 20 )
end

function scene.update(dt)
    if scene.pause then return end
    for camera,_ in pairs(scene.cameras) do
        camera._level:tick(dt)
    end
end

function scene.focus(inside)
    scene.pause = not inside
end

return scene