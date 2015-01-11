local Scenes, Layer, Camera, Level, Physics, Tasks, Input, Text, Data, Logger; import()
local SystemLogger  = require 'ecs.SystemLogger'
local EntityManager = require 'ecs.EntityManager'

local common = {}

function common.set_systems(manager)
    manager:add_system('UpdateInput')
    manager:add_system('SelectNextJump')
    manager:add_system('UpdateSpawn')
    manager:add_system('UpdateVelocity')
    manager:add_system('UpdateDirection')
    manager:add_system('UpdateWalkingAI')
    manager:add_system('UpdateGroundDetector')
    manager:add_system('UseDoor')
    manager:add_system('UpdateLateralTouch')
    manager:add_system('UpdateLevelPosition')
    manager:add_system('RemovePlayer')
    manager:add_system('RemoveEntities')
    manager:add_system('Callback')
    manager:add_system('UpdateWalker')
    manager:add_system('MovePlayer')
    manager:add_system('ResolveCollisionHitbox')
    manager:add_system('ResolveCollisionPortal')
    manager:add_system('ApplyDamage')
    manager:add_system('JumpEnemy')
    manager:add_system('ReactionPlayer')
    manager:add_system('WoundedPlayer')
    manager:add_system('PlayerCollisionPower')
    manager:add_system('MaskFixtures')
    manager:add_system('jump.UpdateState')
    manager:add_system('jump.SingleStandard')
    manager:add_system('jump.DoubleStandard')
    manager:add_system('jump.BounceStandard')
    manager:add_system('jump.WallStandard')
    manager:add_system('jump.Falcon')
    manager:add_system('jump.Space')
    manager:add_system('jump.Kirby')
    manager:add_system('jump.Teleport')
    manager:add_system('jump.Peach')
    manager:add_system('jump.Dixie')
    manager:add_system('UpdateFallingMovement')
    manager:add_system('Animate')
    manager:add_system('AnimateJumper')
    manager:add_system('AnimateJumpingText')
    manager:add_system('RemoveAnimationEntity')
    manager:add_system('UpdateCamera')
    manager:add_system('UpdateTicks')
    manager:add_system('ShowSelection')
    manager:add_system('ShowResources')
    manager:add_system('ChangeScene')
end

local function logger_factory(filename)
    return Logger(project .. "/log/systems/" .. filename)
end

function common.get_prototype(start_prototype)
    local common_scene = {}
    function common_scene:init()
        self:load(unpack(self.init_package))
    end

    function common_scene:load(start, hp)

        Physics:init(Data.world.First)

        if Data.MainConfig.dev.debug_physics then Layer.main:setBox2DWorld (Physics.world) end

        local di = {}
        di.system_logger = SystemLogger(logger_factory)
        local manager = EntityManager(di)

        common.set_systems(manager)

        self.manager = manager

        local level     = Level (start and start.level or start_prototype, manager)
              level:initEntities ('objects'  )
              level:initStructure('platforms')


        local player    = level.player
        local cameras   = {}

        player.first_scene = "First"

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

        local fps   = Text:print('FPS: 60.1', 10, 8)

        gTasks:set('updateFPS'   , function()
            fps:setString('FPS: ' .. tostring(MOAISim.getPerformance()):sub(0, 4))
        end, 100)
    end

    function common_scene:draw() end

    function common_scene:update(dt)
        if self.pause then return end

        self.manager:update(dt)

        MOAISim:forceGC()

        gTasks()
    end

    function common_scene:focus(inside)
        self.pause = not inside
    end

    function common_scene:clear()
        Physics:clear()
        Layer.clear_all()
    end

    return common_scene
end

return common