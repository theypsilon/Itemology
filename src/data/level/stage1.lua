local Tasks, Data; import()

return function(level, camera)
    local player
    for e,_ in pairs(level.entities) do
        if e._name == 'Player' then player = e break end
    end

    local jump = level.map('objects').objects['jump']
    local def  = Data.entity[jump.type]
    local function createJump()
        return require(def.class)(level, def, jump, level.map('objects'))
    end

    local _, limit = level.map:getBorder()

    local cheat   = level.map('regions'):getRegion('cheat'  )
    local upfloor = level.map('regions'):getRegion('upfloor').y

    limit = limit - 32

    camera._end.y   = limit
    camera._begin.y = 480

    assert(player)
    local djump, trick = true, true
    return function()
        if player.power.djump >= jump.properties.charges then djump = false end

        if player.power.djump == 0 or (cheat:contains(player) and trick) then
            if not djump then
                gTasks:once('respawnJump', function() level:add(createJump()) end, 150)
                djump = true
            end
            trick = player.power.djump == 0
        end

        if player.y < upfloor and camera._begin.y > 0 then 
            camera._begin.y = camera._begin.y - 5
            camera._end.y   = camera._end.y > (limit - 344) and camera._end.y - 5 or limit - 344
        elseif player.y > upfloor and camera._end.y < limit then
            camera._end.y = camera._end.y >= limit and limit or camera._end.y + 10
        end
    end
end