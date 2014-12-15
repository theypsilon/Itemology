local Scenes, Physics, Layer, Application; import()
local System; import 'ecs'
local ChangeScene = class(System)

function ChangeScene:requires()
    return {'change_scene'}
end

function ChangeScene:update(e, _, change_scene)
    Layer.text:clear()
    Physics   :clear()
    Layer.main:clear()
    Layer.text = nil
    Scenes.run(unpack(change_scene))
    e.change_scene = nil
end


return ChangeScene