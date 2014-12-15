local Scenes, Physics; import()
local System; import 'ecs'
local ChangeScene = class(System)

function ChangeScene:requires()
    return {'change_scene'}
end

function ChangeScene:update(e, _, change_scene)
    Physics:clear()
    Scenes.run(unpack(change_scene))
end


return ChangeScene