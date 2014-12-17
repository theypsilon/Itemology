local Scenes, Layer, Camera, Level, Data, Physics, Tasks, Input, Text, Data, CommonScene, Logger; import()
local SystemLogger  = require 'ecs.SystemLogger'
local EntityManager = require 'ecs.EntityManager'

scene = {}

local function logger_factory(filename)
    return Logger(project .. "/log/systems/" .. filename)
end

function scene:load(start, hp)

    Physics:init(Data.world.First)

    if Data.MainConfig.dev.debug_physics then Layer.main:setBox2DWorld (Physics.world) end

    local di = {}
    di.system_logger = SystemLogger(logger_factory)
    local manager = EntityManager(di)

    CommonScene.set_systems(manager)

    self.manager = manager
    
    local level     = Level (start and start.level or Data.MainConfig.start, manager)
          level:initEntities ('objects'  )
          level:initStructure('platforms')


    local player    = level.player
    local cameras   = {}

    if defined('tickClock') then manager:add_entity(tickClock) end
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

function scene:draw() end

function scene:update(dt)
    if self.pause then return end

    self.manager:update(dt)

    if self.player.removed then
        Text:print('Game Over', 240, 140)
        Text:print('Press ESPACE to restart', 170, 210)
        Input.bindAction(self.player.keyconfig.jump, function()
            Scenes.run('First')
        end)
        self.player.removed = nil
    end

    MOAISim:forceGC()

    gTasks()
end

function scene:focus(inside)
    self.pause = not inside
end

function scene:clear()
    Layer.text:clear()
    Layer.text = nil
end