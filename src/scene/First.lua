local scene = {}

local level, player, cameras = nil, nil, {}
function scene.load()
	require 'entity.Player'

    level    = Level("plattform.tmx")
    player   = Player(level, 100, 100)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    cameras[Camera(player, {x=0,   y=0  , w=w/2, h=h/2},{x=40, y=40})] = true
    cameras[Camera(player, {x=w/2, y=0  , w=w/2, h=h/2}             )] = true
    cameras[Camera(player, {x=0  , y=h/2, w=w/2, h=h/2},{x=80, y=65})] = true
    cameras[Camera(player, {x=w/2, y=h/2, w=w/2, h=h/2},{x=10, y=10})] = true
end

function scene.draw()
    for camera,_ in pairs(cameras) do
        camera:draw()
    end
    love.graphics.print(
        "tick " .. player._ticks .. 
        "\nx: " .. player.x ..
        "\ny: " .. player.y , 
        20, 20 )
end

function scene.update(dt)
    if pause then return end
    level:tick(dt)
end

function scene.focus(inside)
    pause = not inside
end

return scene