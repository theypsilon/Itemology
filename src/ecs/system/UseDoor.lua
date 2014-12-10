local System; import 'ecs'
local Scenes; import()
local UseDoor = class(System)

function UseDoor:requires()
	return {'door', 'action', 'level', 'body', 'hp'}
end

function UseDoor:update(e, dt, door, action, level, body, hp)
    if action.up or action.door then
        if door.level and door.level ~= level.name then
            gTasks:once('changeMap', function() 
                Scenes.run('First', door, hp) 
            end)
        else
            local link = door.layer.objects[door.link]
            if link then body:setTransform(link.x, link.y) end
        end
        action.up, action.door = false, false
    end
end


return UseDoor