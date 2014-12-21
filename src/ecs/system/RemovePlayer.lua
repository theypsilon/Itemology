local System; import 'ecs'
local Text, Input, Layer, Physics; import()
local RemovePlayer = class(System)

function RemovePlayer:requires()
    return {'first_scene', 'removed', 'player'}
end

function RemovePlayer:update(e, dt, first_scene)
    Text:print('Game Over', 240, 140)
    Text:print('Press ESPACE to restart', 170, 210)
    Input.bindAction(e.keyconfig.jump, function()
        self.manager.next = {name=first_scene, params={}}
    end)
end


return RemovePlayer