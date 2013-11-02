scene = {}

local Scenes, Layer, Camera, Level, Data, Physics, Test, TaskQueue, Input, Flow = 
require 'Scenes', require 'Layer',   require 'Camera', require 'Level', 
require 'Data',   require 'Physics', require 'Test',   require 'TaskQueue',
require 'Input',  require 'Flow'

function scene.load()

    Physics:init(data.world.First)

    if Data.MainConfig.debugPhysics then Layer.main:setBox2DWorld (Physics.world) end

    local i = 0
    for k,v in pairs(Physics.bodies) do
        i = i + 1
    end
    dump(i)

    local level     = Level ("plattform.tmx")
          level:initEntities ('objects'  )
          level:initStructure('platforms')

    local player    = level.player
    local cameras   = {}

    cameras[Camera(player)] = true
    
    scene.cameras, scene.level, scene.player = cameras, level, player

    Input.bindAction('reset', function() 
        TaskQueue.setOnce('reset', function()
            for i = 1, 100, 1 do Scenes.run('First') end
        end)
    end)

end 

function scene.draw()
    for camera,_ in pairs(scene.cameras) do
        camera:draw()
    end

end
function scene.update(dt)
    if scene.pause then return end
    --for camera,_ in pairs(scene.cameras) do
        scene.level:tick(dt)
    --end
    if scene.player.removed then
        print 'Game Over'
        os.exit()
    end
    for _,f in TaskQueue.iterator() do f() end
end

function scene.focus(inside)
    scene.pause = not inside
end

function scene.clear()
    Flow.clear()
end