local Job, Data; import()

local function getJumpFactory(level)
    local jump = level.map('objects').objects['jump']
    local def  = Data.entity[jump.type]
    local function createJump()
        return require(def.class)(level, def, jump, level.map('objects'))
    end
    return createJump, jump.properties.charges
end

return function(level, camera)
    local player = table.first(level.entityByName().Player)
    assert(player)

    player.jumpState.can_wall_jump = false
    player.attackState.can_attack  = false
    player.attackState.can_special = false

    local createJump, jumpCharges = getJumpFactory(level)

    local cheat   = level.map('regions'):getRegion('cheat'  )
    local visible = level.map('regions'):getRegion('visible')

    local limit = camera._limit

    limit.x = limit.x + 16
    limit.w = limit.w - 16

    camera._limit = table.copy(visible)
    camera._limit.h = camera._limit.h - 8

    visible.y = visible.y - 16

    local djump, trick = true, true
    
    local function main()
        if player.power.djump >= jumpCharges then djump = false end

        if player.power.djump == 0 or (cheat:contains(player) and trick) then
            if not djump then
                gTasks:once('respawnJump', function() level:add(createJump()) end, 50)
                djump = true
            end
            trick = player.power.djump == 0
        end
    end

    return Job.chain(function(c)
        main()

        if not visible:contains(player) then 
            player.jumpState.can_wall_jump = true
            player.attackState.can_attack  = true
            player.attackState.can_special = true
            c:next() 
        end
    end):after(function(c)
        main()

        camera._limit.y = camera._limit.y - 5
        camera._limit.h = camera._limit.h - 5

        if camera._limit.h <= visible.y + 16 then 
            camera._limit = limit
            camera._limit.h = visible.y + 16
            c:next() 
        end
    end):after(function(c)
        if     visible:contains(player)      then c:next() end
    end):after(function(c)
        main()

        camera._limit.h = camera._limit.h + 10

        if camera._limit.h >= visible.h - 8  then c:next() end
    end):after(main)
end