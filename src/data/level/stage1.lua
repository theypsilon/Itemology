local Tasks, Data; import()

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

    local wallJump = player.moveWallJump
    --player.moveWallJump = nothing

    local createJump, jumpCharges = getJumpFactory(level)

    local _, limit = level.map:getBorder()

    local cheat   = level.map('regions'):getRegion('cheat'  )
    local upfloor = level.map('regions'):getRegion('upfloor').y

    limit = limit - 32

    camera._end.y   = limit
    camera._begin.y = 480

    local djump, trick = true, true
    return function()
        if player.power.djump >= jumpCharges then djump = false end

        if player.power.djump == 0 or (cheat:contains(player) and trick) then
            if not djump then
                gTasks:once('respawnJump', function() level:add(createJump()) end, 50)
                djump = true
            end
            trick = player.power.djump == 0
        end

        if player.y < upfloor and camera._begin.y > 0 then
            player.moveWallJump = wallJump
            camera._begin.y = camera._begin.y - 5
            camera._end.y   = camera._end.y > (limit - 344) and camera._end.y - 5 or limit - 344
        elseif player.y > upfloor and camera._end.y < limit then
            camera._end.y = camera._end.y >= limit and limit or camera._end.y + 10
        end
    end
end