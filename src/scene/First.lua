local Scenes, Layer, Camera, Level, Data, Physics, Tasks, Input, Flow, Text, Data; import()
local EntityManager = require 'ecs.EntityManager'

scene = {}

function scene:load(start, hp)

    Physics:init(Data.world.First)

    if Data.MainConfig.dev.debug_physics then Layer.main:setBox2DWorld (Physics.world) end

    local manager = EntityManager()
    manager:add_system('UpdateInput')
    manager:add_system('UpdateVelocity')
    manager:add_system('UpdateDirection')
    manager:add_system('UpdateWalkingAI')
    manager:add_system('UpdateGroundDetector')
    manager:add_system('UseDoor')
    manager:add_system('UpdateLateralTouch')
    manager:add_system('UpdateLevelPosition')
    manager:add_system('RemoveEntities')
    manager:add_system('UpdateLevelScript')
    manager:add_system('UpdateWalker')
    manager:add_system('UpdatePlayer')
    manager:add_system('UpdateJumpState')
    manager:add_system('UpdateAttackState')
    manager:add_system('UpdateWalkingEnemy')
    manager:add_system('UpdateFallingMovement')
    manager:add_system('UpdateObject')
    manager:add_system('Animate')
    manager:add_system('UpdateCamera')
    manager:add_system('UpdateTicks')
    manager:add_system('ShowSelection')
    manager:add_system('ShowResources')

    self.manager = manager
    global{manager = manager}
    
    local level     = Level (start and start.level or Data.MainConfig.start)
          level:initEntities ('objects'  )
          level:initStructure('platforms')


    local player    = level.player
    local cameras   = {}

    manager:add_entity(player)
    manager:add_entity(level)
    for e, _ in pairs(level.entities) do
        manager:add_entity(e)
    end

    if start then
        if start.link then
            local link = level.map('objects')(start.link)
            if link and link.x and link.y then
                player.body:setTransform(link.x, link.y)
            end
        elseif start.initx and start.inity then
            player.body:setTransform(start.initx, start.inity)
        end
    end

    if hp then player.hp = hp end

    local cam = Camera(player)
    cameras[cam] = true
    level:initProperties(cam)

    manager:add_entity(cam)
    
    self.cameras, self.level, self.player = cameras, level, player

    Input.bindAction('reset', function() 
        gTasks:once('reset', function()
            for i = 1, 1, 1 do Scenes.run('First') end
        end)
    end)

    local fps    = Text:print('FPS: 60.1', 10, 8)

    gTasks:set('updateFPS'   , function() 
        fps:setString('FPS: ' .. tostring(MOAISim.getPerformance()):sub(0, 4))
    end, 100)
end 

function scene:draw()
    for camera,_ in pairs(self.cameras) do
    --    camera:draw()
    end

end

function scene:update(dt)
    if self.pause then return end
    --for camera,_ in pairs(self.cameras) do
    --   self.level:tick(dt)
    --end

    self.manager:update(dt)

    if self.player.removed then
        Text:print('Game Over', 240, 140)
            --:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
        Text:print('Press ESPACE to restart', 170, 210)
            --:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
        Input.bindAction(self.player.keyconfig.jump, function()
            Scenes.run('First')
        end)
        self.player.removed = nil
    end

    gTasks()
end

function scene:focus(inside)
    self.pause = not inside
end

function scene:clear()
    Layer.text:clear()
    Layer.text = nil
    Flow.clear()
end