local Scenes, Layer, Camera, Level, Physics, Tasks, Input, Text, Data, TickLogger; import()
local SystemLogger  = require 'ecs.SystemLogger'
local EntityManager = require 'ecs.EntityManager'

local common = {}

function common.set_systems(manager)
    local systems = {
        'infra.InputToAction',
        'domain.SelectNextJump',
        'domain.UpdateSpawn',
        'infra.UpdateVelocity',
        'domain.UpdateDirection',
        'domain.UpdateWalkingAI',
        'infra.SenseGround',
        'UseDoor',
        'infra.SenseLateralTouch',
        'UpdateLevelPosition',
        'RemovePlayer',
        'infra.RemoveEntities',
        'domain.Callback',
        'domain.UpdateWalker',
        'domain.MovePlayer',
        'ResolveCollisionHitbox',
        'ResolveCollisionPortal',
        'domain.ApplyDamage',
        'domain.JumpEnemy',
        'domain.ReactionPlayer',
        'WoundedPlayer',
        'domain.PlayerCollisionPower',
        'MaskFixtures',
        'domain.jump.UpdateState',
        'domain.jump.SingleStandard',
        'domain.jump.DoubleStandard',
        'domain.jump.BounceStandard',
        'domain.jump.WallStandard',
        'domain.jump.Falcon',
        'domain.jump.Space',
        'domain.jump.Kirby',
        'domain.jump.Teleport',
        'domain.jump.Peach',
        'domain.jump.Dixie',
        'domain.UpdateFallingMovement',
--        'domain.DEBUGFallingMovement',
        'infra.SetLinearVelocity',
        'Animate',
        'AnimateJumper',
        'AnimateJumpingText',
        'domain.RemoveAnimationEntity',
        'UpdateCamera',
        'domain.UpdateTicks',
        'ShowSelection',
        'ShowResources',
        'infra.ChangeScene'
    }

    for _, system in pairs(systems) do
        manager:add_system(system)
    end
end

local function logger_factory(filename)
    return TickLogger(project .. "/log/systems/" .. filename)
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