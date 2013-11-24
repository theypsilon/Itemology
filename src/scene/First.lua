scene = {}

local Scenes, Layer, Camera, Level, Data, Physics, Test, Tasks, Input, Flow, Text, Job =  
require 'Scenes', require 'Layer',   require 'Camera', require 'Level', 
require 'Data',   require 'Physics', require 'Test',   require 'Tasks',
require 'Input',  require 'Flow',    require 'Text',   require 'Job'

function scene:load(start, hp)

    Physics:init(data.world.First)

    if Data.MainConfig.dev.debugPhysics then Layer.main:setBox2DWorld (Physics.world) end
    
    local level     = Level (start and start.level or "stage1.tmx")
          level:initEntities ('objects'  )
          level:initStructure('platforms')


    local player    = level.player
    local cameras   = {}

    if start then
        if start.link then
            local link = level.map('objects')(start.link)
            if link and link.x and link.y then
                player.pos:set(link.x, link.y)
            end
        elseif start.x and start.y then 
            player.pos:set(start.x, start.y)
        end
    end

    if hp then player.hp = hp end

    local cam = Camera(player)
    cameras[cam] = true
    level:initProperties(cam)
    
    self.cameras, self.level, self.player = cameras, level, player

    Input.bindAction('reset', function() 
        Tasks:once('reset', function()
            for i = 1, 1, 1 do Scenes.run('First') end
        end)
    end)

    local fps    = Text:print('FPS: 60.1', 10, 8)

    Tasks:set('updateFPS'   , function() 
        fps:setString('FPS: ' .. tostring(MOAISim.getPerformance()):sub(0, 4))
    end, 100)
end 

function scene:draw()
    for camera,_ in pairs(self.cameras) do
        camera:draw()
    end

end

function scene:update(dt)
    if self.pause then return end
    --for camera,_ in pairs(self.cameras) do
        self.level:tick(dt)
    --end
    if self.player.removed then
        Text:print('Game Over', 240, 140)
            --:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
        Text:print('Press ESPACE to restart', 170, 210)
            --:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
        Input.bindAction('b2', function()
            Scenes.run('First')
        end)
        self.player.removed = nil
    end

    Tasks()
end

function scene:focus(inside)
    self.pause = not inside
end

function scene:clear()
    Layer.text:clear()
    Layer.text = nil
    Flow.clear()
end